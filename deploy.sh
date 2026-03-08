#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEPLOY_TARGET="/var/www/guide"

cd "$SCRIPT_DIR"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --translate-only   Run translation without building/deploying
  --build-only       Build without translating or deploying
  --skip-translate   Build and deploy without translating
  --force-translate  Re-translate all files regardless of timestamps
  --lang LANG        Translate only specific language(s): en
  --dry-run          Show what would be translated
  -h, --help         Show this help
EOF
    exit 0
}

TRANSLATE=true
BUILD=true
DEPLOY=true
TRANSLATE_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --translate-only) BUILD=false; DEPLOY=false; shift ;;
        --build-only) TRANSLATE=false; DEPLOY=false; shift ;;
        --skip-translate) TRANSLATE=false; shift ;;
        --force-translate) TRANSLATE_ARGS+=(--force); shift ;;
        --lang) shift; TRANSLATE_ARGS+=(--lang "$1"); shift ;;
        --dry-run) TRANSLATE_ARGS+=(--dry-run); BUILD=false; DEPLOY=false; shift ;;
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

if $TRANSLATE; then
    echo ""
    echo "=== Translating documents ==="
    uv run python translate.py "${TRANSLATE_ARGS[@]}"
fi

if $BUILD; then
    echo ""
    echo "=== Building site ==="
    uv run mkdocs build
fi

if $DEPLOY; then
    echo ""
    echo "=== Deploying to ${DEPLOY_TARGET} ==="
    sudo rsync -a --delete site/ "${DEPLOY_TARGET}/"
    sudo chown -R deployer:webdeploy "${DEPLOY_TARGET}"
    echo "Deployed to https://guide.wenzhi-ding.com/"
fi

echo ""
echo "=== Done ==="
