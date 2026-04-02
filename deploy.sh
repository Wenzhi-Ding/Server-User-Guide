#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEPLOY_TARGET="/var/www/guide"

cd "$SCRIPT_DIR"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --build-only       Build without deploying
  -h, --help         Show this help
EOF
    exit 0
}

DEPLOY=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --build-only) DEPLOY=false; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

if ! command -v uv &>/dev/null; then
    echo "Error: uv is not installed. Install it first: https://docs.astral.sh/uv/"
    exit 1
fi

echo "=== Installing dependencies ==="
uv sync --quiet

echo ""
echo "=== Building site ==="
uv run mkdocs build

if $DEPLOY; then
    echo ""
    echo "=== Deploying to ${DEPLOY_TARGET} ==="
    sudo rsync -a --delete site/ "${DEPLOY_TARGET}/"
    sudo chown -R deployer:webdeploy "${DEPLOY_TARGET}"
    echo "Deployed to https://guide.wenzhi-ding.com/"
fi

echo ""
echo "=== Done ==="
