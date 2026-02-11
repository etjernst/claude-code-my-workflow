---
paths:
  - "scripts/**/*.do"
  - "explorations/**"
  - "output/**"
---

# Research Project Orchestrator (Simplified)

**For Stata scripts, data analysis, and output generation** -- use this simplified loop instead of the full multi-agent orchestrator.

## The Simple Loop

```
Plan approved → orchestrator activates
  │
  Step 1: IMPLEMENT — Execute plan steps
  │
  Step 2: VERIFY — Run code, check outputs
  │         Stata scripts: .do file runs without error
  │         Log files: check for error messages
  │         Figures: created in output/figures/, correct format
  │         Tables: created in output/tables/, correct format
  │         If verification fails → fix → re-verify
  │
  Step 3: SCORE — Apply quality-gates rubric
  │
  └── Score >= 80?
        YES → Done (commit when user signals)
        NO  → Fix blocking issues, re-verify, re-score
```

**No 5-round loops. No multi-agent reviews. Just: write, test, done.**

## Verification Checklist

- [ ] Script runs without errors (check log file)
- [ ] All globals/paths use master.do conventions
- [ ] No hardcoded absolute paths
- [ ] Log file opened and closed properly
- [ ] Output files created at expected paths (output/figures/, output/tables/)
- [ ] Variable labels applied to key variables
- [ ] Tolerance checks pass (if applicable)
- [ ] Quality score >= 80
