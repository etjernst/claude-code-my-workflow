# Session Log: 2026-02-13 -- Guide Rewrite & Sync Script

**Status:** COMPLETED
**Continues from:** `2026-02-13_pdf-processing-and-readme.md`

## Objective

Convert the workflow guide from Quarto to plain Markdown, rewrite it as a lean internal reference (fixing inaccuracies), establish clone-per-project workflow with upstream remote, and build a sync script for propagating infrastructure updates.

## Changes Made

| File | Change | Reason |
|------|--------|--------|
| `guide/workflow-guide.qmd` | Deleted | Quarto format no longer in toolchain |
| `guide/_quarto.yml` | Deleted | Quarto config |
| `guide/custom.scss` | Deleted | Quarto styling |
| `guide/.gitignore` | Deleted | Quarto build artifacts gitignore |
| `guide/workflow-guide.html` | Deleted | Stale rendered output |
| `guide/workflow-guide.md` | Created, then rewritten (757 -> 256 lines) | First converted from QMD, then rewrote as lean internal reference |
| `CLAUDE.md` | Added repo setup section, removed `docs/` from folder structure | Clone-per-project workflow with upstream remote; remind every ~5 sessions to pull updates |
| `README.md` | Replaced fork instructions with clone + remote rename | Matches new clone-per-project workflow; added sync script usage |
| `scripts/sync-workflow.sh` | Created (134 lines) | Copies infrastructure files to project repos, skips project-specific files |
| `scripts/R/.gitkeep` | Deleted | Leftover from R removal |

## Design Decisions

| Decision | Alternatives Considered | Rationale |
|----------|------------------------|-----------|
| Clone-per-project (not monorepo) | Single repo with project folders | Clean git history, independent CLAUDE.md per project, independent MEMORY.md, can share/archive independently |
| Sync script (not git submodule) | Submodule, subtree, template-only | Submodules are painful with `.claude/` structure; sync script is simple and selective |
| Skip domain-reviewer + knowledge-base in sync | Sync everything, sync nothing | These two are the designated customization points; everything else is pure infrastructure |
| Lean guide (256 lines, not 757) | Keep tutorial format | Internal document -- reference format is more useful than tutorial narrative |

## Key Findings

### Guide Accuracy Issues Fixed

The old guide's quality deduction table was fabricated -- it listed "Equation typo: -10", "Label overlap: -5", "Notation inconsistency: -3" but `quality_score.py` doesn't check any of those. Replaced with actual deductions from the script (e.g., hardcoded path: -20, undefined citation: -15, missing seed: -10).

### Infrastructure vs. Project Split

51 files are infrastructure (safe to overwrite via sync), 2 are project-specific (domain-reviewer, knowledge-base-template). CLAUDE.md and settings.json are also project-specific but live outside the synced directories.

## Commits

| Hash | Message |
|------|---------|
| `55a0f3b` | Convert guide from Quarto to plain Markdown |
| `4b9622c` | Rewrite workflow guide as lean internal reference |
| `05745aa` | Add clone-per-project workflow with upstream remote |
| `6b6f3fb` | Add sync-workflow.sh for propagating infrastructure to projects |
| `029df68` | Remove leftover R directory placeholder |

## Verification

- [x] Sync script runs clean against itself (51 unchanged, 0 new, 0 updated, 2 skipped)
- [x] Guide deduction tables match actual `quality_score.py` rubrics
- [x] No Quarto files remain in `guide/`
- [x] CLAUDE.md under 152 lines (target: ~150)
- [x] README clone instructions include remote rename workflow
- [x] CLAUDE.md references correct guide path (`guide/workflow-guide.md`)

## Open Questions

- The untracked PDF (`MQBS Salary Loading Scheme and Guidelines (Feb. 2024).pdf`) is still in the repo root
- The sync script could optionally handle `settings.json` merging (permissions might need updating when new tools are added to template) -- not built yet
- Consider marking the GitHub repo as a template repository (Settings -> Template repository checkbox)
