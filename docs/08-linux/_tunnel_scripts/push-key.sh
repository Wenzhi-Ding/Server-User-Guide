#!/usr/bin/env bash
# ============================================================
# 单独推送/更新用户公钥（用于 add-user 时未提供密钥的场景）
# 用法: sudo ./push-key.sh <用户名> --key-file <公钥文件>
#       sudo ./push-key.sh <用户名> --key <公钥字符串>
# ============================================================
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "[!] 请用 sudo 执行"
    exit 1
fi

USERNAME=""
PUBKEY_FILE=""
PUBKEY_INLINE=""

# 第一个非选项参数是用户名
while [ $# -gt 0 ]; do
    case "$1" in
        --key-file)
            PUBKEY_FILE="${2:?--key-file 需要文件路径}"
            shift 2
            ;;
        --key)
            PUBKEY_INLINE="${2:?--key 需要公钥字符串}"
            shift 2
            ;;
        -*)
            echo "[!] 未知选项: $1"
            exit 1
            ;;
        *)
            if [ -z "${USERNAME}" ]; then
                USERNAME="$1"
            else
                echo "[!] 多余参数: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "${USERNAME}" ]; then
    echo "用法: sudo ./push-key.sh <用户名> --key-file <公钥文件>"
    echo "      sudo ./push-key.sh <用户名> --key <公钥字符串>"
    exit 1
fi

if [ -z "${PUBKEY_FILE}" ] && [ -z "${PUBKEY_INLINE}" ]; then
    echo "[!] 请提供 --key-file 或 --key"
    exit 1
fi

if [ -n "${PUBKEY_FILE}" ] && [ -n "${PUBKEY_INLINE}" ]; then
    echo "[!] --key-file 和 --key 不能同时使用"
    exit 1
fi

source /etc/autossh/tunnel.conf
REGISTRY="/etc/autossh/port-registry.txt"

# 查找端口
PORT=$(awk -v u="${USERNAME}" '$2 == u {print $1}' "${REGISTRY}")
if [ -z "${PORT}" ]; then
    echo "[!] 用户 ${USERNAME} 不在端口分配表中"
    exit 1
fi

# 获取公钥内容
if [ -n "${PUBKEY_INLINE}" ]; then
    PUBKEY_CONTENT=$(echo "${PUBKEY_INLINE}" | grep -v '^#' | grep -v '^$' | head -1)
    if ! echo "${PUBKEY_CONTENT}" | grep -qE '^(ssh-(ed25519|rsa|ecdsa)|ecdsa-sha2)'; then
        echo "[!] 公钥字符串格式不正确"
        exit 1
    fi
else
    if [ ! -f "${PUBKEY_FILE}" ]; then
        echo "[!] 公钥文件不存在: ${PUBKEY_FILE}"
        exit 1
    fi
    PUBKEY_CONTENT=$(grep -v '^#' "${PUBKEY_FILE}" | grep -v '^$' | head -1)
    if ! echo "${PUBKEY_CONTENT}" | grep -qE '^(ssh-(ed25519|rsa|ecdsa)|ecdsa-sha2)'; then
        echo "[!] 文件内容不像 SSH 公钥"
        exit 1
    fi
fi

# ---- 写入工作服务器 authorized_keys ----
USER_HOME=$(eval echo "~${USERNAME}")
if [ -d "${USER_HOME}/.ssh" ]; then
    if grep -qF "${PUBKEY_CONTENT}" "${USER_HOME}/.ssh/authorized_keys" 2>/dev/null; then
        echo "[*] 公钥已存在于工作服务器 authorized_keys"
    else
        echo "${PUBKEY_CONTENT}" >> "${USER_HOME}/.ssh/authorized_keys"
        chown "${USERNAME}:${USERNAME}" "${USER_HOME}/.ssh/authorized_keys"
        echo "[✓] 公钥已写入工作服务器 ${USERNAME} 的 authorized_keys"
    fi
fi

# ---- 推送到跳板服务器 ----
echo "[*] 推送公钥到跳板服务器 (端口 ${PORT}) ..."
RELAY_AK_ENTRY="restrict,port-forwarding,permitopen=\"localhost:${PORT}\" ${PUBKEY_CONTENT}"

SSH_CMD="ssh -i ${MGMT_KEY} \
    -o Port=${RELAY_PORT} \
    -o StrictHostKeyChecking=yes \
    -o UserKnownHostsFile=/etc/autossh/known_hosts \
    -o IdentitiesOnly=yes \
    -o ConnectTimeout=15 \
    ${RELAY_MGMT_USER}@${RELAY_HOST}"

if ${SSH_CMD} "grep -qF '${PUBKEY_CONTENT}' /home/tunnel/.ssh/authorized_keys 2>/dev/null"; then
    echo "    ✓ 公钥已存在于跳板服务器"
else
    ${SSH_CMD} "echo '${RELAY_AK_ENTRY}' >> /home/tunnel/.ssh/authorized_keys" && \
        echo "[✓] 公钥已推送到跳板服务器" || \
        echo "[!] 推送失败 — 检查管理密钥是否已添加到跳板服务器"
fi

echo ""
echo "===== 完成 ====="
echo "用户 ${USERNAME} (端口 ${PORT}) 的 SSH config:"
echo ""
echo "  Host my-server"
echo "      HostName localhost"
echo "      Port ${PORT}"
echo "      ProxyJump tunnel@${RELAY_HOST}"
echo "      User ${USERNAME}"
echo "      ServerAliveInterval 30"
