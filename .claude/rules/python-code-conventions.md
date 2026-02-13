---
paths:
  - "**/*.py"
  - "scripts/**/*.py"
---

# Python Code Standards

**Standard:** Senior Principal Data Engineer + PhD researcher quality

---

## 1. Reproducibility

- `random.seed()` or `np.random.seed()` called ONCE at top
- All imports at top, grouped: stdlib, third-party, local
- All paths relative to repository root
- `os.makedirs(..., exist_ok=True)` for output directories

## 2. Function Design

- `snake_case` naming, verb-noun pattern
- Docstrings (Google style) on all non-trivial functions
- Default parameters, no magic numbers
- Type hints on function signatures

## 3. Domain Correctness

<!-- Customize for your field's known pitfalls -->
- Verify estimator implementations match slide formulas
- Check known package bugs (document below in Common Pitfalls)

## 4. Visual Identity

```python
# --- Your institutional palette ---
COLORS = {
    "primary_blue": "#012169",
    "primary_gold": "#f2a900",
    "accent_gray": "#525252",
    "positive_green": "#15803d",
    "negative_red": "#b91c1c",
}
```

### Figure Standards
```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(12, 5))
# ... plot ...
fig.savefig(filepath, dpi=300, bbox_inches="tight", transparent=True)
plt.close(fig)
```

## 5. Data Persistence

**Heavy computations saved as pickle or parquet; slides reference pre-computed results.**

```python
import pickle
with open(filepath, "wb") as f:
    pickle.dump(result, f)

# Or for DataFrames:
df.to_parquet(filepath)
```

## 6. Common Pitfalls

<!-- Add your field-specific pitfalls here -->
| Pitfall | Impact | Prevention |
|---------|--------|------------|
| Missing `transparent=True` | White boxes on slides | Always include in savefig() |
| Hardcoded paths | Breaks on other machines | Use relative paths or Path() |
| Missing random seed | Non-reproducible results | Set seed once at top |

## 7. Line Length & Mathematical Exceptions

**Standard:** Keep lines <= 100 characters.

**Exception: Mathematical Formulas** -- lines may exceed 100 chars **if and only if:**

1. Breaking the line would harm readability of the math
2. An inline comment explains the mathematical operation
3. The line is in a numerically intensive section

**Quality Gate Impact:**
- Long lines in non-mathematical code: minor penalty (-1 to -2 per line)
- Long lines in documented mathematical sections: no penalty

## 8. Code Quality Checklist

```
[ ] Imports at top, grouped correctly
[ ] Random seed set once at top
[ ] All paths relative
[ ] Functions documented (docstrings)
[ ] Figures: transparent bg, explicit dimensions, 300 DPI
[ ] Results saved (pickle/parquet)
[ ] Comments explain WHY not WHAT
```
