---
name: proofread
description: Run the proofreading protocol on paper or slide files. Checks grammar, typos, overflow, consistency, writing style, and references. Produces a report without editing files.
disable-model-invocation: true
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Proofread Files

Run the mandatory proofreading protocol on paper or slide files. This produces a report of all issues found WITHOUT editing any source files.

## Steps

1. **Identify files to review:**
   - If `$ARGUMENTS` is a specific filename: review that file only
   - If `$ARGUMENTS` is "all": review all `.tex` files in `paper/` and `prez/`

2. **For each file, launch the proofreader agent** that checks for:

   **GRAMMAR:** Subject-verb agreement, articles (a/an/the), prepositions, tense consistency
   **TYPOS:** Misspellings, search-and-replace artifacts, duplicated words
   **OVERFLOW:** Overfull hbox warnings, content exceeding page/slide boundaries
   **CONSISTENCY:** Citation format (`\citet` vs `\citep`), notation, terminology
   **ACADEMIC QUALITY:** Informal language, missing words, awkward constructions
   **REFERENCES:** `\ref{}` targets exist, all figures/tables referenced, `\label{}`/`\ref{}` pairs consistent
   **WRITING STYLE:** Enforces the project's writing preferences:
   - Minimal adverbs and adjectives; prefer strong verbs and nouns
   - Limit prepositional phrases
   - Prefer active voice whenever possible
   - Minimal use of "to be" in all forms (is, are, were, was)
   - Convert nominalizations into verbs
   - No correlative conjunctions
   - No bold subheadings, bold labels, or `\paragraph{}` markers in prose
   - Create structure using paragraphs and transitions, not typographic emphasis
   - Clear topic sentences for every paragraph

3. **Produce a detailed report** for each file listing every finding with:
   - Location (line number or section/slide title)
   - Current text (what's wrong)
   - Proposed fix (what it should be)
   - Category and severity

4. **Save each report** to `quality_reports/[FILENAME_WITHOUT_EXT]_report.md`

5. **IMPORTANT: Do NOT edit any source files.**
   Only produce the report. Fixes are applied separately after user review.

6. **Present summary** to the user:
   - Total issues found per file
   - Breakdown by category
   - Most critical issues highlighted
