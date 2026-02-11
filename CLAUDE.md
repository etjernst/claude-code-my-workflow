# CLAUDE.MD -- Selection and Heterogeneity in the Returns to Migration

**Project:** Selection and Heterogeneity in the Returns to Migration
**Authors:** Eduardo Cenci, Marieke Kleemans, Emilia Tjernstrom
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile and confirm output at the end of every task
- **LaTeX is authoritative** -- the paper `.tex` is the single source of truth; Stata `.do` files produce all analytical output
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
ckt/
├── CLAUDE.md                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── paper/                       # LaTeX paper (.tex, .bib)
│   └── bibliography.bib         # Bibliography lives with main.tex
├── prez/                        # Beamer slides (.tex files)
├── scripts/                     # Stata .do files
│   └── logs/                    # Stata log files
├── data/                        # Data files
│   ├── countries/
│   └── processed/
├── output/                      # All generated results
│   ├── figures/                 # ALL figures (Stata, TikZ, diagrams, etc.)
│   └── tables/
├── Preambles/                   # Shared LaTeX resources (style files)
├── master_supporting_docs/      # Reference papers, notes
├── explorations/                # Research sandbox (see rules)
├── quality_reports/             # Plans, session logs, merge reports
└── templates/                   # Session log, quality report, exploration templates
```

---

## Commands

```bash
# Paper compilation (3-pass, XeLaTeX, from paper/)
cd paper && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
bibtex main
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex

# Slide compilation (3-pass, XeLaTeX, from prez/)
cd prez && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
BIBINPUTS=../paper:$BIBINPUTS bibtex file
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex

# Stata (future -- run from project root)
# stata-mp -b do scripts/master.do
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
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex (paper/ or prez/) |
| `/proofread [file]` | Grammar, style, citation, reference review |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/validate-bib` | Cross-reference citations against bibliography |
| `/review-paper [file]` | Manuscript review with econometric focus |

---

## Writing Style Preferences

These apply to all paper and slide prose. The `/proofread` skill enforces them.

- Minimal adverbs and adjectives; prefer strong verbs and nouns
- Limit prepositional phrases
- Prefer active voice whenever possible
- Minimal use of "to be" in all forms (is, are, were, was)
- Convert nominalizations into verbs (e.g., "make a decision" → "decide")
- No correlative conjunctions
- No bold subheadings, bold labels, or `\paragraph{}` markers in prose
- Create structure using paragraphs and transitions, not typographic emphasis
- Clear topic sentences for every paragraph
