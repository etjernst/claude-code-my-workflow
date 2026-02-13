# Workflow Quick Reference

## Non-Negotiable Standards

### Paths
- All paths relative to repository root
- Python: use `Path()` or `os.path.join()`
- Stata: use global macros (`$root`, `$data`, etc.)
- LaTeX: use `--include-directory=` (MikTeX syntax)
- **Never** hardcode absolute paths

### Reproducibility
- Python: `np.random.seed()` or `random.seed()` once at top
- Stata: `set seed` once after `clear all`
- Always: document package/ado versions

### Figures
- Transparent background: `transparent=True` (Python) / check Beamer theme
- Resolution: 300 DPI minimum for raster
- Dimensions: explicit, sized for Beamer slides (12x5 default)
- Format: PDF for LaTeX inclusion, PNG as backup
- Color palette: institutional colors (define in project conventions)

### Tables
- Stata: `esttab` to LaTeX format
- Python: manual LaTeX or `stargazer`
- Always: include SEs, significance stars, N, R-squared

### Data Management
- Raw data in `data/raw/` -- never modify originals
- Processed data in `data/processed/`
- Intermediate results: pickle/parquet (Python), .dta (Stata)

## Daily Workflow

1. Start session: Claude reads CLAUDE.md + MEMORY.md
2. Plan first: save to `quality_reports/plans/`
3. Implement: write code following conventions
4. Verify: compile/run and check output
5. Review: run appropriate reviewer agent
6. Score: `python scripts/quality_score.py <file>`
7. Commit when score >= 80

## Key Commands

```bash
# Compile slides
cd slides && xelatex --include-directory=../preambles -interaction=nonstopmode file.tex

# Run Python analysis
python scripts/python/analysis.py

# Run Stata analysis
stata-mp -b do stata/analysis.do

# Quality score
python scripts/quality_score.py <file>
```

## Agent Model Selection

- **Opus:** Planning, review, complex reasoning
- **Haiku:** Implementation, routine tasks
- **Review feedback:** Directions, not code
