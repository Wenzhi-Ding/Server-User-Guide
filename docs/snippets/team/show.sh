#!/usr/bin/env bash
# show.sh — Show a user's effective access on /home paths (excluding their own home)
# Usage: bash show.sh <username>
# Usage: bash show.sh              (shows all users in permissions.json)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/permissions.json"

if [[ ! -f "$CONFIG" ]]; then
    echo "Error: $CONFIG not found." >&2
    exit 1
fi

for cmd in jq getfacl; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is required." >&2
        exit 1
    fi
done

# ---- Color helpers -------------------------------------------------------- #
if [[ -t 1 ]]; then
    GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'
    CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
else
    GREEN=''; YELLOW=''; RED=''; CYAN=''; BOLD=''; RESET=''
fi

fmt_perm() {
    local perm="$1"
    if [[ "$perm" == *"w"* ]]; then
        echo -e "${GREEN}${perm}${RESET}"
    elif [[ "$perm" == *"r"* ]]; then
        echo -e "${YELLOW}${perm}${RESET}"
    else
        echo -e "${RED}${perm}${RESET}"
    fi
}

# ---- Core: get effective permissions for a user on a path ----------------- #
get_effective_perm() {
    local user="$1" path="$2"
    local perm
    # getfacl → find user-specific ACL entry → extract permission bits
    perm=$(getfacl -p "$path" 2>/dev/null | grep "^user:${user}:" | head -1 | cut -d: -f3)
    if [[ -n "$perm" ]]; then
        echo "$perm"
        return
    fi

    # Fall back to group membership check
    local gid owner_group
    owner_group=$(stat -c '%G' "$path" 2>/dev/null)
    if id -nG "$user" 2>/dev/null | tr ' ' '\n' | grep -qx "$owner_group"; then
        perm=$(getfacl -p "$path" 2>/dev/null | grep "^group::$" -A0 | head -1)
        perm=${perm##*:}
        if [[ -z "$perm" ]]; then
            perm=$(stat -c '%A' "$path" 2>/dev/null | cut -c5-7)
        fi
        echo "$perm"
        return
    fi

    # Fall back to 'other'
    perm=$(getfacl -p "$path" 2>/dev/null | grep "^other::" | head -1 | cut -d: -f3)
    echo "${perm:----}"
}

# ---- Display one user ---------------------------------------------------- #
show_user() {
    local user="$1"

    if ! id "$user" &>/dev/null; then
        echo -e "${RED}User '$user' does not exist.${RESET}" >&2
        return 1
    fi

    local home_dir
    home_dir=$(eval echo "~$user")

    echo -e "${BOLD}${CYAN}User: ${user}${RESET}"
    echo -e "${BOLD}${CYAN}$(printf '=%.0s' {1..60})${RESET}"

    # -- Section 1: Configured permissions (from JSON) ---------------------- #
    echo -e "\n${BOLD}Configured (permissions.json):${RESET}"

    local has_config=false

    local rw_paths
    rw_paths=$(jq -r --arg u "$user" '.[$u].rw // [] | .[]' "$CONFIG" 2>/dev/null)
    if [[ -n "$rw_paths" ]]; then
        has_config=true
        while IFS= read -r path; do
            local eff
            eff=$(get_effective_perm "$user" "$path")
            local status="✓"
            [[ "$eff" != *"w"* ]] && status="✗ (not applied)"
            echo -e "  rw  $path  →  effective: $(fmt_perm "$eff")  $status"
        done <<< "$rw_paths"
    fi

    local ro_paths
    ro_paths=$(jq -r --arg u "$user" '.[$u].ro // [] | .[]' "$CONFIG" 2>/dev/null)
    if [[ -n "$ro_paths" ]]; then
        has_config=true
        while IFS= read -r path; do
            local eff
            eff=$(get_effective_perm "$user" "$path")
            local status="✓"
            [[ "$eff" != *"r"* ]] && status="✗ (not applied)"
            echo -e "  ro  $path  →  effective: $(fmt_perm "$eff")  $status"
        done <<< "$ro_paths"
    fi

    if [[ "$has_config" == false ]]; then
        echo "  (no entries)"
    fi

    # -- Section 2: Scan all /home/* paths for any extra access ------------- #
    echo -e "\n${BOLD}All access under /home (excluding $home_dir):${RESET}"

    local found_any=false
    for entry in /home/*/; do
        entry="${entry%/}"
        [[ "$entry" == "$home_dir" ]] && continue

        local eff
        eff=$(get_effective_perm "$user" "$entry")
        [[ "$eff" == "---" ]] && continue

        found_any=true
        echo -e "  $(fmt_perm "$eff")  $entry"

        # Also scan one level deeper for browsable base dirs
        local base_dir
        base_dir=$(jq -r '
            [.[].rw // [], .[].ro // []] | flatten | .[] |
            split("/") | .[0:3] | join("/")
        ' "$CONFIG" | sort -u | head -1)
        if [[ "$entry" == "$base_dir" ]]; then
            for subentry in "$entry"/*/; do
                subentry="${subentry%/}"
                local sub_eff
                sub_eff=$(get_effective_perm "$user" "$subentry")
                [[ "$sub_eff" == "---" ]] && continue
                echo -e "    $(fmt_perm "$sub_eff")  $subentry"
            done
        fi
    done

    if [[ "$found_any" == false ]]; then
        echo "  (no access found)"
    fi

    echo ""
}

# ---- Main ---------------------------------------------------------------- #
if [[ $# -ge 1 ]]; then
    show_user "$1"
else
    USERS=$(jq -r 'keys[]' "$CONFIG")
    for user in $USERS; do
        show_user "$user"
    done
fi
