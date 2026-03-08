#!/usr/bin/env python3
"""Translate Chinese markdown files to multiple languages using Ollama."""

import argparse
import json
import re
import sys
import time
from pathlib import Path

import requests

OLLAMA_URL = "http://192.168.0.244:11434/api/generate"
MODEL = "translategemma:12b"

LANGUAGES = {
    "en": "English",
}

DOCS_DIR = Path(__file__).parent / "docs"


def call_ollama(prompt: str, retries: int = 3) -> str:
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "options": {"temperature": 0.3},
    }
    for attempt in range(retries):
        try:
            resp = requests.post(OLLAMA_URL, json=payload, timeout=300)
            resp.raise_for_status()
            return resp.json()["response"]
        except (requests.RequestException, KeyError) as exc:
            if attempt == retries - 1:
                raise SystemExit(f"Ollama API failed after {retries} attempts: {exc}")
            wait = 2 ** attempt
            print(f"  Retry {attempt + 1}/{retries} in {wait}s: {exc}")
            time.sleep(wait)
    return ""


def build_prompt(text: str, target_lang: str) -> str:
    return (
        f"Translate the following Markdown document from Chinese to {target_lang}. "
        "Preserve ALL Markdown formatting, code blocks, links, images, admonitions "
        "(e.g. !!! note, !!! warning), YAML front matter, and any HTML tags exactly as they are. "
        "Only translate the human-readable text. Do NOT add any explanation or commentary. "
        "Output ONLY the translated Markdown.\n\n"
        f"{text}"
    )


def find_chinese_sources() -> list[Path]:
    all_md = sorted(DOCS_DIR.rglob("*.md"))
    sources = []
    for p in all_md:
        stem_parts = p.stem.rsplit(".", 1)
        if len(stem_parts) == 2 and stem_parts[1] in LANGUAGES:
            continue
        sources.append(p)
    return sources


def target_path(source: Path, lang_code: str) -> Path:
    return source.with_suffix(f".{lang_code}.md")


def needs_translation(source: Path, target: Path) -> bool:
    if not target.exists():
        return True
    return source.stat().st_mtime > target.stat().st_mtime


def translate_file(source: Path, lang_code: str, lang_name: str, force: bool = False) -> bool:
    target = target_path(source, lang_code)
    if not force and not needs_translation(source, target):
        return False

    rel = source.relative_to(DOCS_DIR)
    print(f"  {rel} -> {lang_code}: ", end="", flush=True)

    text = source.read_text(encoding="utf-8")
    prompt = build_prompt(text, lang_name)
    translated = call_ollama(prompt)

    translated = translated.strip()
    translated = re.sub(r"^```(?:markdown|md)?\s*\n", "", translated)
    translated = re.sub(r"\n```\s*$", "", translated)

    target.write_text(translated + "\n", encoding="utf-8")
    print("done")
    return True


def main():
    parser = argparse.ArgumentParser(description="Translate docs using Ollama")
    parser.add_argument("files", nargs="*", help="Specific Chinese .md files to translate (default: all)")
    parser.add_argument("--lang", nargs="*", choices=list(LANGUAGES.keys()), help="Target languages (default: all)")
    parser.add_argument("--force", action="store_true", help="Re-translate even if target is up to date")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be translated without doing it")
    args = parser.parse_args()

    target_langs = {k: LANGUAGES[k] for k in (args.lang or LANGUAGES.keys())}

    if args.files:
        sources = [Path(f).resolve() for f in args.files]
        for s in sources:
            if not s.exists():
                print(f"Error: {s} not found", file=sys.stderr)
                sys.exit(1)
    else:
        sources = find_chinese_sources()

    print(f"Sources: {len(sources)} files")
    print(f"Languages: {', '.join(target_langs.values())}")
    print()

    total = 0
    skipped = 0
    for source in sources:
        rel = source.relative_to(DOCS_DIR)
        for lang_code, lang_name in target_langs.items():
            target = target_path(source, lang_code)
            if args.dry_run:
                status = "NEEDS UPDATE" if needs_translation(source, target) else "up to date"
                print(f"  {rel} -> {lang_code}: {status}")
                continue

            if translate_file(source, lang_code, lang_name, force=args.force):
                total += 1
            else:
                skipped += 1

    print(f"\nTranslated: {total}, Skipped (up to date): {skipped}")


if __name__ == "__main__":
    main()
