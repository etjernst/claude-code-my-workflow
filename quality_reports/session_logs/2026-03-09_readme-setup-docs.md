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

## Status

README updated, not yet committed.
