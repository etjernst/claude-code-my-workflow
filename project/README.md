# Fertilizer Quality in Kenya---PEDL project files

This directory is synced bidirectionally with the `PEDL/` subfolder in Dropbox. Only the PEDL folder is pulled---root-level admin documents in the Dropbox "Fake fertilizer" folder are excluded from sync.

## Convention

- Raw data files are protected by `.claude/hooks/protect-files.sh` and `.gitignore`
- Code files (.py, .do, .tex) are tracked by git
- Output files (tables, figures) are gitignored by default

## What goes here

Anything your collaborators need: data, code, output, documentation. The repo's infrastructure (`.claude/`, `quality_reports/`, `templates/`, `preambles/`, `scripts/`) stays at the root level and never enters Dropbox.

## Dropbox sync

If your project lives in a shared Dropbox folder, you can set up bidirectional sync so that `project/` stays in sync with the Dropbox copy. Infrastructure files at the repo root are excluded automatically.

### How it works

- On every `git commit`, a post-commit hook rsyncs `project/` → Dropbox (authoritative---git is the source of truth)
- Before starting work, you manually run `sync-from-dropbox.sh` to pull collaborator changes into `project/` (additive---never deletes local files)
- `.syncignore` at the repo root controls what gets excluded from both directions

### Setup

Run the one-time setup script from the repo root:

```bash
bash templates/setup-sync.sh
```

It will ask for two paths and then:

1. Install a git post-commit hook at `.git/hooks/post-commit` (auto-push to Dropbox on every commit)
2. Create `sync-from-dropbox.sh` at the repo root (manual pull from Dropbox)

### Daily workflow

```bash
# Start of session: pull any collaborator changes
bash sync-from-dropbox.sh

# Work normally---commit as usual
git add -A && git commit -m "update analysis"
# post-commit hook automatically pushes project/ to Dropbox
```

### If you don't use Dropbox

Skip this entirely. The workflow functions without it.
