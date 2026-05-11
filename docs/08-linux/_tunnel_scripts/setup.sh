#!/usr/bin/env bash
# ============================================================
# Reverse SSH Tunnel — 首次安装
# 需 sudo 执行，仅运行一次
# ============================================================
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "[!] 请用 sudo 执行"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AUTOSSH_DIR="/etc/autossh"
SERVICE_SRC="${SCRIPT_DIR}/tunnel@.service"
ENV_SRC="${SCRIPT_DIR}/tunnel.conf"

echo "===== Reverse SSH Tunnel 安装 ====="
echo ""

# ---- 1. 创建专用系统用户 ----
echo "[1/8] 创建 tunnel-runner 系统用户 ..."
if id tunnel-runner &>/dev/null; then
    echo "    ✓ 已存在"
else
    useradd -r -s /usr/sbin/nologin -d "${AUTOSSH_DIR}" tunnel-runner
    echo "    ✓ 已创建"
fi

# ---- 2. 创建目录 ----
echo "[2/8] 创建 ${AUTOSSH_DIR}/ ..."
mkdir -p "${AUTOSSH_DIR}"

# ---- 3. 生成隧道密钥 ----
echo "[3/8] 生成隧道密钥 ..."
if [ -f "${AUTOSSH_DIR}/tunnel_key" ]; then
    echo "    ✓ 隧道密钥已存在，跳过"
else
    ssh-keygen -t ed25519 -f "${AUTOSSH_DIR}/tunnel_key" -N "" -C "tunnel-main"
    echo "    ✓ 已生成"
fi

# ---- 4. 生成管理密钥（用于推送/删除用户公钥到跳板服务器）----
echo "[4/8] 生成管理密钥 ..."
if [ -f "${AUTOSSH_DIR}/management_key" ]; then
    echo "    ✓ 管理密钥已存在，跳过"
else
    ssh-keygen -t ed25519 -f "${AUTOSSH_DIR}/management_key" -N "" -C "tunnel-management"
    echo "    ✓ 已生成"
fi

# ---- 5. 获取跳板服务器主机密钥 ----
echo "[5/8] 获取跳板服务器主机密钥 ..."
source "${ENV_SRC}"
if [ -f "${AUTOSSH_DIR}/known_hosts" ] && grep -q "${RELAY_HOST}" "${AUTOSSH_DIR}/known_hosts"; then
    echo "    ✓ known_hosts 已存在"
else
    ssh-keyscan -p "${RELAY_PORT}" "${RELAY_HOST}" > "${AUTOSSH_DIR}/known_hosts" 2>/dev/null
    LINES=$(wc -l < "${AUTOSSH_DIR}/known_hosts")
    if [ "${LINES}" -eq 0 ]; then
        echo "    ✗ 无法获取主机密钥，检查跳板服务器是否可达"
        exit 1
    fi
    echo "    ✓ 获取 ${LINES} 个密钥"
fi

# ---- 6. 安装配置文件 ----
echo "[6/8] 安装配置文件 ..."
cp "${ENV_SRC}" "${AUTOSSH_DIR}/tunnel.conf"
cp "${SERVICE_SRC}" /etc/systemd/system/tunnel@.service
echo "    ✓ tunnel.conf + tunnel@.service 已安装"

if [ ! -f "${AUTOSSH_DIR}/port-registry.txt" ]; then
    TODAY=$(date '+%Y-%m-%d')
    ADMIN_USER=$(logname 2>/dev/null || echo "admin")
    cat > "${AUTOSSH_DIR}/port-registry.txt" << EOF
# 端口分配表
# 格式：端口  用户名  创建日期  备注
10001	${ADMIN_USER}	${TODAY}	管理员
EOF
    echo "    ✓ 端口分配表已创建"
else
    echo "    ✓ 端口分配表已存在"
fi

# ---- 7. 设置权限 ----
echo "[7/8] 设置文件权限 ..."
chown tunnel-runner:tunnel-runner "${AUTOSSH_DIR}/tunnel_key"
chmod 600 "${AUTOSSH_DIR}/tunnel_key"
chown root:root "${AUTOSSH_DIR}/management_key"
chmod 600 "${AUTOSSH_DIR}/management_key"
chown root:root "${AUTOSSH_DIR}/tunnel_key.pub" "${AUTOSSH_DIR}/management_key.pub" \
    "${AUTOSSH_DIR}/known_hosts" "${AUTOSSH_DIR}/tunnel.conf" "${AUTOSSH_DIR}/port-registry.txt"
chmod 644 "${AUTOSSH_DIR}/tunnel_key.pub" "${AUTOSSH_DIR}/management_key.pub" \
    "${AUTOSSH_DIR}/known_hosts" "${AUTOSSH_DIR}/tunnel.conf" "${AUTOSSH_DIR}/port-registry.txt"
echo "    ✓ 权限已设置"

# ---- 8. 停旧进程、启动服务 ----
echo "[8/8] 停旧进程并启动服务 ..."
OLD_PIDS=$(pgrep -f "autossh.*-R" 2>/dev/null || true)
if [ -n "${OLD_PIDS}" ]; then
    echo "    停止旧 autossh 进程: ${OLD_PIDS}"
    kill ${OLD_PIDS} 2>/dev/null || true
    sleep 1
fi

systemctl daemon-reload

FIRST_PORT=$(awk '/^[0-9]/{print $1; exit}' "${AUTOSSH_DIR}/port-registry.txt")
if [ -n "${FIRST_PORT}" ]; then
    systemctl enable "tunnel@${FIRST_PORT}"
    systemctl start "tunnel@${FIRST_PORT}"
    sleep 2
    if systemctl is-active --quiet "tunnel@${FIRST_PORT}"; then
        echo "    ✓ tunnel@${FIRST_PORT} 已启动"
    else
        echo "    ✗ 启动失败（公钥可能尚未添加到跳板服务器）"
        echo "    查看日志: journalctl -u tunnel@${FIRST_PORT} --no-pager -n 20"
    fi
fi

echo ""
echo "===== 安装完成 ====="
echo ""
echo "【下一步】在跳板服务器上执行以下命令:"
echo ""
echo "  ─── 1. 创建 tunnel 用户 ───"
echo "  sudo useradd -m -s /usr/sbin/nologin tunnel"
echo "  sudo mkdir -p /home/tunnel/.ssh"
echo ""
echo "  ─── 2. 写入隧道公钥（用来建隧道的）───"
echo "  echo 'restrict,port-forwarding,permitopen=\"localhost:22\" $(cat ${AUTOSSH_DIR}/tunnel_key.pub)' | \\"
echo "      sudo tee /home/tunnel/.ssh/authorized_keys"
echo ""
echo "  ─── 3. 将管理公钥加入 root 的 authorized_keys ───"
echo "  echo '$(cat ${AUTOSSH_DIR}/management_key.pub)' | \\"
echo "      sudo tee -a /root/.ssh/authorized_keys"
echo ""
echo "  sudo chown -R tunnel:tunnel /home/tunnel/.ssh"
echo "  sudo chmod 700 /home/tunnel/.ssh"
echo "  sudo chmod 600 /home/tunnel/.ssh/authorized_keys"
