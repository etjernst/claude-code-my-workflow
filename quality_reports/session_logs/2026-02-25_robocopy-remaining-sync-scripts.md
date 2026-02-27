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

---

## Session continued: sync, rhetoric, and hooks cleanup

### Sync exclusion bug fix (commit `a689b1e`)
Removed infrastructure directory names (`scripts/`, `templates/`, `preambles/`, etc.) from robocopy `/XD` exclusions in all Dropbox sync scripts. The sync is scoped to `project/` ↔ Dropbox, so infrastructure is already out of scope by design. The old name-based exclusions silently skipped user project folders with the same names. Restructured `.syncignore` to document the two-layer model.

### Rhetoric integration (commits `64479bf`, `ad7cffc`)
Added `templates/rhetoric_of_decks.md` (user-authored framework). Created `.claude/rules/slide-rhetoric.md` codifying the principles. Updated `pedagogy-reviewer.md` with 8 rhetoric checks (R1--R8) evaluated before the 13 pedagogical patterns, plus title sequence test and three-act narrative arc. Updated `slide-auditor.md` with density balance, element justification, and visual hierarchy checks. Updated `/pedagogy-review` and `/slide-excellence` skills.

### Hooks cleanup (commits `3f0b976`, `3ceb76e`)
- Replaced macOS-only `notify.sh` (`osascript`) with cross-platform `notify.py` (PowerShell WinRT on Windows, osascript on macOS, notify-send on Linux)
- Deleted dead hooks: `pre-compact.sh` (superseded by `.py`), `post-merge.sh` (never wired)
- Created `edit-verify.py`: fingerprints files by mtime+size after every Edit/Write; red warning if file unchanged on disk, green confirmation otherwise; backup nudges at 3 and 6 edits for gitignored project files
- Wired into settings.json alongside verify-reminder.py
- Cleaned up `__pycache__` in hooks directory

---

## Session continued: rhetoric scoring + research-feedback skill

### Rhetoric checks in quality scorer (commit `dbf0cde`)

Added five automated rhetoric checks to `scripts/quality_score.py`, enforcing principles from `slide-rhetoric.md`:

| Check | Severity | Points | Detection |
|-------|----------|--------|-----------|
| Label titles | Major | -3/slide | Titles like "Results", "Methods" instead of assertions |
| Generic closing | Major | -5 | Last slide is "Questions?" or "Thank You" |
| Slide overload | Major | -3/slide | Frames with 8+ `\item` entries |
| Box fatigue | Minor | -2/slide | 2+ colored box environments on one frame |
| Generic opening | Minor | -2 | First content slide is bare "Outline" or "Agenda" |

Implementation: new `_parse_frames()` helper on `IssueDetector` parses `\begin{frame}` blocks into structured dicts. Five `@staticmethod` detectors operate on the frame list. Wired into `score_beamer()` after orphan/runt checks. Updated `BEAMER_RUBRIC` dict and `.claude/rules/quality-gates.md`. Verified against test file with all five violations detected (score 79/100).

### Research-feedback skill

Created `~/.claude/skills/research-feedback/` for reviewing student economics research (proposals, WIP, drafts). Supports any input format (PDF, Word, LaTeX, pasted text), flexible output (email draft, structured report, inline comments), asks for student level (Masters/PhD) and subfield interactively if not provided. Core workflow in SKILL.md; detailed six-priority feedback framework in `references/feedback-framework.md` (economic reasoning, causal identification, data fundamentals, design over technique, threats/robustness, scope/contribution).

Feedback on Bao Vu's proposal logged separately: see `2026-02-27_bao-vu-proposal-feedback.md`.
