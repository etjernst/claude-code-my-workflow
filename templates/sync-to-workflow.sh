#!/bin/bash
# Sync infrastructure improvements from a project repo back to the workflow template
#
# Usage: bash templates/sync-to-workflow.sh /path/to/workflow-repo
#
# Run from your project repo. Copies only generic infrastructure files---skips
# anything project-specific (CLAUDE.md, MEMORY.md, project/, settings.json, etc.)
#
# After running, cd into the workflow repo, review the diff, and commit what you want.
#
# Uses robocopy (built into Windows).

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

# Convert Git Bash path to Windows path for robocopy
to_win() { echo "$1" | sed 's|^/c/|C:/|; s|^/d/|D:/|; s|/|\\|g'; }

# robocopy exit codes 0-7 are success, 8+ are errors
run_robocopy() {
    robocopy.exe "$@"
    local rc=$?
    if [[ $rc -ge 8 ]]; then
        echo "  robocopy failed (exit code $rc)"
        return 1
    fi
    return 0
}

echo "=== Sync infrastructure to workflow template ==="
echo "  From: $PROJECT_REPO"
echo "  To:   $WORKFLOW_REPO"
echo ""

# Infrastructure directories (mirror: copy + delete extras in destination)
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
        SRC=$(to_win "$PROJECT_REPO/$dir")
        DST=$(to_win "$WORKFLOW_REPO/$dir")
        run_robocopy "$SRC" "$DST" /MIR /XJ /NJH /NJS /NDL /NP \
            /XD "__pycache__" /XF "*.pyc"
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
        mkdir -p "$(dirname "$WORKFLOW_REPO/$file")"
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
