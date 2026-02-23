#!/bin/bash
# Post-commit hook: sync project/ to Dropbox after every commit
# Copy this to .git/hooks/post-commit and make executable (chmod +x)
#
# CONFIGURE THESE TWO PATHS:
REPO_PATH="[REPO_PATH]"       # e.g., C:/git/my-project
DROPBOX_PATH="[DROPBOX_PATH]" # e.g., C:/Users/you/Dropbox/shared-project

# Safety check
if [[ "$REPO_PATH" == *"["* ]] || [[ "$DROPBOX_PATH" == *"["* ]]; then
    echo "post-commit hook: paths not configured. Edit .git/hooks/post-commit."
    exit 0
fi

echo "Syncing project/ to Dropbox..."
rsync -av --delete \
    --exclude-from="$REPO_PATH/.syncignore" \
    "$REPO_PATH/project/" \
    "$DROPBOX_PATH/"

echo "Dropbox sync complete."
