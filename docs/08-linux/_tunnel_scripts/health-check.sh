#!/usr/bin/env bash
# ============================================================
# 隧道健康检查 — 由 cron 定期执行
# 建议: */5 * * * * /home/wenzhi/server-management/reverse_ssh/health-check.sh
# ============================================================
set -euo pipefail

REGISTRY="/etc/autossh/port-registry.txt"
LOG_TAG="polyu-tunnel-health"
FAILURES=""

while IFS= read -r line; do
    # 跳过注释和空行
    [[ "${line}" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line}" ]] && continue

    PORT=$(echo "${line}" | awk '{print $1}')
    USER=$(echo "${line}" | awk '{print $2}')

    # 跳过非数字端口
    [[ "${PORT}" =~ ^[0-9]+$ ]] || continue

    if systemctl is-active --quiet "polyu-tunnel@${PORT}" 2>/dev/null; then
        logger -t "${LOG_TAG}" "OK port=${PORT} user=${USER}"
    else
        MSG="DOWN port=${PORT} user=${USER}"
        logger -t "${LOG_TAG}" "${MSG}"
        FAILURES="${FAILURES}\n${MSG}"
    fi
done < "${REGISTRY}"

# 如有故障，输出到 stderr（cron 会发邮件）
if [ -n "${FAILURES}" ]; then
    echo -e "Tunnel failures detected:${FAILURES}" >&2
    exit 1
fi
