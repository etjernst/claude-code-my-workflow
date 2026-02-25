---
name: slide-excellence
description: Comprehensive slide excellence review combining visual audit, pedagogical review, proofreading, and optional TikZ/substance reviews. Produces multiple reports and a combined summary.
disable-model-invocation: true
argument-hint: "[TEX filename]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Slide Excellence Review

Run a comprehensive multi-dimensional review of lecture slides. Multiple agents analyze the file independently, then results are synthesized.

## Steps

### 1. Identify the File

Parse `$ARGUMENTS` for the filename. Resolve path in `slides/`.

### 2. Run Review Agents in Parallel

**Agent 1: Visual Audit** (slide-auditor)
- Overflow, font consistency, box fatigue, spacing, images
- Density balance, element justification, visual hierarchy
- Save: `quality_reports/[FILE]_visual_audit.md`

**Agent 2: Pedagogy and Rhetoric Review** (pedagogy-reviewer)
- 8 rhetoric checks (one idea per slide, titles as assertions, pyramid principle, MB/MC balance, opening/closing quality, devil's advocate, element justification)
- 13 pedagogical patterns, narrative arc, pacing, notation
- Save: `quality_reports/[FILE]_pedagogy_report.md`

**Agent 3: Proofreading** (proofreader)
- Grammar, typos, consistency, academic quality, citations
- Save: `quality_reports/[FILE]_report.md`

**Agent 4: TikZ Review** (only if file contains TikZ)
- Label overlaps, geometric accuracy, visual semantics
- Save: `quality_reports/[FILE]_tikz_review.md`

**Agent 5: Substance Review** (optional, for .tex files)
- Domain correctness via domain-reviewer protocol
- Save: `quality_reports/[FILE]_substance_review.md`

### 3. Synthesize Combined Summary

```markdown
# Slide Excellence Review: [Filename]

## Overall Quality Score: [EXCELLENT / GOOD / NEEDS WORK / POOR]

| Dimension | Critical | Medium | Low |
|-----------|----------|--------|-----|
| Visual/Layout | | | |
| Rhetoric | | | |
| Pedagogical | | | |
| Proofreading | | | |

### Critical Issues (Immediate Action Required)
### Medium Issues (Next Revision)
### Recommended Next Steps
```

## Quality Score Rubric

| Score | Critical | Medium | Meaning |
|-------|----------|--------|---------|
| Excellent | 0-2 | 0-5 | Ready to present |
| Good | 3-5 | 6-15 | Minor refinements |
| Needs Work | 6-10 | 16-30 | Significant revision |
| Poor | 11+ | 31+ | Major restructuring |
