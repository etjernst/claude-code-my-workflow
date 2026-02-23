#!/bin/bash
# Post-commit hook: sync project/ to Dropbox after every commit
# Installed by templates/setup-sync.sh
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

if command -v rsync &>/dev/null; then
    rsync -av --delete \
        --exclude-from="$REPO_PATH/.syncignore" \
        "$REPO_PATH/project/" \
        "$DROPBOX_PATH/"
else
    # Windows fallback: use Python shutil (mirror with delete)
    python -c "
import shutil, os, fnmatch

src = os.path.join(r'''$REPO_PATH''', 'project')
dst = r'''$DROPBOX_PATH'''

# Read .syncignore patterns
ignore_patterns = []
syncignore = os.path.join(r'''$REPO_PATH''', '.syncignore')
if os.path.exists(syncignore):
    with open(syncignore) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                ignore_patterns.append(line)

def should_ignore(name, relpath):
    for pat in ignore_patterns:
        pat = pat.rstrip('/')
        if fnmatch.fnmatch(name, pat) or fnmatch.fnmatch(relpath, pat):
            return True
    return False

copied = 0
for root, dirs, files in os.walk(src):
    rel = os.path.relpath(root, src)
    if rel == '.':
        rel = ''
    dirs[:] = [d for d in dirs if not should_ignore(d, os.path.join(rel, d) if rel else d)]
    for f in files:
        rel_file = os.path.join(rel, f) if rel else f
        if should_ignore(f, rel_file):
            continue
        src_file = os.path.join(root, f)
        dst_file = os.path.join(dst, rel_file)
        dst_dir = os.path.dirname(dst_file)
        os.makedirs(dst_dir, exist_ok=True)
        if not os.path.exists(dst_file) or os.path.getmtime(src_file) > os.path.getmtime(dst_file):
            shutil.copy2(src_file, dst_file)
            copied += 1
print(f'Copied {copied} files from project/ to Dropbox')
"
fi

echo "Dropbox sync complete."
