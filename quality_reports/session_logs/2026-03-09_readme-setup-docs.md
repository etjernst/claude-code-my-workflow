# Session log: Improve README setup documentation

**Date:** 2026-03-09
**Goal:** Review README for clarity on three setup scenarios and improve where needed.

## What we checked

User asked whether the README clearly covers:
1. Setting up a new repo from scratch
2. Migrating an existing repo that already has project-level `.claude/` infrastructure
3. Safely converting an existing `project/` directory to a symlink without data loss

## Changes made

### Added: "Existing repo (migrating from project-level Claude infrastructure)" section
- New section between the two existing setup scenarios
- Covers auditing what project-level `.claude/` infrastructure exists
- How to preserve custom skills/rules by copying to `~/.claude/` before deleting
- Removing project-level skills/agents/rules/hooks while keeping `settings.json`
- Replacing the heavyweight `CLAUDE.md` with the lightweight template
- Links to `project/` migration steps

### Improved: "Migrating from an existing project/ directory" section
- Explains what `diff -rq` output means (what "Only in project/" lines signify)
- Explicitly says to move at-risk files to Dropbox before proceeding
- Explains what `differ` lines mean and how to resolve version conflicts
- Clearer sequencing: verify → move → resolve → delete

### Added: `.claude/` to exclude list in "Existing repo (no commits to remote)"
- Claude Code creates a `.claude/` directory for local state/settings
- Added `echo ".claude/" >> .git/info/exclude` to the setup commands

### Added: Stealth mode for commit messages
- Co-authoring lines ("with Claude") in commits are a trace---added instructions to suppress them
- `git config --local claude.coauthor false` as a repo-local breadcrumb
- Instruction to add "Stealth mode" line to project `CLAUDE.md` so Claude skips co-authoring
- Updated section intro to explicitly promise no trace in files or commits

### Fixed: Hardcoded path
- Changed `cp C:/git/fresh-workflow/CLAUDE.md` to `cp /path/to/fresh-workflow/CLAUDE.md`

### Replaced full template copy with minimal inline CLAUDE.md
- The full template creates folders (quality_reports/, explorations/, etc.) that don't belong in someone else's repo
- New inline `cat > CLAUDE.md << 'EOF'` creates a minimal version with just project context and stealth mode

### Added verification step and .gitignore fallback
- `git check-ignore -v CLAUDE.md` to verify the exclude is working
- If repo's .gitignore has negation patterns (e.g., `!/**/*.md`), exclude file won't work
- Fallback: append to .gitignore + `git update-index --assume-unchanged .gitignore`
- Discovered this via real testing---`.gitignore` negations override `.git/info/exclude`

## Status

Committed.
