#!/bin/bash
# Integration test for Dropbox sync safety
#
# Verifies that robocopy /E /XO (copy newer, never delete) behaves correctly
# in both push and pull directions. Uses a real Dropbox folder with isolated
# test subfolders that are cleaned up automatically.
#
# Prerequisites:
#   - Git Bash on Windows (robocopy.exe, cygpath available)
#   - Dropbox folder at the path below with CoE.pdf, Page-1.pdf, Page-2.pdf
#
# Usage: bash tests/test_sync_safety.sh

set -u

# --- Configuration ---
DROPBOX_BASE="C:/Users/maand/Dropbox (Personal)/.Fuckhead/AIGrants"
DROPBOX_PUSH="$DROPBOX_BASE/_test_push"
DROPBOX_PULL="$DROPBOX_BASE/_test_pull"
LOCAL_DIR=""
PASS=0
FAIL=0
TOTAL=0

# --- Helpers ---

to_win() { cygpath -w "$1"; }

run_robocopy() {
    MSYS_NO_PATHCONV=1 robocopy.exe "$@" > /dev/null 2>&1
    local rc=$?
    if [[ $rc -ge 8 ]]; then
        echo "    robocopy error (exit $rc)"
        return 1
    fi
    return 0
}

# Exclusion flags (identical to templates/setup-sync.sh lines 174-182)
EXCLUDE_DIRS=("__pycache__" ".git")
EXCLUDE_FILES=(".env" "Thumbs.db" ".DS_Store")
EXCLUDE_EXTS=("*.pyc" "*.aux" "*.log" "*.bbl" "*.blg" "*.synctex.gz" \
              "*.nav" "*.out" "*.snm" "*.toc" "*.vrb")

XD_FLAGS=()
for d in "${EXCLUDE_DIRS[@]}"; do XD_FLAGS+=("$d"); done
XF_FLAGS=()
for f in "${EXCLUDE_FILES[@]}"; do XF_FLAGS+=("$f"); done
for e in "${EXCLUDE_EXTS[@]}"; do XF_FLAGS+=("$e"); done

pass() {
    TOTAL=$((TOTAL + 1))
    PASS=$((PASS + 1))
    echo "  PASS  $1"
}

fail() {
    TOTAL=$((TOTAL + 1))
    FAIL=$((FAIL + 1))
    echo "  FAIL  $1"
}

assert_exists() {
    if [[ -f "$1" ]]; then pass "$2"; else fail "$2 -- not found: $1"; fi
}

assert_not_exists() {
    if [[ ! -f "$1" && ! -d "$1" ]]; then pass "$2"; else fail "$2 -- exists: $1"; fi
}

assert_content() {
    if [[ -f "$1" ]] && grep -qF "$2" "$1" 2>/dev/null; then
        pass "$3"
    else
        fail "$3"
    fi
}

assert_output_contains() {
    if echo "$1" | grep -qF "$2" 2>/dev/null; then
        pass "$3"
    else
        fail "$3 -- expected '$2' in output"
    fi
}

assert_output_nonempty() {
    if [[ -n "$1" ]]; then pass "$2"; else fail "$2 -- output was empty"; fi
}

# --- Push command (same flags as post-commit hook, setup-sync.sh line 203) ---
push_sync() {
    local src dst
    src=$(to_win "$1")
    dst=$(to_win "$2")
    run_robocopy "$src" "$dst" /E /XO /XJ /NJH /NJS /NDL /NP \
        /XD "${XD_FLAGS[@]}" /XF "${XF_FLAGS[@]}"
}

# --- Pull command (same flags as sync-pull.sh, setup-sync.sh line 295) ---
pull_sync() {
    local src dst
    src=$(to_win "$1")
    dst=$(to_win "$2")
    run_robocopy "$src" "$dst" /E /XO /XJ /NJH /NJS /NDL /NP \
        /XD "${XD_FLAGS[@]}" /XF "${XF_FLAGS[@]}"
}

# --- Setup / Teardown ---

setup() {
    echo "=== Setup ==="

    if [[ ! -d "$DROPBOX_BASE" ]]; then
        echo "ERROR: Dropbox folder not found: $DROPBOX_BASE"
        exit 2
    fi

    for f in CoE.pdf Page-1.pdf Page-2.pdf; do
        if [[ ! -f "$DROPBOX_BASE/$f" ]]; then
            echo "ERROR: Expected file missing: $DROPBOX_BASE/$f"
            exit 2
        fi
    done

    LOCAL_DIR=$(mktemp -d)
    mkdir -p "$DROPBOX_PUSH" "$DROPBOX_PULL"

    # Seed push target with copies of the real PDFs (simulate Dropbox-only files)
    cp "$DROPBOX_BASE/CoE.pdf"    "$DROPBOX_PUSH/"
    cp "$DROPBOX_BASE/Page-1.pdf" "$DROPBOX_PUSH/"
    cp "$DROPBOX_BASE/Page-2.pdf" "$DROPBOX_PUSH/"

    # Seed pull source with test files
    echo "pull-content-1" > "$DROPBOX_PULL/pull-file-1.txt"
    echo "pull-content-2" > "$DROPBOX_PULL/pull-file-2.txt"

    echo "  Local:  $LOCAL_DIR"
    echo "  Push:   $DROPBOX_PUSH"
    echo "  Pull:   $DROPBOX_PULL"
    echo ""
}

cleanup() {
    echo ""
    echo "=== Cleanup ==="
    # Dropbox may hold file locks briefly; retry once after a short pause.
    for dir in "$DROPBOX_PUSH" "$DROPBOX_PULL"; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir" 2>/dev/null || { sleep 2; rm -rf "$dir" 2>/dev/null; }
            if [[ -d "$dir" ]]; then
                echo "  WARNING: could not fully remove $dir (Dropbox lock?)"
            else
                echo "  Removed ${dir##*/}"
            fi
        fi
    done
    if [[ -n "${LOCAL_DIR:-}" && -d "$LOCAL_DIR" ]]; then
        rm -rf "$LOCAL_DIR" 2>/dev/null
        echo "  Removed $LOCAL_DIR"
    fi
}
trap cleanup EXIT

# =========================================================================
#  GROUP A: Push safety (the critical fix)
# =========================================================================

test_1_push_no_delete() {
    echo "Test 1: Push does NOT delete Dropbox-only files"

    mkdir -p "$LOCAL_DIR/push_project"
    echo "local only" > "$LOCAL_DIR/push_project/local-only.txt"

    push_sync "$LOCAL_DIR/push_project" "$DROPBOX_PUSH"

    assert_exists "$DROPBOX_PUSH/CoE.pdf"       "CoE.pdf survives push"
    assert_exists "$DROPBOX_PUSH/Page-1.pdf"    "Page-1.pdf survives push"
    assert_exists "$DROPBOX_PUSH/Page-2.pdf"    "Page-2.pdf survives push"
    assert_exists "$DROPBOX_PUSH/local-only.txt" "local-only.txt pushed to Dropbox"
}

test_2_push_copies_newer() {
    echo "Test 2: Push copies newer local files"

    echo "test-push-content" > "$LOCAL_DIR/push_project/test-push.txt"

    push_sync "$LOCAL_DIR/push_project" "$DROPBOX_PUSH"

    assert_exists  "$DROPBOX_PUSH/test-push.txt" "test-push.txt copied to Dropbox"
    assert_content "$DROPBOX_PUSH/test-push.txt" "test-push-content" \
                   "test-push.txt has correct content"
}

test_3_push_skips_older() {
    echo "Test 3: Push skips older local files (/XO)"

    # Make the Dropbox copy newer
    sleep 2
    echo "dropbox-modified" > "$DROPBOX_PUSH/test-push.txt"

    # Push again -- local copy is now older
    push_sync "$LOCAL_DIR/push_project" "$DROPBOX_PUSH"

    assert_content "$DROPBOX_PUSH/test-push.txt" "dropbox-modified" \
                   "Dropbox newer version preserved"
}

test_4_detect_newer() {
    echo "Test 4: detect_newer warns about Dropbox-side changes"

    # Dropbox has a newer test-push.txt from test 3
    local src dst output
    src=$(to_win "$DROPBOX_PUSH")
    dst=$(to_win "$LOCAL_DIR/push_project")

    # Replicate detect_newer logic (setup-sync.sh detect_newer function)
    output=$(MSYS_NO_PATHCONV=1 robocopy.exe "$src" "$dst" \
        /E /XO /L /NDL /NJH /NJS /NP /NC /NS \
        /XD "${XD_FLAGS[@]}" /XF "${XF_FLAGS[@]}" 2>/dev/null \
        | sed 's/^[[:space:]]*//' | sed '/^$/d') || true

    assert_output_contains "$output" "test-push.txt" \
        "detect_newer identifies newer Dropbox file"
}

# =========================================================================
#  GROUP B: Pull safety
# =========================================================================

test_5_pull_no_delete() {
    echo "Test 5: Pull does NOT delete local-only files"

    mkdir -p "$LOCAL_DIR/pull_project"
    echo "secret data" > "$LOCAL_DIR/pull_project/local-secret.txt"

    pull_sync "$DROPBOX_PULL" "$LOCAL_DIR/pull_project"

    assert_exists "$LOCAL_DIR/pull_project/local-secret.txt" \
                  "local-secret.txt survives pull"
}

test_6_pull_copies_newer() {
    echo "Test 6: Pull copies newer Dropbox files"

    pull_sync "$DROPBOX_PULL" "$LOCAL_DIR/pull_project"

    assert_exists  "$LOCAL_DIR/pull_project/pull-file-1.txt" \
                   "pull-file-1.txt pulled from Dropbox"
    assert_content "$LOCAL_DIR/pull_project/pull-file-1.txt" "pull-content-1" \
                   "pull-file-1.txt has correct content"
}

test_7_pull_skips_older() {
    echo "Test 7: Pull skips older Dropbox files (/XO)"

    # Make local copy newer
    sleep 2
    echo "local-modified" > "$LOCAL_DIR/pull_project/pull-file-1.txt"

    # Pull again -- Dropbox source is now older
    pull_sync "$DROPBOX_PULL" "$LOCAL_DIR/pull_project"

    assert_content "$LOCAL_DIR/pull_project/pull-file-1.txt" "local-modified" \
                   "Local newer version preserved"
}

test_8_preview_pull() {
    echo "Test 8: preview_pull shows correct output"

    # Fresh local dir -- both pull files should need pulling
    mkdir -p "$LOCAL_DIR/preview_project"

    local src dst output
    src=$(to_win "$DROPBOX_PULL")
    dst=$(to_win "$LOCAL_DIR/preview_project")

    # Replicate preview_pull logic (setup-sync.sh preview_pull function)
    output=$(MSYS_NO_PATHCONV=1 robocopy.exe "$src" "$dst" \
        /E /XO /L /NDL /NJH /NJS /NP /NC /NS \
        /XD "${XD_FLAGS[@]}" /XF "${XF_FLAGS[@]}" 2>/dev/null \
        | sed 's/^[[:space:]]*//' | sed '/^$/d') || true

    assert_output_nonempty "$output" "preview_pull reports files to pull"
}

# =========================================================================
#  GROUP C: Exclusion filters
# =========================================================================

test_9_push_excludes_artifacts() {
    echo "Test 9: Push excludes artifact files"

    mkdir -p "$LOCAL_DIR/push_project/__pycache__"
    echo "cached"     > "$LOCAL_DIR/push_project/__pycache__/cache.pyc"
    echo "SECRET=key" > "$LOCAL_DIR/push_project/.env"

    push_sync "$LOCAL_DIR/push_project" "$DROPBOX_PUSH"

    assert_not_exists "$DROPBOX_PUSH/__pycache__" \
                      "__pycache__ dir excluded from push"
    assert_not_exists "$DROPBOX_PUSH/.env" \
                      ".env excluded from push"
}

test_10_pull_excludes_artifacts() {
    echo "Test 10: Pull excludes artifact files"

    mkdir -p "$DROPBOX_PULL/__pycache__"
    echo "cached" > "$DROPBOX_PULL/__pycache__/cache.pyc"

    mkdir -p "$LOCAL_DIR/pull_excl_project"

    pull_sync "$DROPBOX_PULL" "$LOCAL_DIR/pull_excl_project"

    assert_not_exists "$LOCAL_DIR/pull_excl_project/__pycache__" \
                      "__pycache__ dir excluded from pull"
}

# --- Run all tests ---

setup

echo "=== Group A: Push safety ==="
test_1_push_no_delete
echo ""
test_2_push_copies_newer
echo ""
test_3_push_skips_older
echo ""
test_4_detect_newer
echo ""

echo "=== Group B: Pull safety ==="
test_5_pull_no_delete
echo ""
test_6_pull_copies_newer
echo ""
test_7_pull_skips_older
echo ""
test_8_preview_pull
echo ""

echo "=== Group C: Exclusion filters ==="
test_9_push_excludes_artifacts
echo ""
test_10_pull_excludes_artifacts
echo ""

echo "=== Results ==="
echo "$PASS/$TOTAL passed"
if [[ $FAIL -gt 0 ]]; then
    echo "$FAIL FAILED"
    exit 1
else
    echo "All tests passed."
    exit 0
fi
