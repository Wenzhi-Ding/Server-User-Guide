#!/usr/bin/env bash
# ============================================================
# 新增隧道用户 + 推送公钥到中转服务器
# 用法: sudo ./add-user.sh <用户名> --key-file <公钥文件> | --key <公钥字符串> [--port 端口] [--remark 备注]
# 示例: sudo ./add-user.sh charlie --key-file /tmp/charlie.pub --port 2225 --remark "访问学者"
#       sudo ./add-user.sh charlie --key "ssh-ed25519 AAAA... charlie@laptop" --port 2225
# ============================================================
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "[!] 请用 sudo 执行"
    exit 1
fi

# ---- 解析参数 ----
USERNAME=""
PUBKEY_FILE=""
PUBKEY_INLINE=""
PORT=""
REMARK=""

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
        --port)
            PORT="${2:?--port 需要端口号}"
            shift 2
            ;;
        --remark)
            REMARK="${2:?--remark 需要备注文本}"
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
    echo "用法: sudo ./add-user.sh <用户名> --key-file <公钥文件> | --key <公钥字符串> [--port 端口] [--remark 备注]"
    exit 1
fi

if [ -n "${PUBKEY_FILE}" ] && [ -n "${PUBKEY_INLINE}" ]; then
    echo "[!] --key-file 和 --key 不能同时使用"
    exit 1
fi

# ---- 加载配置 ----
source /etc/autossh/tunnel.conf
REGISTRY="/etc/autossh/port-registry.txt"

# ---- 输入校验 ----
if ! [[ "${USERNAME}" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "[!] 用户名不合法，仅允许小写字母、数字、下划线、连字符"
    exit 1
fi

if grep -qP "^\d+\s+${USERNAME}\b" "${REGISTRY}" 2>/dev/null; then
    echo "[!] 用户 ${USERNAME} 已存在于端口分配表:"
    grep -P "^\d+\s+${USERNAME}\b" "${REGISTRY}"
    exit 1
fi

# 校验公钥
if [ -n "${PUBKEY_INLINE}" ]; then
    # 直接传入的公钥字符串
    PUBKEY_CONTENT=$(echo "${PUBKEY_INLINE}" | grep -v '^#' | grep -v '^$' | head -1)
    if ! echo "${PUBKEY_CONTENT}" | grep -qE '^(ssh-(ed25519|rsa|ecdsa)|ecdsa-sha2)'; then
        echo "[!] 公钥字符串格式不正确"
        exit 1
    fi
elif [ -n "${PUBKEY_FILE}" ]; then
    if [ ! -f "${PUBKEY_FILE}" ]; then
        echo "[!] 公钥文件不存在: ${PUBKEY_FILE}"
        exit 1
    fi
    # 读取并校验公钥格式
    PUBKEY_CONTENT=$(grep -v '^#' "${PUBKEY_FILE}" | grep -v '^$' | head -1)
    if ! echo "${PUBKEY_CONTENT}" | grep -qE '^(ssh-(ed25519|rsa|ecdsa)|ecdsa-sha2)'; then
        echo "[!] 文件内容不像 SSH 公钥: ${PUBKEY_FILE}"
        exit 1
    fi
else
    PUBKEY_CONTENT=""
    echo "[!] 未提供 --key-file，将只创建 PolyU 用户和隧道，不推送公钥到中转服务器"
    echo "    后续可用: sudo ./push-key.sh ${USERNAME} <公钥文件>"
fi

# 自动分配端口
if [ -z "${PORT}" ]; then
    MAX_PORT=$(awk '/^[0-9]/{print $1}' "${REGISTRY}" | sort -n | tail -1)
    MAX_PORT=${MAX_PORT:-2220}
    PORT=$((MAX_PORT + 1))
    echo "[*] 自动分配端口: ${PORT}"
fi

if ! [[ "${PORT}" =~ ^[0-9]+$ ]] || [ "${PORT}" -lt 1024 ] || [ "${PORT}" -gt 65535 ]; then
    echo "[!] 端口号必须在 1024-65535 之间"
    exit 1
fi

if grep -qP "^${PORT}\s" "${REGISTRY}" 2>/dev/null; then
    echo "[!] 端口 ${PORT} 已被占用:"
    grep -P "^${PORT}\s" "${REGISTRY}"
    exit 1
fi

# ---- 创建系统用户 ----
if ! id "${USERNAME}" &>/dev/null; then
    echo "[*] 创建系统用户 ${USERNAME} ..."
    useradd -m -s /bin/bash "${USERNAME}"
    USER_HOME=$(eval echo "~${USERNAME}")
    mkdir -p "${USER_HOME}/.ssh"
    touch "${USER_HOME}/.ssh/authorized_keys"
    chmod 700 "${USER_HOME}/.ssh"
    chmod 600 "${USER_HOME}/.ssh/authorized_keys"
    chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}/.ssh"
    echo "    ✓ 用户已创建"
else
    echo "[*] 用户 ${USERNAME} 已存在，跳过创建"
    # 确保 .ssh 目录和 authorized_keys 存在
    USER_HOME=$(eval echo "~${USERNAME}")
    mkdir -p "${USER_HOME}/.ssh"
    touch "${USER_HOME}/.ssh/authorized_keys"
    chmod 700 "${USER_HOME}/.ssh"
    chmod 600 "${USER_HOME}/.ssh/authorized_keys"
    chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}/.ssh"
fi

# ---- 写入公钥到 PolyU 用户 ----
if [ -n "${PUBKEY_CONTENT}" ]; then
    USER_HOME=$(eval echo "~${USERNAME}")
    # 去重：已存在则跳过
    if grep -qF "${PUBKEY_CONTENT}" "${USER_HOME}/.ssh/authorized_keys" 2>/dev/null; then
        echo "[*] 公钥已存在于 ${USERNAME} 的 authorized_keys"
    else
        echo "${PUBKEY_CONTENT}" >> "${USER_HOME}/.ssh/authorized_keys"
        chown "${USERNAME}:${USERNAME}" "${USER_HOME}/.ssh/authorized_keys"
        echo "[✓] 公钥已写入 ${USER_HOME}/.ssh/authorized_keys"
    fi
fi

# ---- 推送公钥到中转服务器 ----
if [ -n "${PUBKEY_CONTENT}" ]; then
    echo "[*] 推送公钥到中转服务器 ..."
    RELAY_AK_ENTRY="restrict,port-forwarding,permitopen=\"localhost:${PORT}\" ${PUBKEY_CONTENT}"

    SSH_CMD="ssh -i ${MGMT_KEY} \
        -o Port=${RELAY_PORT} \
        -o StrictHostKeyChecking=yes \
        -o UserKnownHostsFile=/etc/autossh/known_hosts \
        -o IdentitiesOnly=yes \
        -o ConnectTimeout=15 \
        ${RELAY_MGMT_USER}@${RELAY_HOST}"

    if ${SSH_CMD} "grep -qF '${PUBKEY_CONTENT}' /home/tunnel/.ssh/authorized_keys 2>/dev/null"; then
        echo "    ✓ 公钥已存在于中转服务器"
    else
        ${SSH_CMD} "echo '${RELAY_AK_ENTRY}' >> /home/tunnel/.ssh/authorized_keys" && \
            echo "    ✓ 公钥已推送到中转服务器 tunnel authorized_keys" || \
            echo "    [!] 推送失败 — 管理密钥可能未添加到中转服务器 root 的 authorized_keys"
    fi
fi

# ---- 更新端口分配表 ----
TODAY=$(date '+%Y-%m-%d')
printf "%s\t%s\t%s\t%s\n" "${PORT}" "${USERNAME}" "${TODAY}" "${REMARK}" >> "${REGISTRY}"
echo "[✓] 端口分配表已更新"

# ---- 启动隧道实例 ----
echo "[*] 启动 polyu-tunnel@${PORT} ..."
systemctl enable "polyu-tunnel@${PORT}" 2>/dev/null
systemctl start "polyu-tunnel@${PORT}"
sleep 2

if systemctl is-active --quiet "polyu-tunnel@${PORT}"; then
    echo "[✓] 隧道已启动"
else
    echo "[✗] 隧道启动失败:"
    journalctl -u "polyu-tunnel@${PORT}" --no-pager -n 10
    exit 1
fi

# ---- 输出客户端配置 ----
echo ""
echo "===== 用户 ${USERNAME} 已添加 (端口 ${PORT}) ====="
echo ""
echo "将以下配置发给 ${USERNAME}，添加到 ~/.ssh/config:"
echo ""
echo "  Host polyu"
echo "      HostName localhost"
echo "      Port ${PORT}"
echo "      ProxyJump tunnel@8.218.122.123"
echo "      User ${USERNAME}"
echo "      ServerAliveInterval 30"
