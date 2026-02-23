#!/bin/bash
# One-time setup: wire Dropbox sync for this project
#
# Usage: bash templates/setup-sync.sh
#
# What this does:
#   1. Asks for your repo path and Dropbox path
#   2. Installs the post-commit hook (auto-pushes project/ to Dropbox on every commit)
#   3. Creates sync-from-dropbox.sh at repo root (manually pull collaborator changes)

set -e

echo "=== Dropbox sync setup ==="
echo ""

# Get paths from user
read -rp "Repo path (e.g., C:/git/my-project): " REPO_PATH
read -rp "Dropbox path (e.g., C:/Users/you/Dropbox/shared-project): " DROPBOX_PATH

# Validate
if [[ -z "$REPO_PATH" ]] || [[ -z "$DROPBOX_PATH" ]]; then
    echo "Error: both paths are required."
    exit 1
fi

if [[ ! -d "$REPO_PATH/.git" ]]; then
    echo "Error: $REPO_PATH does not appear to be a git repository."
    exit 1
fi

# 1. Install post-commit hook
echo ""
echo "Installing post-commit hook..."
HOOK_FILE="$REPO_PATH/.git/hooks/post-commit"

if [[ -f "$HOOK_FILE" ]]; then
    echo "Warning: $HOOK_FILE already exists. Backing up to post-commit.bak"
    cp "$HOOK_FILE" "$HOOK_FILE.bak"
fi

sed -e "s|\[REPO_PATH\]|$REPO_PATH|g" \
    -e "s|\[DROPBOX_PATH\]|$DROPBOX_PATH|g" \
    "$REPO_PATH/templates/post-commit-hook.sh" > "$HOOK_FILE"
chmod +x "$HOOK_FILE"
echo "  Created $HOOK_FILE"

# 2. Create sync-from-dropbox.sh at repo root
echo "Creating sync-from-dropbox.sh..."
SYNC_FILE="$REPO_PATH/sync-from-dropbox.sh"

sed -e "s|\[REPO_PATH\]|$REPO_PATH|g" \
    -e "s|\[DROPBOX_PATH\]|$DROPBOX_PATH|g" \
    "$REPO_PATH/templates/sync-from-dropbox.sh" > "$SYNC_FILE"
chmod +x "$SYNC_FILE"
echo "  Created $SYNC_FILE"

echo ""
echo "=== Setup complete ==="
echo ""
echo "How it works:"
echo "  - Every 'git commit' now rsyncs project/ to Dropbox automatically"
echo "  - Run 'bash sync-from-dropbox.sh' to pull collaborator changes before starting work"
echo "  - .syncignore controls what gets excluded from sync"
echo ""
echo "Configured paths:"
echo "  Repo:    $REPO_PATH"
echo "  Dropbox: $DROPBOX_PATH"
