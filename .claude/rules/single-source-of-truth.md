---
paths:
  - "Figures/**/*"
  - "Slides/**/*.tex"
---

# Single Source of Truth: Enforcement Protocol

**The Beamer `.tex` file is the authoritative source for slide content.**

## The SSOT Chain

```
Beamer .tex (SOURCE OF TRUTH for slides)
  ├── extract_tikz.tex → PDF → SVGs (derived)
  ├── Bibliography_base.bib (shared)
  └── Figures/ (shared assets)

Analysis scripts (SOURCE OF TRUTH for results)
  ├── scripts/python/*.py → output/figures/, output/tables/
  ├── stata/*.do → output/tables/, output/estimates/
  └── data/raw/ → data/processed/ (derived)

NEVER edit derived artifacts independently.
ALWAYS propagate changes from source → derived.
```

---

## TikZ Freshness Protocol (MANDATORY)

**Before using ANY TikZ SVG, verify it matches the current Beamer source.**

### Diff-Check Procedure

1. Read the TikZ block from the Beamer `.tex` file
2. Read the corresponding block from `Figures/LectureN/extract_tikz.tex`
3. Compare EVERY coordinate, label, color, opacity, and anchor point
4. If ANY difference exists: update `extract_tikz.tex` from Beamer, recompile, regenerate SVGs

### When to Re-Extract

Re-extract ALL TikZ diagrams when:
- The Beamer `.tex` file has been modified since last extraction
- Any TikZ-related quality issue is reported

---

## Content Fidelity Checklist

```
[ ] Math check: every equation appears with identical notation
[ ] Citation check: every \cite resolves in bibliography
[ ] Figure check: every \includegraphics references an existing file
[ ] Table check: output tables match current analysis results
```
