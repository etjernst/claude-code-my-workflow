# Project files

Drop your existing project folder contents here. Do not reorganize---describe the structure in `CLAUDE.md` instead, and Claude will navigate it as-is.

## Convention

- Raw data files are protected by `.claude/hooks/protect-files.sh` and `.gitignore`
- Code files (.py, .do, .tex) are tracked by git
- Output files (tables, figures) are gitignored by default

## What goes here

Anything your collaborators need: data, code, output, documentation. The repo's own infrastructure (`.claude/`, `quality_reports/`, `templates/`, `preambles/`, `scripts/`) lives at the repo root, outside `project/`, keeping project files cleanly separated.
