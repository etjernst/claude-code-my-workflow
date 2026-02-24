#!/bin/bash
# Sync infrastructure improvements from a project repo back to the workflow template
#
# Usage: bash templates/sync-to-workflow.sh /path/to/workflow-repo
#
# Run from your project repo. Copies only generic infrastructure files---skips
# anything project-specific (CLAUDE.md, MEMORY.md, project/, settings.json, etc.)
#
# After running, cd into the workflow repo, review the diff, and commit what you want.

set -e

WORKFLOW_REPO="$1"

if [[ -z "$WORKFLOW_REPO" ]]; then
    echo "Usage: bash templates/sync-to-workflow.sh /path/to/workflow-repo"
    echo ""
    echo "Run from your project repo root."
    exit 1
fi

if [[ ! -f "$WORKFLOW_REPO/CLAUDE.md" ]]; then
    echo "Error: $WORKFLOW_REPO does not look like a workflow repo (no CLAUDE.md)."
    exit 1
fi

PROJECT_REPO="$(pwd)"

echo "=== Sync infrastructure to workflow template ==="
echo "  From: $PROJECT_REPO"
echo "  To:   $WORKFLOW_REPO"
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
    if [[ -d "$PROJECT_REPO/$dir" ]]; then
        echo "Syncing $dir/"
        rsync -av --delete \
            --exclude="__pycache__" \
            --exclude="*.pyc" \
            "$PROJECT_REPO/$dir/" "$WORKFLOW_REPO/$dir/"
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
    if [[ -f "$PROJECT_REPO/$file" ]]; then
        echo "Syncing $file"
        cp "$PROJECT_REPO/$file" "$WORKFLOW_REPO/$file"
    fi
done

echo ""
echo "=== Sync complete ==="
echo ""
echo "Skipped (project-specific):"
echo "  CLAUDE.md, MEMORY.md, README.md, bibliography.bib"
echo "  project/, quality_reports/, explorations/, slides/, figures/"
echo "  .claude/settings.json, scripts/python/, scripts/stata/"
echo ""
echo "Next steps:"
echo "  cd $WORKFLOW_REPO"
echo "  git diff                # review changes"
echo "  git add -p              # stage what you want"
echo "  git commit"
