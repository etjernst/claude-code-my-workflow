# Project files

This directory is a symlink to your Dropbox folder. Do not reorganize---describe the structure in `CLAUDE.md` instead, and Claude will navigate it as-is.

## Convention

- Code files (.do, .py, .R, .tex, .bib, .sh) are tracked by git through the symlink
- Everything else (data, output, figures) is gitignored by default
- Edits write directly to Dropbox---no sync step needed

## What git tracks

The `.gitignore` uses an ignore-everything-then-whitelist approach: all files in `project/` are ignored by default, then code file extensions are whitelisted. To track additional extensions, add them to `.gitignore`.
