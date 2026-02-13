---
name: data-analysis
description: End-to-end Python data analysis workflow from exploration through regression to publication-ready tables and figures
disable-model-invocation: true
argument-hint: "[dataset path or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Analysis Workflow

Run an end-to-end data analysis in Python: load, explore, analyze, and produce publication-ready output.

**Input:** `$ARGUMENTS` -- a dataset path (e.g., `data/raw/county_panel.csv`) or a description of the analysis goal.

---

## Constraints

- **Follow Python code conventions** in `.claude/rules/python-code-conventions.md`
- **Save all scripts** to `scripts/python/` with descriptive names
- **Save all outputs** (figures, tables, estimates) to `output/`
- **Use pickle/parquet** for every computed object
- **Use project theme** for all figures (check for custom palette in `.claude/rules/`)
- **Run python-reviewer** on the generated script before presenting results

---

## Workflow Phases

### Phase 1: Setup and Data Loading

1. Read `.claude/rules/python-code-conventions.md` for project standards
2. Create Python script with proper header (title, author, purpose, inputs, outputs)
3. Import required packages at top
4. Set seed once at top: `np.random.seed(42)` or `random.seed(42)`
5. Load and inspect the dataset

### Phase 2: Exploratory Data Analysis

Generate diagnostic outputs:
- **Summary statistics:** `.describe()`, missingness rates, dtypes
- **Distributions:** Histograms for key continuous variables
- **Relationships:** Scatter plots, correlation matrices
- **Time patterns:** If panel data, plot trends over time
- **Group comparisons:** If treatment/control, compare pre-treatment means

Save all diagnostic figures to `output/figures/diagnostics/`.

### Phase 3: Main Analysis

Based on the research question:
- **Regression analysis:** Use `statsmodels` or `linearmodels` for panel data
- **Standard errors:** Cluster at the appropriate level (document why)
- **Multiple specifications:** Start simple, progressively add controls
- **Effect sizes:** Report standardized effects alongside raw coefficients

### Phase 4: Publication-Ready Output

**Tables:**
- Use manual LaTeX table generation or `stargazer` Python port
- Include all standard elements: coefficients, SEs, significance stars, N, R-squared
- Export as `.tex` for LaTeX inclusion

**Figures:**
- Use `matplotlib`/`seaborn` with project color palette
- Set `transparent=True` for Beamer compatibility
- Include proper axis labels (sentence case, units)
- Export with explicit dimensions and 300 DPI
- Save as both `.pdf` and `.png`

### Phase 5: Save and Review

1. `pickle.dump()` or `.to_parquet()` for all key objects
2. Create `output/` subdirectories as needed with `os.makedirs(..., exist_ok=True)`
3. Run the python-reviewer agent on the generated script
4. Address any Critical or High issues from the review.

---

## Script Structure

Follow this template:

```python
# ============================================================
# [Descriptive Title]
# Author: [from project context]
# Purpose: [What this script does]
# Inputs: [Data files]
# Outputs: [Figures, tables, estimates]
# ============================================================

# 0. Setup ----
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.api as sm
import os

np.random.seed(42)
os.makedirs("output/analysis", exist_ok=True)

# 1. Data Loading ----

# 2. Exploratory Analysis ----

# 3. Main Analysis ----

# 4. Tables and Figures ----

# 5. Export ----
```

---

## Important

- **Reproduce, don't guess.** If the user specifies a regression, run exactly that.
- **Show your work.** Print summary statistics before jumping to regression.
- **Check for issues.** Look for multicollinearity, outliers, perfect prediction.
- **Use relative paths.** All paths relative to repository root.
- **No hardcoded values.** Use variables for sample restrictions, date ranges, etc.
