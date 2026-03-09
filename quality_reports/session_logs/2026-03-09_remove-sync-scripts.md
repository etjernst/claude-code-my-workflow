# Session log: Remove sync scripts, replace with symlinks

**Date:** 2026-03-09
**Goal:** Remove all Dropbox/Overleaf syncing infrastructure (scripts, hooks, tests, docs) in preparation for replacing the approach with symlinks.

## Key context

- The repo had a robocopy-based sync system: `setup-sync.sh` installed git hooks (pre-commit conflict detection, post-commit push), created `sync-pull.sh`, and stored paths in `.sync-config`
- Overleaf sync pushed output dirs to an Overleaf-linked Dropbox folder
- Decision: replace all of this with symlinks instead

## Changes made

### Deleted (7 files)
- `templates/setup-sync.sh` — one-time Dropbox/Overleaf setup
- `templates/sync-from-dropbox.sh` — manual Dropbox pull
- `templates/sync-from-workflow.sh` — pull infrastructure from workflow template
- `templates/sync-to-workflow.sh` — push infrastructure to workflow template
- `.syncignore` — Dropbox exclusion list
- `.claude/hooks/edit-verify.py` — edit verification + Dropbox backup nudges
- `tests/test_sync_safety.sh` — robocopy sync safety tests

### Revised (5 files)
- `CLAUDE.md` — removed Dropbox setup step and "(Dropbox sync target)" comment
- `README.md` — removed entire "Dropbox and Overleaf sync" section, sync references in setup instructions, starter prompt, origin line, and `sync-from-workflow.sh` reference
- `project/README.md` — removed Dropbox/Overleaf sync section and daily workflow
- `install.sh` — changed "Sync" to "Install" in comment
- `.claude/settings.json` — removed hook wiring for deleted `edit-verify.py`

### Kept (session logs)
- Session logs mentioning sync were left for the historical record

## Open questions
- Symlink approach not yet implemented — next step
