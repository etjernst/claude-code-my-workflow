---
name: pedagogy-review
description: Run pedagogical and rhetoric review on lecture slides. Checks rhetoric (one idea per slide, titles as assertions, pyramid principle, MB/MC balance), narrative arc, student prerequisites, worked examples, notation clarity, and deck pacing.
disable-model-invocation: true
argument-hint: "[TEX filename]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Pedagogy and Rhetoric Review of Lecture Slides

Perform a comprehensive pedagogical and rhetoric review.

## Steps

1. **Identify the file** specified in `$ARGUMENTS`
   - If no argument, ask user which lecture to review
   - If just a name, look in `slides/`

2. **Launch the pedagogy-reviewer agent** with the full file path
   - The agent checks 8 rhetoric principles (one idea per slide, titles as assertions, pyramid principle, MB/MC balance, opening/closing quality, devil's advocate, element justification)
   - Checks 13 pedagogical patterns
   - Performs deck-level analysis (narrative arc, pacing, density balance, visual rhythm, notation)
   - Runs the title sequence test (do titles form a coherent argument?)
   - Considers student perspective (prerequisites, objections)

3. **The agent produces a report** saved to:
   `quality_reports/[FILENAME_WITHOUT_EXT]_pedagogy_report.md`

4. **Present summary to user:**
   - Rhetoric checks passed vs failed (out of 8)
   - Patterns followed vs violated (out of 13)
   - Title sequence assessment
   - Deck-level assessments
   - Critical recommendations (top 3-5)

## Important Notes

- This is a **read-only review** -- no files are edited
- Focuses on **pedagogy and rhetoric** not visual layout (use `/visual-audit` for that)
- For a combined review, use `/slide-excellence` instead
