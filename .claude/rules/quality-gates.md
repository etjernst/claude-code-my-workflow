---
paths:
  - "paper/**/*.tex"
  - "prez/**/*.tex"
  - "scripts/**/*.py"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for deployment
- **95/100 = Excellence** -- aspirational

## Paper & Slides (.tex)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | XeLaTeX compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Equation overflow or typo | -10 |
| Critical | Overfull hbox > 10pt | -10 |
| Major | Notation inconsistency | -5 |
| Major | Writing style violation (see CLAUDE.md) | -3 |
| Major | Missing figure/table reference | -3 |
| Minor | Font size reduction | -1 per slide |
| Minor | Long lines (>100 chars) | -1 (EXCEPT documented math formulas) |

## Python Scripts (.py)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Hardcoded absolute paths (not using relative paths) | -20 |
| Critical | No module docstring | -15 |
| Major | Missing type hints on public functions | -5 |
| Major | Missing output export (figure/table) | -5 |
| Major | No comments for non-obvious operations | -3 |
| Minor | PEP 8 violations | -1 |
| Minor | Unused imports | -1 |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.

## Tolerance Thresholds (Research)

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | 1e-6 | Numerical precision |
| Standard errors | 1e-4 | Clustering/bootstrap variation |
| Coverage rates | +/- 0.01 | MC variability |
