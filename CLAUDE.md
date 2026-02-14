# CLAUDE.MD -- Academic Project Development with Claude Code

**Project:** [YOUR PROJECT NAME]
**Institution:** Macquarie University
**Branch:** main
**Workflow repo:** `etjernst/claude-code-my-workflow`

---

## Repo Setup (first session only)

If this project was just cloned from the workflow template, remind the user to set up remotes:

```bash
git remote rename origin workflow   # keep link to workflow repo for updates
git remote add origin https://github.com/USER/NEW-PROJECT.git
git push -u origin main
```

Periodically (every ~5 sessions), remind the user: *"Want to pull any workflow updates from the template repo?"* (`git fetch workflow && git merge workflow/main`).

---

## Core Principles
- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile/render and confirm output at the end of every task
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md
- **Agent model selection** -- use opus for planning and review, haiku for implementation
- **Review feedback** -- agents give directions, not code

---

## Folder Structure

```
[YOUR-PROJECT]/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── bibliography.bib             # Centralized bibliography
├── figures/                     # Static images (logos, photos, diagrams)
├── preambles/header.tex         # LaTeX headers
├── slides/                      # Beamer .tex files
├── data/                        # Data files
│   ├── raw/                     # Original data (never modify)
│   └── processed/               # Cleaned/transformed data
├── scripts/                     # All analysis scripts
│   ├── python/                  # Python analysis scripts
│   └── stata/                   # Stata .do files
│       └── logs/                # Stata log files (.smcl, .log)
├── output/                      # Script-generated output
│   ├── tables/                  # LaTeX/CSV tables
│   ├── figures/                 # Generated plots (PDF/PNG)
│   └── estimates/               # Saved estimates (pickle/parquet)
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Papers and existing slides
```

---

## Commands

```bash
# LaTeX (3-pass, XeLaTeX only — MikTeX on Windows)
cd slides
xelatex --include-directory=../preambles -interaction=nonstopmode file.tex
bibtex --include-directory=.. file
xelatex --include-directory=../preambles -interaction=nonstopmode file.tex
xelatex --include-directory=../preambles -interaction=nonstopmode file.tex

# Stata
stata-mp -b do scripts/stata/analysis.do

# Python (Anaconda)
python scripts/python/analysis.py

# Quality score
python scripts/quality_score.py slides/file.tex
python scripts/quality_score.py scripts/python/file.py
python scripts/quality_score.py scripts/stata/file.do
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex (MikTeX) |
| `/extract-tikz [LectureN]` | TikZ → PDF → SVG |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/review-python [file]` | Python code quality review |
| `/review-stata [file]` | Stata .do file review |
| `/slide-excellence [file]` | Combined multi-agent review |
| `/validate-bib` | Cross-reference citations |
| `/devils-advocate` | Challenge slide design |
| `/create-lecture` | Full lecture creation |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/data-analysis [dataset]` | End-to-end Python/Stata analysis |

---

## Beamer Custom Environments

| Environment | Effect | Use Case |
|---|---|---|
| `keybox` | Gold background box | Key takeaways |
| `highlightbox` | Teal left-accent box | Highlights |
| `definitionbox[Title]` | Navy titled box | Formal definitions |

---

## Current Project State

| Component | File | Status | Key Content |
|-----------|------|--------|-------------|
| Preamble | `preambles/header.tex` | Done | Metropolis theme, colors, environments |
| Slides | `slides/Workflow_Overview.tex` | Done | 17-slide workflow overview, 3 TikZ diagrams |
