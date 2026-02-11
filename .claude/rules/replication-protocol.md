---
paths:
  - "scripts/**/*.py"
  - "output/**"
---

# Replication-First Protocol

**Core principle:** Replicate original results to the dot BEFORE extending.

---

## Phase 1: Inventory & Baseline

Before writing any analysis code:

- [ ] Read the paper's replication README
- [ ] Inventory replication package: data files, scripts, outputs
- [ ] Record gold standard numbers from the paper:

```markdown
## Replication Targets: [Paper Author (Year)]

| Target | Table/Figure | Value | SE/CI | Notes |
|--------|-------------|-------|-------|-------|
| Main ATT | Table 2, Col 3 | -1.632 | (0.584) | Primary specification |
```

- [ ] Store targets in `quality_reports/replication_targets.md`

---

## Phase 2: Translate & Execute

- [ ] Translate line-by-line initially -- don't "improve" during replication
- [ ] Match original specification exactly (covariates, sample, clustering, SE computation)
- [ ] Save all intermediate results

### Python Conventions

| Convention | Example | Notes |
|-----------|---------|-------|
| Relative paths | `Path("data/processed/panel.parquet")` | Use pathlib, never hardcode absolute |
| Logging | `logging.getLogger(__name__)` | Use logging module, not print() |
| Docstrings | `"""Estimate IV model for EC impact."""` | Module and function docstrings |
| Output export | `fig.savefig("output/figures/fig1.pdf")` | Always to output/ |
| Clustering | `fit(cov_type='clustered', cluster_entity=...)` | Document clustering level |
| Fixed effects | `PanelOLS(..., entity_effects=True, time_effects=True)` | Specify all FE |
| Reproducibility | `np.random.seed(12345)` | Always set seed |

---

## Phase 3: Verify Match

### Tolerance Thresholds

| Type | Tolerance | Rationale |
|------|-----------|-----------|
| Integers (N, counts) | Exact match | No reason for any difference |
| Point estimates | < 0.01 | Rounding in paper display |
| Standard errors | < 0.05 | Bootstrap/clustering variation |
| P-values | Same significance level | Exact p may differ slightly |
| Percentages | < 0.1pp | Display rounding |

### If Mismatch

**Do NOT proceed to extensions.** Isolate which step introduces the difference, check common causes (sample size, SE computation, default options, variable definitions), and document the investigation even if unresolved.

### Replication Report

Save to `quality_reports/replication_report.md`:

```markdown
# Replication Report: [Paper Author (Year)]
**Date:** [YYYY-MM-DD]
**Scripts:** [script paths]

## Summary
- **Targets checked / Passed / Failed:** N / M / K
- **Overall:** [REPLICATED / PARTIAL / FAILED]

## Results Comparison

| Target | Paper | Ours | Diff | Status |
|--------|-------|------|------|--------|

## Discrepancies (if any)
- **Target:** X | **Investigation:** ... | **Resolution:** ...

## Environment
- Python version, key packages (with versions), data source
```

---

## Phase 4: Only Then Extend

After replication is verified (all targets PASS):

- [ ] Commit replication script: "Replicate [Paper] Table X -- all targets match"
- [ ] Now extend with project-specific modifications (different estimators, new figures, etc.)
- [ ] Each extension builds on the verified baseline
