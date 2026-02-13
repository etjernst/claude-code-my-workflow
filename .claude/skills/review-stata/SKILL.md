---
name: review-stata
description: Review a Stata .do file for code quality, reproducibility, and project standards. Launches the stata-reviewer agent.
disable-model-invocation: true
argument-hint: "[Stata file path, e.g., stata/analysis.do]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Stata Code Review

Review a Stata .do file for quality, reproducibility, and project compliance.

## Steps

1. **Identify the file** specified in `$ARGUMENTS`. Resolve path in `stata/` if not fully qualified.

2. **Launch the stata-reviewer agent:**

```
Delegate to the stata-reviewer agent:
"Review the Stata do-file at $ARGUMENTS. Check all categories in the review protocol and produce a structured report."
```

3. **Save the report** to `quality_reports/[script_name]_stata_review.md`

4. **Present summary** to user with issue counts by severity.
