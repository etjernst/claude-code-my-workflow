#!/bin/bash
# Sync workflow infrastructure from template repo to a project repo.
#
# Usage:
#   ./scripts/sync-workflow.sh /path/to/project
#
# Copies agents, skills, hooks, rules, scripts, templates, and guide.
# Skips project-specific files: CLAUDE.md, settings.json,
# domain-reviewer.md, knowledge-base-template.md.
#
# Safe to run repeatedly — only overwrites files that differ.

set -euo pipefail

# ── Resolve template repo root (where this script lives) ──
TEMPLATE="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-}"

if [ -z "$TARGET" ]; then
    echo "Usage: $(basename "$0") /path/to/project"
    echo ""
    echo "Syncs workflow infrastructure from this template repo to a project."
    echo "Project-specific files (CLAUDE.md, settings.json, domain-reviewer,"
    echo "knowledge-base-template) are never overwritten."
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "Error: directory not found: $TARGET"
    exit 1
fi

if [ ! -f "$TARGET/CLAUDE.md" ]; then
    echo "Warning: $TARGET/CLAUDE.md not found — is this a project repo?"
    read -r -p "Continue anyway? [y/N] " response
    [[ "$response" =~ ^[Yy]$ ]] || exit 0
fi

# ── Counters ──
NEW=0
UPDATED=0
UNCHANGED=0
SKIPPED_FILES=()

# ── Sync one file ──
# Args: $1 = source (relative to TEMPLATE), $2 = dest (relative to TARGET)
sync_file() {
    local src="$TEMPLATE/$1"
    local dst="$TARGET/${2:-$1}"

    if [ ! -f "$src" ]; then
        return
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"

    if [ ! -f "$dst" ]; then
        cp "$src" "$dst"
        echo "  NEW     $1"
        NEW=$((NEW + 1))
    elif ! diff -q "$src" "$dst" > /dev/null 2>&1; then
        cp "$src" "$dst"
        echo "  UPDATED $1"
        UPDATED=$((UPDATED + 1))
    else
        UNCHANGED=$((UNCHANGED + 1))
    fi
}

# ── Skip list (project-specific files) ──
is_skipped() {
    local file="$1"
    case "$file" in
        .claude/agents/domain-reviewer.md) return 0 ;;
        .claude/rules/knowledge-base-template.md) return 0 ;;
        *) return 1 ;;
    esac
}

echo "Syncing workflow from: $TEMPLATE"
echo "                   to: $TARGET"
echo ""

# ── Agents ──
echo "Agents:"
for f in "$TEMPLATE"/.claude/agents/*.md; do
    rel=".claude/agents/$(basename "$f")"
    if is_skipped "$rel"; then
        SKIPPED_FILES+=("$rel")
        echo "  SKIP    $rel (project-specific)"
    else
        sync_file "$rel"
    fi
done

# ── Skills (entire directories) ──
echo "Skills:"
for d in "$TEMPLATE"/.claude/skills/*/; do
    skill="$(basename "$d")"
    for f in "$d"*; do
        [ -f "$f" ] || continue
        rel=".claude/skills/$skill/$(basename "$f")"
        sync_file "$rel"
    done
done

# ── Rules ──
echo "Rules:"
for f in "$TEMPLATE"/.claude/rules/*.md; do
    rel=".claude/rules/$(basename "$f")"
    if is_skipped "$rel"; then
        SKIPPED_FILES+=("$rel")
        echo "  SKIP    $rel (project-specific)"
    else
        sync_file "$rel"
    fi
done

# ── Hooks ──
echo "Hooks:"
for f in "$TEMPLATE"/.claude/hooks/*; do
    [ -f "$f" ] || continue
    rel=".claude/hooks/$(basename "$f")"
    sync_file "$rel"
done

# ── Scripts (quality_score.py + sync script itself) ──
echo "Scripts:"
sync_file "scripts/quality_score.py"
sync_file "scripts/sync-workflow.sh"

# ── Templates ──
echo "Templates:"
for f in "$TEMPLATE"/templates/*; do
    [ -f "$f" ] || continue
    rel="templates/$(basename "$f")"
    sync_file "$rel"
done

# ── Guide ──
echo "Guide:"
for f in "$TEMPLATE"/guide/*; do
    [ -f "$f" ] || continue
    rel="guide/$(basename "$f")"
    sync_file "$rel"
done

# ── Summary ──
echo ""
echo "────────────────────────────"
echo "  New:       $NEW"
echo "  Updated:   $UPDATED"
echo "  Unchanged: $UNCHANGED"
echo "  Skipped:   ${#SKIPPED_FILES[@]} (project-specific)"
echo "────────────────────────────"

if [ $((NEW + UPDATED)) -gt 0 ]; then
    echo ""
    echo "Run 'cd $TARGET && git diff' to review changes."
    echo "Then commit: git add -A && git commit -m 'Sync workflow updates from template'"
fi
