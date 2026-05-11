#!/usr/bin/env bash
# ============================================================
# 删除隧道用户 + 从跳板服务器清除公钥
# 用法: sudo ./remove-user.sh <用户名> [--delete-home]
# ============================================================
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "[!] 请用 sudo 执行"
    exit 1
fi

USERNAME="${1:?用法: sudo ./remove-user.sh <用户名> [--delete-home]}"
DELETE_HOME="${2:-}"

source /etc/autossh/tunnel.conf
REGISTRY="/etc/autossh/port-registry.txt"

# 查找端口
PORT=$(awk -v u="${USERNAME}" '$2 == u {print $1}' "${REGISTRY}")
if [ -z "${PORT}" ]; then
    echo "[!] 用户 ${USERNAME} 不在端口分配表中"
    exit 1
fi

echo "[*] 用户 ${USERNAME} — 端口 ${PORT}"
echo "[!] 确认移除？(y/N)"
read -r CONFIRM
if [ "${CONFIRM}" != "y" ] && [ "${CONFIRM}" != "Y" ]; then
    echo "已取消"
    exit 0
fi

# ---- 停止并禁用隧道实例 ----
echo "[*] 停止 tunnel@${PORT} ..."
systemctl disable --now "tunnel@${PORT}" 2>/dev/null || true
echo "    ✓ 已停止"

# ---- 从跳板服务器删除公钥 ----
echo "[*] 从跳板服务器删除公钥 (匹配 permitopen 端口 ${PORT}) ..."
SSH_CMD="ssh -i ${MGMT_KEY} \
    -o Port=${RELAY_PORT} \
    -o StrictHostKeyChecking=yes \
    -o UserKnownHostsFile=/etc/autossh/known_hosts \
    -o IdentitiesOnly=yes \
    -o ConnectTimeout=15 \
    ${RELAY_MGMT_USER}@${RELAY_HOST}"

# 匹配包含 permitopen="localhost:PORT" 的行并删除
if ${SSH_CMD} "sed -i '/permitopen=\"localhost:${PORT}\"/d' /home/tunnel/.ssh/authorized_keys" 2>/dev/null; then
    echo "    ✓ 已从跳板服务器删除"
else
    echo "    [!] 删除失败或无匹配条目 — 管理密钥可能未配置"
fi

# ---- 从端口分配表移除 ----
sed -i "/^\s*${PORT}\s\+/d" "${REGISTRY}"
echo "    ✓ 端口分配表已更新"

# ---- 清理用户 ----
if [ "${DELETE_HOME}" = "--delete-home" ]; then
    echo "[*] 删除用户 ${USERNAME} 及主目录 ..."
    userdel -r "${USERNAME}" 2>/dev/null && echo "    ✓ 已删除" || echo "    ! 用户可能不存在"
else
    echo "[*] 保留 ${USERNAME} 的系统账户和数据"
    echo "    如需删除: sudo userdel -r ${USERNAME}"
fi

echo ""
echo "===== ${USERNAME} 已从隧道移除 (端口 ${PORT}) ====="
