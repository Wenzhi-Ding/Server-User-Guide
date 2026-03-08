# Server User Guide

This is a [mkdocs](https://www.mkdocs.org/) website that aims to guide using Linux servers for academic purposes.

Currently, it is written in Chinese. However, translation to other languages is strongly welcome and appreciated.

## Deploy

Requires [uv](https://docs.astral.sh/uv/).

```bash
# Full pipeline: translate → build → deploy
./deploy.sh

# Translate only (no build/deploy)
./deploy.sh --translate-only

# Build only (no translate/deploy)
./deploy.sh --build-only

# Build and deploy, skip translation
./deploy.sh --skip-translate

# Force re-translate all files regardless of timestamps
./deploy.sh --force-translate

# Translate a specific language only
./deploy.sh --lang en

# Dry run: show what would be translated
./deploy.sh --dry-run
```
