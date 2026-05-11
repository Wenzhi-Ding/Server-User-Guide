#!/usr/bin/env bash
# test.sh — Verify ACL permission boundaries match permissions.json (Efficient Edition)
#
# Usage: sudo bash test.sh
#
# For each user in permissions.json, tests:
#   1. ro positive:  read a ro-authorized path (ls + file read)
#   2. rw positive:  create+read+delete temp file in a rw-authorized path
#   3. system deny:  cannot access system dirs (/etc, /root, /usr, /var)
#   4. home isolation: cannot access another user's home dir (/home/<user>)
#   5. unauthorized data: cannot access real paths not in permissions.json
#   6. base dir traversal: locked dirs (cd-only, no ls) / browsable dirs (everyone can ls)
#   7. browsable isolation: can list browsable base dir but cannot access unauthorized subdirs
#
# Strategy: Random sampling for efficiency, but guarantees critical boundary tests.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/permissions.json"
TIMESTAMP=$(date +%s)
TMPFILE=".acl_test_${TIMESTAMP}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

TOTAL=0
PASSED=0
FAILED=0

SYSTEM_DIRS=("/etc" "/root" "/usr" "/var")

# Base dirs where everyone can list first-level contents (must match apply.sh)
BROWSABLE_BASE_DIRS=("/home/shared")

is_browsable_dir() {
    local dir="$1"
    for bd in "${BROWSABLE_BASE_DIRS[@]}"; do
        [[ "$dir" == "$bd" ]] && return 0
    done
    return 1
}

if [[ ! -f "$CONFIG" ]]; then
    echo "Error: $CONFIG not found." >&2; exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "Error: run with sudo." >&2; exit 1
fi

for cmd in jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is required." >&2; exit 1
    fi
done

pass() {
    echo -e "  ${GREEN}PASS${RESET}  $1"
    ((PASSED++)) || true
    ((TOTAL++)) || true
}

fail() {
    echo -e "  ${RED}FAIL${RESET}  $1"
    ((FAILED++)) || true
    ((TOTAL++)) || true
}

skip() {
    echo -e "  ${YELLOW}SKIP${RESET}  $1"
    ((TOTAL++)) || true
}

as_user() {
    local user="$1"; shift
    sudo -u "$user" "$@" 2>/dev/null
}

user_all_paths() {
    local user="$1"
    jq -r --arg u "$user" '
        [(.[$u].rw // []), (.[$u].ro // [])] | flatten | .[]
    ' "$CONFIG"
}

user_rw_paths() {
    local user="$1"
    jq -r --arg u "$user" '.[$u].rw // [] | .[]' "$CONFIG"
}

user_ro_paths() {
    local user="$1"
    jq -r --arg u "$user" '.[$u].ro // [] | .[]' "$CONFIG"
}

# Get all authorized paths from config (flattened)
all_authorized_paths() {
    jq -r '(.[].rw // []), (.[].ro // []) | .[]' "$CONFIG" | sort -u
}

# Discover real directories under base paths that are NOT in permissions.json
find_unauthorized_paths() {
    local user="$1"
    local all_auth all_subdirs unauthorized
    
    # Get all paths this user is authorized for
    all_auth=$(user_all_paths "$user" | sort -u)
    
    unauthorized=()
    
    # Check base dirs for real directories
    BASE_DIRS=$(jq -r '
        [.[].rw // [], .[].ro // []] | flatten | .[] |
        split("/") | .[0:3] | join("/")
    ' "$CONFIG" | sort -u)

    for base in $BASE_DIRS; do
        [[ -d "$base" ]] || continue
        
        # Find immediate subdirectories
        while IFS= read -r -d '' subdir; do
            local basename
            basename=$(basename "$subdir")
            local fullpath="$base/$basename"
            
            # Skip if user is authorized for this exact path or a parent
            local is_authorized=false
            while IFS= read -r auth_path; do
                [[ -z "$auth_path" ]] && continue
                if [[ "$fullpath" == "$auth_path" || "$fullpath" == "$auth_path"/* || "$auth_path" == "$fullpath"/* ]]; then
                    is_authorized=true
                    break
                fi
            done <<< "$all_auth"
            
            if [[ "$is_authorized" == false ]]; then
                unauthorized+=("$fullpath")
            fi
        done < <(find "$base" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)
    done
    
    printf '%s\n' "${unauthorized[@]}"
}

# --- Collect users ---
USERS=$(jq -r 'keys[]' "$CONFIG")

echo -e "${BOLD}=== ACL Permission Test ===${RESET}"
echo "Config: $CONFIG"
echo "Strategy: Random sampling for efficiency, critical paths guaranteed"
echo ""

for user in $USERS; do
    if ! id "$user" &>/dev/null; then
        echo -e "${YELLOW}SKIP${RESET}  user '$user' does not exist"
        echo ""
        continue
    fi

    echo -e "${BOLD}=== $user ===${RESET}"

    declare -A MY_PATHS=()
    while IFS= read -r p; do
        MY_PATHS["$p"]=1
    done < <(user_all_paths "$user")

    # ---- 1. RO positive: read a ro-authorized path ----
    RO_PATHS=()
    while IFS= read -r p; do
        [[ -n "$p" ]] && RO_PATHS+=("$p")
    done < <(user_ro_paths "$user")

    if [[ ${#RO_PATHS[@]} -gt 0 ]]; then
        target="${RO_PATHS[$((RANDOM % ${#RO_PATHS[@]}))]}"
        if [[ ! -e "$target" ]]; then
            skip "ro  read    $target  (path does not exist)"
        elif as_user "$user" ls "$target" &>/dev/null; then
            testfile=$(find "$target" -maxdepth 1 -type f -print -quit 2>/dev/null)
            if [[ -n "$testfile" ]] && as_user "$user" cat "$testfile" >/dev/null 2>&1; then
                pass "ro  read    $target  (dir ls + file read)"
            else
                pass "ro  read    $target  (dir ls, no testable file)"
            fi
        else
            fail "ro  read    $target  (should be readable)"
        fi
    else
        skip "ro  (no ro paths configured)"
    fi

    # ---- 2. RW positive: create+read+delete temp file ----
    RW_PATHS=()
    while IFS= read -r p; do
        [[ -n "$p" ]] && RW_PATHS+=("$p")
    done < <(user_rw_paths "$user")

    if [[ ${#RW_PATHS[@]} -gt 0 ]]; then
        target="${RW_PATHS[$((RANDOM % ${#RW_PATHS[@]}))]}"
        if [[ ! -e "$target" ]]; then
            skip "rw  write   $target  (path does not exist)"
        else
            rw_pass=true
            if ! as_user "$user" touch "$target/$TMPFILE" 2>/dev/null; then
                rw_pass=false
            fi
            if [[ "$rw_pass" == true ]] && ! as_user "$user" cat "$target/$TMPFILE" >/dev/null 2>&1; then
                rw_pass=false
            fi
            if [[ "$rw_pass" == true ]] && ! as_user "$user" rm -f "$target/$TMPFILE" 2>/dev/null; then
                rw_pass=false
            fi
            if [[ "$rw_pass" == false ]]; then
                as_user "$user" rm -f "$target/$TMPFILE" 2>/dev/null || true
                fail "rw  write   $target  (create/read/delete failed)"
            else
                pass "rw  write   $target  (create+read+delete)"
            fi
        fi
    else
        skip "rw  (no rw paths configured)"
    fi

    # ---- 3. System directory write denial ----
    for sysdir in "${SYSTEM_DIRS[@]}"; do
        if [[ ! -d "$sysdir" ]]; then
            skip "deny-write  $sysdir  (does not exist)"
            continue
        fi
        
        if [[ "$sysdir" == "/root" ]]; then
            if as_user "$user" ls "$sysdir" &>/dev/null; then
                fail "deny  $sysdir  (CRITICAL: /root should NEVER be accessible)"
            else
                pass "deny  $sysdir  (root dir blocked)"
            fi
        else
            if as_user "$user" touch "$sysdir/.acl_test_${TIMESTAMP}_${user}" 2>/dev/null; then
                rm -f "$sysdir/.acl_test_${TIMESTAMP}_${user}" 2>/dev/null || true
                fail "deny-write  $sysdir  (SYSTEM DIR — should NEVER be writable)"
            else
                pass "deny-write  $sysdir  (not writable)"
            fi
        fi
    done

    # ---- 4. Home isolation: cannot access another user's home ----
    OTHER_USERS=()
    for u in $USERS; do
        [[ "$u" != "$user" ]] && OTHER_USERS+=("$u")
    done
    
    if [[ ${#OTHER_USERS[@]} -gt 0 ]]; then
        shuffled=()
        while IFS= read -r -d '' u; do
            shuffled+=("$u")
        done < <(printf '%s\0' "${OTHER_USERS[@]}" | shuf -z 2>/dev/null || printf '%s\0' "${OTHER_USERS[@]}")
        
        test_count=0
        for other_u in "${shuffled[@]}"; do
            [[ $test_count -ge 2 ]] && break
            other_home="/home/$other_u"
            
            if [[ ! -d "$other_home" ]]; then
                skip "deny  $other_home  (dir does not exist)"
                ((test_count++)) || true
                continue
            fi
            
            owner=$(stat -c '%U' "$other_home" 2>/dev/null || echo "")
            if [[ "$owner" == "$user" ]]; then
                skip "deny  $other_home  ($user is owner)"
            elif as_user "$user" ls "$other_home" &>/dev/null; then
                fail "deny  $other_home  ($other_u home dir — should NEVER access)"
            else
                pass "deny  $other_home  ($other_u home dir blocked)"
            fi
            ((test_count++)) || true
        done
    fi

    # ---- 5. Unauthorized real paths: discover and test ----
    UNAUTH_PATHS=()
    while IFS= read -r p; do
        [[ -n "$p" ]] && UNAUTH_PATHS+=("$p")
    done < <(find_unauthorized_paths "$user")

    if [[ ${#UNAUTH_PATHS[@]} -gt 0 ]]; then
        shuffled_unauth=()
        while IFS= read -r -d '' p; do
            shuffled_unauth+=("$p")
        done < <(printf '%s\0' "${UNAUTH_PATHS[@]}" | shuf -z 2>/dev/null || printf '%s\0' "${UNAUTH_PATHS[@]}")
        
        test_count=0
        for target in "${shuffled_unauth[@]}"; do
            [[ $test_count -ge 2 ]] && break
            
            owner=$(stat -c '%U' "$target" 2>/dev/null || echo "")
            if [[ "$owner" == "$user" ]]; then
                skip "deny  $target  ($user is owner)"
            elif as_user "$user" ls "$target" &>/dev/null; then
                fail "deny  $target  (unauthorized path — should NOT access)"
            else
                pass "deny  $target  (unauthorized path blocked)"
            fi
            ((test_count++)) || true
        done
    else
        skip "deny  (no unauthorized real paths to test)"
    fi

    # ---- 6. Base dir traversal / browsability check ----
    BASE_DIRS=$(jq -r '
        [.[].rw // [], .[].ro // []] | flatten | .[] |
        split("/") | .[0:3] | join("/")
    ' "$CONFIG" | sort -u)

    for basedir in $BASE_DIRS; do
        [[ -d "$basedir" ]] || continue
        basedir_owner=$(stat -c '%U' "$basedir" 2>/dev/null || echo "")

        if [[ "$basedir_owner" == "$user" ]]; then
            skip "traverse  $basedir  ($user is owner)"
            continue
        fi

        if is_browsable_dir "$basedir"; then
            if as_user "$user" ls "$basedir" &>/dev/null; then
                pass "browsable  $basedir  (can list first-level dirs)"
            else
                fail "browsable  $basedir  (should be able to list first-level dirs)"
            fi
        else
            has_path_under=false
            while IFS= read -r p; do
                if [[ "$p" == "$basedir"/* ]]; then
                    has_path_under=true
                    break
                fi
            done < <(user_all_paths "$user")

            if [[ "$has_path_under" == true ]]; then
                if as_user "$user" test -x "$basedir" 2>/dev/null; then
                    if as_user "$user" ls "$basedir" &>/dev/null; then
                        fail "traverse  $basedir  (can list contents, should only traverse)"
                    else
                        pass "traverse  $basedir  (can cd through, cannot ls)"
                    fi
                else
                    fail "traverse  $basedir  (cannot even traverse)"
                fi
            else
                if as_user "$user" ls "$basedir" &>/dev/null; then
                    fail "deny  $basedir  (no paths under here, should NOT access)"
                else
                    pass "deny  $basedir  (no paths under here)"
                fi
            fi
        fi
    done

    # ---- 7. Browsable base dir: subdirectory isolation ----
    for browsable_dir in "${BROWSABLE_BASE_DIRS[@]}"; do
        [[ -d "$browsable_dir" ]] || continue

        unauth_subdirs=()
        while IFS= read -r -d '' subdir; do
            is_auth=false
            while IFS= read -r auth_path; do
                [[ -z "$auth_path" ]] && continue
                if [[ "$subdir" == "$auth_path" || "$subdir" == "$auth_path"/* || "$auth_path" == "$subdir"/* ]]; then
                    is_auth=true
                    break
                fi
            done < <(user_all_paths "$user")
            [[ "$is_auth" == false ]] && unauth_subdirs+=("$subdir")
        done < <(find "$browsable_dir" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)

        if [[ ${#unauth_subdirs[@]} -eq 0 ]]; then
            skip "isolation  $browsable_dir  (all first-level subdirs authorized)"
            continue
        fi

        test_count=0
        for subdir in "${unauth_subdirs[@]}"; do
            [[ $test_count -ge 2 ]] && break
            subdir_owner=$(stat -c '%U' "$subdir" 2>/dev/null || echo "")
            if [[ "$subdir_owner" == "$user" ]]; then
                skip "isolation  $subdir  ($user is owner)"
                ((test_count++)) || true
                continue
            elif as_user "$user" ls "$subdir" &>/dev/null; then
                fail "isolation  $subdir  (unauthorized — should NOT list)"
            else
                pass "isolation  $subdir  (unauthorized subdir blocked)"
            fi

            testfile=$(find "$subdir" -maxdepth 1 -type f -readable -print -quit 2>/dev/null)
            if [[ -n "$testfile" ]]; then
                if as_user "$user" cat "$testfile" >/dev/null 2>&1; then
                    fail "isolation  $testfile  (unauthorized file — should NOT read)"
                else
                    pass "isolation  $testfile  (unauthorized file blocked)"
                fi
            fi
            ((test_count++)) || true
        done

        # Verify files directly in browsable base dir cannot be downloaded
        while IFS= read -r -d '' basefile; do
            file_owner=$(stat -c '%U' "$basefile" 2>/dev/null || echo "")
            if [[ "$file_owner" == "$user" ]]; then
                skip "isolation  $basefile  ($user is owner)"
            elif as_user "$user" cat "$basefile" >/dev/null 2>&1; then
                fail "isolation  $basefile  (browsable-only file — should NOT download)"
            else
                pass "isolation  $basefile  (browsable-only file blocked)"
            fi
        done < <(find "$browsable_dir" -maxdepth 1 -type f -print0 2>/dev/null)
    done

    unset MY_PATHS
    echo ""
done

# --- Summary ---
echo -e "${BOLD}--- Results ---${RESET}"
echo -e "  Total: $TOTAL"
echo -e "  ${GREEN}Passed: $PASSED${RESET}"
if [[ "$FAILED" -gt 0 ]]; then
    echo -e "  ${RED}Failed: $FAILED${RESET}"
    exit 1
else
    echo -e "  ${GREEN}Failed: 0${RESET}"
fi
