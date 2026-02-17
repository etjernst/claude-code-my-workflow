---
name: proofread
description: Run the proofreading protocol on a file. Checks grammar, passive voice, typos, formatting, consistency, and writing style. Produces a report without editing files. Use when the user says /proofread or asks to proofread, review style, or check writing quality.
disable-model-invocation: true
argument-hint: "[filename or glob pattern]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Proofread files

Run the mandatory proofreading protocol on the specified file(s). This produces a report of all issues found WITHOUT editing any source files.

## Steps

1. Identify files to review:
   - If `$ARGUMENTS` names a specific file: review that file only
   - If `$ARGUMENTS` is a glob pattern: review all matching files
   - If `$ARGUMENTS` is empty: ask which file to review

2. For each file, launch the proofreader agent that checks for:

   GRAMMAR: Subject-verb agreement, articles, prepositions, tense consistency
   PASSIVE VOICE: Flag every passive construction and propose active alternative
   TYPOS: Misspellings, search-and-replace artifacts, duplicated words
   FORMATTING: Overflow (LaTeX), heading hierarchy (Markdown), dash usage, number formatting
   CONSISTENCY: Citation format, notation, terminology, heading case
   WRITING STYLE: No bold labels, no nominalizations, no orphan words, strong verbs, flush em dashes

3. Produce a detailed report for each file listing every finding with:
   - Location (line number or section heading)
   - Current text (what's wrong)
   - Proposed fix (what it should be)
   - Category and severity

4. Save each report to `quality_reports/`:
   - Named `quality_reports/FILENAME_WITHOUT_EXT_report.md`

5. IMPORTANT: Do NOT edit any source files.
   Only produce the report. Fixes are applied separately after user review.

6. Present summary to the user:
   - Total issues found per file
   - Breakdown by category
   - Most critical issues highlighted
