# CLAUDE.MD -- Academic Project Development with Claude Code

<!-- HOW TO USE: Replace [BRACKETED PLACEHOLDERS] with your project info.
     Customize Beamer environments for your theme.
     Keep this file under ~150 lines — Claude loads it every session.
     See the guide at docs/workflow-guide.html for full documentation. -->

**Project:** [YOUR PROJECT NAME]
**Institution:** [YOUR INSTITUTION]
**Branch:** main

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
├── Bibliography_base.bib        # Centralized bibliography
├── Figures/                     # Figures and images
├── Preambles/header.tex         # LaTeX headers
├── Slides/                      # Beamer .tex files
├── data/                        # Data files
│   ├── raw/                     # Original data (never modify)
│   └── processed/               # Cleaned/transformed data
├── stata/                       # Stata .do files
│   └── logs/                    # Stata log files (.smcl, .log)
├── scripts/                     # Utility scripts
│   └── python/                  # Python analysis scripts
├── output/                      # Analysis output
│   ├── tables/                  # LaTeX/CSV tables
│   ├── figures/                 # Generated figures (PDF/PNG)
│   └── estimates/               # Saved estimates (pickle/parquet)
├── docs/                        # GitHub Pages (auto-generated)
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Papers and existing slides
```

---

## Commands

```bash
# LaTeX (3-pass, XeLaTeX only — MikTeX on Windows)
cd Slides
xelatex --include-directory=../Preambles -interaction=nonstopmode file.tex
bibtex --include-directory=.. file
xelatex --include-directory=../Preambles -interaction=nonstopmode file.tex
xelatex --include-directory=../Preambles -interaction=nonstopmode file.tex

# Stata
stata-mp -b do stata/analysis.do

# Python (Anaconda)
python scripts/python/analysis.py

# Quality score
python scripts/quality_score.py Slides/file.tex
python scripts/quality_score.py scripts/python/file.py
python scripts/quality_score.py stata/file.do
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

<!-- CUSTOMIZE: Replace the example entries below with your own
     Beamer environments. These are examples from the original
     project — delete them and add yours. -->

## Beamer Custom Environments

| Environment       | Effect        | Use Case       |
|-------------------|---------------|----------------|
| `[your-env]`      | [Description] | [When to use]  |

<!-- Example entries (delete and replace with yours):
| `keybox` | Gold background box | Key points |
| `highlightbox` | Gold left-accent box | Highlights |
| `definitionbox[Title]` | Blue-bordered titled box | Formal definitions |
-->

---

## Current Project State

| Component | File | Status | Key Content |
|-----------|------|--------|-------------|
| Paper | `paper.tex` | -- | [Brief description] |
| Slides | `Slides/Lecture01_Topic.tex` | -- | [Brief description] |
| Analysis | `scripts/python/analysis.py` | -- | [Brief description] |
| Stata | `stata/analysis.do` | -- | [Brief description] |
