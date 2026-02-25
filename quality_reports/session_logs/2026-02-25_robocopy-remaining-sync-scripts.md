# Session log: Convert remaining sync scripts from rsync to robocopy

**Date:** 2026-02-25
**Status:** COMPLETE

---

## Goal

Convert the three remaining rsync-based sync scripts to robocopy for Windows compatibility. The Dropbox/Overleaf sync scripts (`setup-sync.sh`, post-commit hook, `sync-pull.sh`) were already converted in commit `bad1222`, but the infrastructure sync scripts were missed.

## Changes made

| File | What changed |
|------|-------------|
| `templates/sync-to-workflow.sh` | `rsync -av --delete` → `robocopy /MIR` with `to_win()` + `run_robocopy()` helpers |
| `templates/sync-from-workflow.sh` | `rsync -av --delete` → `robocopy /MIR` with `to_win()` + `run_robocopy()` helpers |
| `templates/sync-from-dropbox.sh` | `rsync -av` → `robocopy /E` with hardcoded exclusions (robocopy has no `--exclude-from`) |

## Pattern used

All three scripts follow the same robocopy conventions established in `setup-sync.sh`:
- `to_win()` converts Git Bash paths to Windows paths
- `run_robocopy()` wraps robocopy and treats exit codes 0--7 as success
- `/MIR` for mirror sync (replaces `rsync --delete`)
- `/E` for copy-only sync (replaces `rsync` without `--delete`)
- `/XD` and `/XF` for directory and file exclusions

## Follow-up: three robocopy bugs fixed

Committed as `94de4db`, pushed to main.

Three bugs affected all sync scripts in Git Bash:

1. `to_win()` sed delimiter collision --- `s|/|\\|g` failed because `\\|` was parsed as escaped delimiter. Replaced with bash parameter expansion: `p="${p//\//\\}"`.

2. MSYS automatic path conversion --- Git Bash converts `/E`, `/MIR`, `/XJ` to Windows paths before passing to `.exe` programs. Fixed by prefixing `MSYS_NO_PATHCONV=1` inline on each `robocopy.exe` call.

3. Unquoted `.sync-config` values (setup-sync.sh only) --- paths with spaces like `Dropbox (Personal)` got word-split on `source`. Added double quotes in the heredoc.

Files changed: `setup-sync.sh` (2 copies of bugs 1+2, plus bug 3), `sync-from-workflow.sh`, `sync-to-workflow.sh`, `sync-from-dropbox.sh` (gitignored, local fix only).

## Testing

Ran end-to-end test against `C:\Users\maand\Dropbox (Personal)\JointDocs`:
- `to_win()` correctly handles spaces, parens, `/c/` and `/d/` prefixes (3/3 pass)
- `setup-sync.sh --dropbox` generates properly quoted `.sync-config` (4/4 pass)
- Robocopy dry-run pull (`/L` flag) succeeded with exit code 3 (1/1 pass)
- 8/8 tests passed, 0 failed. Cleanup complete.
