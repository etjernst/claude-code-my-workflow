---
name: review-python
description: Review a Python script for code quality, reproducibility, and project standards. Launches the python-reviewer agent.
disable-model-invocation: true
argument-hint: "[Python file path, e.g., scripts/python/analysis.py]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Python Code Review

Review a Python script for quality, reproducibility, and project compliance.

## Steps

1. **Identify the file** specified in `$ARGUMENTS`. Resolve path in `scripts/python/` if not fully qualified.

2. **Launch the python-reviewer agent:**

```
Delegate to the python-reviewer agent:
"Review the Python script at $ARGUMENTS. Check all categories in the review protocol and produce a structured report."
```

3. **Save the report** to `quality_reports/[script_name]_python_review.md`

4. **Present summary** to user with issue counts by severity.
