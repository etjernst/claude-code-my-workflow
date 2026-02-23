#!/bin/bash
# Pull infrastructure updates from the workflow template into a project repo
#
# Usage: bash /path/to/workflow-repo/templates/sync-from-workflow.sh
#    or: bash templates/sync-from-workflow.sh /path/to/workflow-repo
#
# Run from your project repo. Copies only generic infrastructure files---never
# touches project-specific files (CLAUDE.md, MEMORY.md, project/, settings.json, etc.)
#
# After running, review the diff and commit what you want.

set -e

# If called with an argument, use that as the workflow repo path.
# Otherwise, infer it from the script's own location.
if [[ -n "$1" ]]; then
    WORKFLOW_REPO="$1"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    WORKFLOW_REPO="$(dirname "$SCRIPT_DIR")"
fi

PROJECT_REPO="$(pwd)"

if [[ ! -f "$WORKFLOW_REPO/CLAUDE.md" ]]; then
    echo "Error: $WORKFLOW_REPO does not look like a workflow repo (no CLAUDE.md)."
    exit 1
fi

if [[ "$PROJECT_REPO" == "$WORKFLOW_REPO" ]]; then
    echo "Error: you're already in the workflow repo. Run this from your project repo."
    exit 1
fi

echo "=== Pull infrastructure from workflow template ==="
echo "  From: $WORKFLOW_REPO"
echo "  To:   $PROJECT_REPO"
echo ""

# Infrastructure directories (recursive copy, overwrite)
DIRS=(
    ".claude/agents"
    ".claude/rules"
    ".claude/skills"
    ".claude/hooks"
    "templates"
    "preambles"
)

for dir in "${DIRS[@]}"; do
    if [[ -d "$WORKFLOW_REPO/$dir" ]]; then
        echo "Syncing $dir/"
        mkdir -p "$PROJECT_REPO/$dir"
        rsync -av --delete \
            --exclude="__pycache__" \
            --exclude="*.pyc" \
            "$WORKFLOW_REPO/$dir/" "$PROJECT_REPO/$dir/"
    fi
done

# Individual infrastructure files
FILES=(
    ".claude/WORKFLOW_QUICK_REF.md"
    "scripts/quality_score.py"
    ".syncignore"
    ".gitignore"
)

for file in "${FILES[@]}"; do
    if [[ -f "$WORKFLOW_REPO/$file" ]]; then
        echo "Syncing $file"
        mkdir -p "$(dirname "$PROJECT_REPO/$file")"
        cp "$WORKFLOW_REPO/$file" "$PROJECT_REPO/$file"
    fi
done

echo ""
echo "=== Sync complete ==="
echo ""
echo "Skipped (project-specific, not overwritten):"
echo "  CLAUDE.md, MEMORY.md, README.md, bibliography.bib"
echo "  project/, quality_reports/, explorations/, slides/, figures/"
echo "  .claude/settings.json, scripts/python/, scripts/stata/"
echo ""
echo "Next steps:"
echo "  git diff                # review changes"
echo "  git add -p              # stage what you want"
echo "  git commit"
