#!/usr/bin/env bash
# apply.sh — Sync POSIX ACLs to match permissions.json (single source of truth)
#
# Supports incremental updates via permissions.lock:
#   - If permissions.json hasn't changed (SHA-256 match), skip entirely
#   - If changed, only apply differences (added/removed/modified paths)
#   - Use --full to force a complete resync (ignores lock file)
#   - Use --dry-run to preview changes without applying
#
# Usage: sudo bash apply.sh [--dry-run] [--full]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/permissions.json"
LOCK="$SCRIPT_DIR/permissions.lock"
TMP_LOCK="${LOCK}.tmp"

trap 'rm -f "$TMP_LOCK"' EXIT

DRY_RUN=false
FULL_RUN=false

# Base directories where everyone can list first-level contents (but not access them).
# Other base dirs remain fully locked (owner-only).
BROWSABLE_BASE_DIRS=("/home/shared")

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --full)    FULL_RUN=true ;;
        *)         echo "Unknown argument: $arg" >&2; exit 1 ;;
    esac
done

if [[ "$DRY_RUN" == true ]]; then echo "[dry-run] No changes will be made."; fi
if [[ "$FULL_RUN" == true ]]; then echo "[full] Forced complete resync."; fi

if [[ ! -f "$CONFIG" ]]; then
    echo "Error: $CONFIG not found." >&2; exit 1
fi

for cmd in jq setfacl getfacl sha256sum; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is required." >&2; exit 1
    fi
done

CURRENT_HASH=$(sha256sum "$CONFIG" | awk '{print $1}')

# --- Early exit if nothing changed ---
if [[ "$FULL_RUN" == false && -f "$LOCK" ]]; then
    if LOCK_HASH=$(jq -r '.permissions_hash // ""' "$LOCK" 2>/dev/null); then
        if [[ "$LOCK_HASH" == "$CURRENT_HASH" ]]; then
            echo "No changes detected (permissions.json hash unchanged). Exiting."
            exit 0
        fi
    else
        echo "Warning: lock file corrupt, falling back to full sync." >&2
        FULL_RUN=true
    fi
fi

# --- Determine mode ---
MODE="full"
if [[ "$FULL_RUN" == false && -f "$LOCK" ]]; then
    MODE="incremental"
    echo "Changes detected — running incremental update..."
elif [[ "$FULL_RUN" == true ]]; then
    echo "Full resync — applying all permissions from scratch..."
else
    echo "No lock file found — running initial full sync..."
fi
echo ""

# --- Extract base directories from config ---
# e.g. /home/shared/dataset_a → /home/shared
#       /home/projects/2026_xxx  → /home/projects
BASE_DIRS=$(jq -r '
    [.[].rw // [], .[].ro // []] | flatten | .[] |
    split("/") | .[0:3] | join("/")
' "$CONFIG" | sort -u)

# =========================================================================== #
# Helper functions
# =========================================================================== #

revoke_path() {
    local user="$1" path="$2"
    [[ -e "$path" ]] || return 0
    if getfacl -p "$path" 2>/dev/null | grep -q "^user:${user}:"; then
        echo "  revoke  $user  $path"
        if [[ "$DRY_RUN" == false ]]; then
            setfacl -R -x "u:${user}" "$path" 2>/dev/null || true
            setfacl -R -d -x "u:${user}" "$path" 2>/dev/null || true
        fi
    fi
}

apply_rw() {
    local user="$1" path="$2"
    if [[ ! -e "$path" ]]; then
        echo "  Warning: $path does not exist, skipping." >&2; return
    fi
    echo "  apply rw  $user  $path"
    if [[ "$DRY_RUN" == false ]]; then
        setfacl -R -m "u:${user}:rwX" "$path"
        setfacl -R -d -m "u:${user}:rwX" "$path"
    fi
}

apply_ro() {
    local user="$1" path="$2"
    if [[ ! -e "$path" ]]; then
        echo "  Warning: $path does not exist, skipping." >&2; return
    fi
    echo "  apply ro  $user  $path"
    if [[ "$DRY_RUN" == false ]]; then
        setfacl -R -m "u:${user}:rX" "$path"
        setfacl -R -d -m "u:${user}:rX" "$path"
    fi
}

is_browsable_dir() {
    local dir="$1"
    for bd in "${BROWSABLE_BASE_DIRS[@]}"; do
        [[ "$dir" == "$bd" ]] && return 0
    done
    return 1
}

set_traverse() {
    local user="$1" path="$2"
    local parent="$path"
    while true; do
        parent="$(dirname "$parent")"
        [[ "$parent" == "/" || "$parent" == "/home" ]] && break
        # Skip browsable base dirs — they have o+rx, no per-user ACL needed.
        # Adding user:--x here would OVERRIDE the other::r-x for that user.
        if is_browsable_dir "$parent"; then
            continue
        fi
        echo "  traverse  $user  $parent"
        if [[ "$DRY_RUN" == false ]]; then
            setfacl -m "u:${user}:--x" "$parent"
        fi
    done
}

extract_triples() {
    local file="$1" is_lock="${2:-false}"
    jq -r --arg lock "$is_lock" '
        if $lock == "true" then .users else . end |
        to_entries[] |
        .key as $u |
        ((.value.rw // [])[] | "\($u)\t\(.)\trw"),
        ((.value.ro // [])[] | "\($u)\t\(.)\tro")
    ' "$file" 2>/dev/null | grep -v '^$' | sort -u
}

# =========================================================================== #
# Phase 0: Lock down all base directories — owner-only, no group/other
# =========================================================================== #

echo "=== Lock down base directories ==="

for basedir in $BASE_DIRS; do
    [[ -d "$basedir" ]] || continue

    if is_browsable_dir "$basedir"; then
        # Browsable: everyone can list first-level dirs and enter the base dir.
        # Subdirectories remain locked — only ACL-granted users can access them.
        if [[ "$DRY_RUN" == false ]]; then
            chmod o+rx "$basedir"
            setfacl -m "g::r-x" "$basedir" 2>/dev/null || true
            # Remove any stale named user ACL entries from browsable base dir.
            while IFS= read -r acl_user; do
                [[ -n "$acl_user" ]] || continue
                setfacl -x "u:${acl_user}" "$basedir" 2>/dev/null || true
            done < <(getfacl -p "$basedir" 2>/dev/null | grep "^user:" | cut -d: -f2 | grep -v "^$")
            # Lock down files directly in the browsable base dir (prevent download)
            find "$basedir" -maxdepth 1 -type f -exec chmod o-rwx {} \;
        fi
        echo "  $basedir → browsable (o+rx + g::r-x on base, named users cleaned, files+subdirs locked)"
    else
        # Locked: remove group + other access entirely
        if [[ "$DRY_RUN" == false ]]; then
            chmod o-rx "$basedir"
            setfacl -m "g::---" "$basedir" 2>/dev/null || true
        fi
        echo "  $basedir → owner-only (removed group + other)"
    fi

    if [[ "$MODE" == "incremental" ]]; then
        LOCKED_JSON=$(jq -r '.locked_dirs // [] | .[]' "$LOCK" 2>/dev/null || true)
        declare -A LOCKED_MAP=()
        while IFS= read -r d; do
            [[ -n "$d" ]] && LOCKED_MAP["$d"]=1
        done <<< "$LOCKED_JSON"

        for sub in "$basedir"/*/; do
            sub="${sub%/}"
            [[ -d "$sub" ]] || continue
            if [[ -z "${LOCKED_MAP[$sub]+_}" ]]; then
                echo "  lock down  $sub  (new)"
                if [[ "$DRY_RUN" == false ]]; then
                    chmod -R o-rx "$sub"
                fi
            fi
        done
        unset LOCKED_MAP
    else
        for sub in "$basedir"/*/; do
            sub="${sub%/}"
            [[ -d "$sub" ]] || continue
            if [[ "$DRY_RUN" == false ]]; then
                chmod -R o-rx "$sub"
            fi
        done
    fi

done
echo ""

# =========================================================================== #
# Phase 1-2: ACL changes
# =========================================================================== #

if [[ "$MODE" == "full" ]]; then
    # ---- Full mode: revoke stale + apply all ----

    scan_paths() {
        for basedir in $BASE_DIRS; do
            [[ -d "$basedir" ]] || continue
            echo "$basedir"
            for sub in "$basedir"/*/; do
                sub="${sub%/}"
                [[ -d "$sub" ]] && echo "$sub"
            done
        done
    }

    SCAN_LIST=$(scan_paths)
    USERS=$(jq -r 'keys[]' "$CONFIG")

    for user in $USERS; do
        if ! id "$user" &>/dev/null; then
            echo "Warning: user '$user' does not exist, skipping." >&2
            continue
        fi
        home_dir=$(eval echo "~$user")
        echo "=== $user ==="

        declare -A GRANTED=()
        for p in $(jq -r --arg u "$user" '[(.[$u].rw // []), (.[$u].ro // [])] | flatten | .[]' "$CONFIG"); do
            GRANTED["$p"]=1
        done

        echo "  [revoke] checking stale ACL entries..."
        while IFS= read -r path; do
            [[ "$path" == "$home_dir" ]] && continue
            [[ -n "${GRANTED[$path]+_}" ]] && continue
            if getfacl -p "$path" 2>/dev/null | grep -q "^user:${user}:"; then
                echo "  revoke  $path"
                if [[ "$DRY_RUN" == false ]]; then
                    setfacl -R -x "u:${user}" "$path" 2>/dev/null || true
                    setfacl -R -d -x "u:${user}" "$path" 2>/dev/null || true
                fi
            fi
        done <<< "$SCAN_LIST"

        for path in $(jq -r --arg u "$user" '.[$u].rw // [] | .[]' "$CONFIG"); do
            apply_rw "$user" "$path"
        done

        for path in $(jq -r --arg u "$user" '.[$u].ro // [] | .[]' "$CONFIG"); do
            apply_ro "$user" "$path"
        done

        for path in $(jq -r --arg u "$user" '[(.[$u].rw // []), (.[$u].ro // [])] | flatten | .[]' "$CONFIG"); do
            set_traverse "$user" "$path"
        done

        unset GRANTED
        echo ""
    done

else
    # ---- Incremental mode: diff-based update ----

    OLD_TRIPLES=$(extract_triples "$LOCK" "true")
    NEW_TRIPLES=$(extract_triples "$CONFIG" "false")

    REMOVED=$(comm -23 <(printf '%s\n' "$OLD_TRIPLES" | grep .) <(printf '%s\n' "$NEW_TRIPLES" | grep .) 2>/dev/null | grep . || true)
    ADDED=$(comm -13 <(printf '%s\n' "$OLD_TRIPLES" | grep .) <(printf '%s\n' "$NEW_TRIPLES" | grep .) 2>/dev/null | grep . || true)

    if [[ -z "$REMOVED" && -z "$ADDED" ]]; then
        echo "No ACL changes detected (same paths, same types)."
    fi

    # --- Revoke removed paths ---
    if [[ -n "$REMOVED" ]]; then
        echo "=== Revocations ==="
        while IFS=$'\t' read -r user path type; do
            if ! id "$user" &>/dev/null; then
                echo "  Warning: user '$user' no longer exists." >&2
            fi
            revoke_path "$user" "$path"
        done <<< "$REMOVED"

        # Revoke traverse for fully-removed users
        declare -A TRAVERSE_REVOKED=()
        echo ""
        echo "=== Traverse cleanup ==="
        while IFS=$'\t' read -r user path type; do
            if jq -e --arg u "$user" 'has($u)' "$CONFIG" &>/dev/null; then
                continue
            fi
            [[ -n "${TRAVERSE_REVOKED[$user]+_}" ]] && continue
            TRAVERSE_REVOKED["$user"]=1
            echo "  remove traverse for removed user: $user"
            if [[ "$DRY_RUN" == false ]]; then
                for p in $(jq -r --arg u "$user" '[(.users[$u].rw // []), (.users[$u].ro // [])] | flatten | .[]' "$LOCK"); do
                    parent="$p"
                    while true; do
                        parent="$(dirname "$parent")"
                        [[ "$parent" == "/" || "$parent" == "/home" ]] && break
                        setfacl -x "u:${user}" "$parent" 2>/dev/null || true
                    done
                done
            fi
        done <<< "$REMOVED"
        unset TRAVERSE_REVOKED
        echo ""
    fi

    # --- Apply new/changed paths ---
    if [[ -n "$ADDED" ]]; then
        echo "=== New permissions ==="
        while IFS=$'\t' read -r user path type; do
            if ! id "$user" &>/dev/null; then
                echo "  Warning: user '$user' does not exist, skipping." >&2
                continue
            fi
            case "$type" in
                rw) apply_rw "$user" "$path" ;;
                ro) apply_ro "$user" "$path" ;;
            esac
        done <<< "$ADDED"
        echo ""
    fi

    # --- Ensure traverse for all current users ---
    echo "=== Traverse check ==="
    USERS=$(jq -r 'keys[]' "$CONFIG")
    for user in $USERS; do
        if ! id "$user" &>/dev/null; then continue; fi
        for path in $(jq -r --arg u "$user" '[(.[$u].rw // []), (.[$u].ro // [])] | flatten | .[]' "$CONFIG"); do
            set_traverse "$user" "$path"
        done
    done
    echo ""
fi

# =========================================================================== #
# Update lock file
# =========================================================================== #

if [[ "$DRY_RUN" == false ]]; then
    ALL_LOCKED=""
    for basedir in $BASE_DIRS; do
        while IFS= read -r d; do
            [[ -n "$d" ]] && ALL_LOCKED+="${d}"$'\n'
        done < <(ls -1d "$basedir"/*/ 2>/dev/null | sed 's:/$::')
    done
    LOCKED_DIRS_JSON=$(printf '%s' "$ALL_LOCKED" | grep -v '^$' | sort -u | jq -R . | jq -s . 2>/dev/null || echo "[]")

    jq -n \
        --arg hash "$CURRENT_HASH" \
        --argjson dirs "$LOCKED_DIRS_JSON" \
        --slurpfile perms "$CONFIG" \
        '{version: 1, permissions_hash: $hash, locked_dirs: $dirs, users: $perms[0]}' \
        > "$TMP_LOCK" && mv -f "$TMP_LOCK" "$LOCK"

    echo "Lock file updated: $LOCK"
fi

if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] Re-run without --dry-run to apply."
else
    echo "Done. ACLs synced to permissions.json."
fi
