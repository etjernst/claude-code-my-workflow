# Transformation summary

**Date:** 2026-02-24
**Source:** Fresh clone of `pedrohcgs/claude-code-my-workflow` (LaTeX/Beamer + R + Quarto)
**Target:** Reusable template for data analysis projects (LaTeX/Beamer + Python + Stata)

---

## What this repo is

A ready-to-clone Claude Code workflow template for economics research. You clone it, drop your existing project files into `project/`, describe the structure in `CLAUDE.md`, and start working. Claude Code gets plan-first workflow, quality gates, specialized review agents, and automated hooks out of the box.

The repo separates infrastructure (root level) from project content (`project/` subdirectory). Infrastructure never syncs to Dropbox; only `project/` does.

### Folder structure

```
repo/
├── CLAUDE.md                    # Project config (fill in placeholders)
├── MEMORY.md                    # Persistent learnings across sessions
├── README.md                    # What this is, how to use, prerequisites
├── bibliography.bib             # Shared bibliography
├── .syncignore                  # Patterns excluded from Dropbox sync
├── .gitignore                   # LaTeX + Python + Stata + data artifacts
├── .claude/
│   ├── settings.json            # Windows permissions + hook wiring
│   ├── agents/                  # 8 review agents
│   ├── rules/                   # 18 workflow rules
│   ├── skills/                  # 19 slash commands
│   ├── hooks/                   # 9 automation hooks
│   └── WORKFLOW_QUICK_REF.md    # One-page cheat sheet
├── preambles/header.tex         # Metropolis Beamer theme
├── slides/                      # Beamer .tex files
├── figures/                     # Static images
├── scripts/
│   ├── quality_score.py         # Quality scoring (Beamer/Python/Stata)
│   ├── python/                  # Shared Python utilities
│   └── stata/
│       └── logs/                # Stata log files
├── templates/                   # Session log, quality report, sync scripts
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox
├── master_supporting_docs/      # Papers for PDF processing
└── project/                     # YOUR EXISTING PROJECT FILES HERE
```

### Key features

- 8 review agents (domain, pedagogy, proofreading, Python, Stata, slide audit, TikZ, verification)
- 19 slash commands (`/compile-latex`, `/data-analysis`, `/review-python`, `/review-stata`, etc.)
- Plan-first workflow with requirements specs for ambiguous tasks
- Quality gates at 80/90/95 thresholds
- Automated hooks for context monitoring, session logging, file protection, and compaction recovery
- Dropbox sync templates for collaborator workflows
- Two-tier memory system (committed MEMORY.md + gitignored personal memory)

---

## Changes from upstream

84 files changed: 23 deleted, 4 renamed, 14 new, 43 modified.

### Phase 1: Deleted R/Quarto infrastructure

| Type | Files deleted |
|------|-------------|
| Agents | `beamer-translator.md`, `quarto-critic.md`, `quarto-fixer.md`, `r-reviewer.md` |
| Rules | `beamer-quarto-sync.md`, `r-code-conventions.md` |
| Skills | `deploy/`, `qa-quarto/`, `translate-to-quarto/`, `review-r/` |
| Directories | `Quarto/`, `docs/`, `guide/`, `scripts/R/` |
| Scripts | `scripts/sync_to_docs.sh` |
| Templates | `templates/skill-template.md` |
| Session logs | Two upstream session logs from February 2026 |

### Phase 2: Directory restructuring

Renamed uppercase directories to lowercase (two-step rename for Windows case-insensitive filesystem):

- `Figures/` → `figures/`
- `Slides/` → `slides/`
- `Preambles/` → `preambles/`
- `Bibliography_base.bib` → `bibliography.bib`

Created new directories:

- `project/` with README explaining the convention
- `scripts/python/`
- `scripts/stata/` with `logs/` subdirectory

### Phase 3: New files from tested fork

Copied from a previously tested fork, adapted for Windows:

| File | Purpose |
|------|---------|
| `.claude/agents/python-reviewer.md` | Python code review agent |
| `.claude/agents/stata-reviewer.md` | Stata .do file review agent |
| `.claude/rules/python-code-conventions.md` | Python code standards (path scope `**/*.py`) |
| `.claude/rules/stata-code-conventions.md` | Stata code standards (path scope `**/*.do`) |
| `.claude/skills/review-python/SKILL.md` | `/review-python` slash command |
| `.claude/skills/review-stata/SKILL.md` | `/review-stata` slash command |
| `preambles/header.tex` | Metropolis Beamer theme with keybox/highlightbox/definitionbox |
| `scripts/quality_score.py` | Quality scorer supporting Beamer, Python, and Stata |
| `.syncignore` | Patterns excluded from Dropbox rsync |
| `templates/post-commit-hook.sh` | Rsync project/ → Dropbox (with `--delete`) |
| `templates/sync-from-dropbox.sh` | Rsync Dropbox → project/ (no `--delete` for safety) |
| `project/README.md` | Explains the project/ convention and Dropbox sync |

### Phase 4: Adapted agents (5 files)

Removed R/Quarto references, added Python/Stata where relevant:

| Agent | Key changes |
|-------|------------|
| `domain-reviewer.md` | R scripts → Python/Stata scripts |
| `pedagogy-reviewer.md` | Removed Quarto syntax patterns |
| `proofreader.md` | Broadened to professional documents; added writing style checks |
| `slide-auditor.md` | Removed Quarto/RevealJS; added Beamer-specific checks |
| `verifier.md` | Removed .qmd/.R verification; added .py/.do; MikTeX `--include-directory` |

`tikz-reviewer.md` was unchanged.

### Phase 5: Adapted rules (16 files)

All path-scoped rules updated from uppercase to recursive lowercase globs (`Slides/` → `**/*.tex`, `scripts/**/*.R` → `**/*.py` + `**/*.do`).

| Rule | Key changes |
|------|------------|
| `quality-gates.md` | Replaced Quarto/.R rubrics with Beamer/.py/.do |
| `verification-protocol.md` | Removed Quarto section; added Python + Stata; MikTeX syntax |
| `single-source-of-truth.md` | Removed Quarto-derived chain; added analysis scripts chain |
| `pdf-processing.md` | Ghostscript → PyPDF2; added chunked pathway for large PDFs |
| `replication-protocol.md` | R → Python/Stata; updated pitfalls table |
| `proofreading-protocol.md` | Added passive voice + writing style categories |
| `orchestrator-research.md` | R → Python/Stata verification commands |
| `knowledge-base-template.md` | R code pitfalls → Python/Stata code pitfalls |
| `exploration-fast-track.md` | R/ → scripts/python/, scripts/stata/; recursive globs |
| `exploration-folder-protocol.md` | Path updates; project/ awareness |
| `no-pause-beamer.md` | Path glob update only |
| `tikz-visual-quality.md` | Path glob update only |
| `meta-governance.md` | Updated tools list, examples, macOS → Windows |
| `plan-first-workflow.md` | Restored requirements spec phase and context survival strategy |
| `orchestrator-protocol.md` | No changes needed |
| `session-logging.md` | No changes needed |

### Phase 6: Adapted skills (11 files)

| Skill | Key changes |
|-------|------------|
| `compile-latex` | MikTeX `--include-directory`; `cd slides`; `start` not `open`; added `disable-model-invocation` |
| `create-lecture` | R figures → Python/Stata figures; RDS → pickle/parquet |
| `data-analysis` | Complete R-to-Python conversion (statsmodels, linearmodels, matplotlib, seaborn) |
| `extract-tikz` | Lowercase paths; `--include-directory`; removed docs/ sync step |
| `pedagogy-review` | QMD → TEX; recursive paths |
| `proofread` | Added passive voice + writing style; broadened to all file types |
| `slide-excellence` | Removed Quarto content-parity agent |
| `visual-audit` | Removed Quarto render step |
| `validate-bib` | Removed .qmd scanning; `bibliography.bib` |
| `review-paper` | Removed .qmd input format |
| `learn` | Updated R example to Python/statsmodels example |

Eight skills were unchanged: `commit`, `context-status`, `devils-advocate`, `interview-me`, `lit-review`, `research-ideation`, `review-python`, `review-stata`.

### Phase 7: Configuration files

| File | Changes |
|------|---------|
| `CLAUDE.md` | Complete rewrite: Macquarie University, project/ philosophy, MikTeX `--include-directory`, Python/Stata commands, Beamer environments, Dropbox sync section, project setup checklist |
| `README.md` | Minimal rewrite: what this repo is, 5-step usage, prerequisites |
| `MEMORY.md` | Cleaned: kept generic workflow patterns, removed upstream-specific entries |
| `WORKFLOW_QUICK_REF.md` | R → Python/Stata equivalents (`here::here()` → `Path()`, `set.seed()` → `np.random.seed()`) |

### Phase 8: Dropbox sync infrastructure

- `project/README.md` explains the project/ convention and sync workflow
- `.syncignore` excludes infrastructure from sync
- `templates/post-commit-hook.sh` rsyncs project/ → Dropbox (with `--delete`)
- `templates/sync-from-dropbox.sh` rsyncs Dropbox → project/ (no `--delete` for safety)
- `CLAUDE.md` includes Dropbox sync section with placeholders

### Phase 9: Hook cleanup

| Hook | Changes |
|------|---------|
| `notify.sh` | Kept on disk but unwired from settings.json (user-level settings handle notifications) |
| `post-merge.sh` | Removed emoji, flush emdashes, replaced macOS example with Windows MikTeX |
| `context-monitor.py` | Removed emoji, flush emdashes, standardized throttle to 60s |
| `log-reminder.py` | `python3` → `python` in docstring, `/tmp/` → `tempfile.gettempdir()` |
| `pre-compact.py` | Removed emoji from format_compaction_message |
| `post-compact-restore.py` | Added `"resume"` to session_type check |
| `protect-files.sh` | `Bibliography_base.bib` → `bibliography.bib`; added `CLAUDE.md` to protected patterns |
| `verify-reminder.py` | `.qmd`/`.R` → `.py`/`.do`; added Windows path normalization |

### Phase 10: .gitignore

Replaced R/.Rproj/.Rhistory/.Quarto patterns with:

- Python: `__pycache__/`, `*.pyc`, `*.egg-info/`, `.env`
- Stata: `*.smcl`, `*.gph`
- Data files: `csv`, `dta`, `xlsx`, `tsv`, `parquet`, `pkl` inside project/
- LaTeX artifacts: `*.aux`, `*.log`, `*.bbl`, `*.synctex.gz`, etc.
- Dropbox conflict files
- Claude state: `.claude/state/`, `.claude/settings.local.json`

### Phase 11: Cleanup

- Deleted `custom-adaptations.md` (purpose served)
- Deleted `claude_code_instructions.md` (instructions for this task, not template content)
- Deleted two upstream session logs

### Settings.json changes

- Removed notification hook (unwired `notify.sh`)
- Changed all `python3` → `python` in hook commands
- Removed R/Quarto permissions (`Rscript`, `quarto render`, `TEXINPUTS=`, `BIBINPUTS=`, `sync_to_docs.sh`)
- Added Python/Stata/Windows permissions (`python`, `pip`, `conda`, `stata-mp`, `start`, `powershell`)
- Consolidated `gh *` permissions

---

## Platform adaptations

All infrastructure is adapted for Windows 11 + Git Bash:

- MikTeX `--include-directory=` flag instead of Unix `TEXINPUTS=` env var
- `start` instead of `open` for opening files
- `tempfile.gettempdir()` instead of hardcoded `/tmp/`
- `python` instead of `python3` in all hook commands
- Windows path normalization in hook scripts (`\\` → `/`)
- Two-step git rename to work around case-insensitive NTFS
