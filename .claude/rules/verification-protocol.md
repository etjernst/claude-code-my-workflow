---
paths:
  - "paper/**/*.tex"
  - "prez/**/*.tex"
  - "scripts/**/*.py"
---

# Task Completion Verification Protocol

**At the end of EVERY task, Claude MUST verify the output works correctly.** This is non-negotiable.

## For LaTeX Paper (paper/):
1. Compile with 3-pass xelatex + bibtex from `paper/` directory
2. Check for compilation errors and overfull hbox warnings
3. Open the PDF to verify figures and tables render: `start main.pdf`
4. Verify all `\ref{}` and `\cite{}` commands resolve (no "??" in output)
5. Report verification results

## For Beamer Slides (prez/):
1. Compile with 3-pass xelatex + bibtex from `prez/` directory
2. Set TEXINPUTS to `../Preambles:` and BIBINPUTS to `../paper:` for shared resources
3. Check for compilation errors and overfull hbox warnings
4. Open the PDF to verify: `start file.pdf`
5. Report verification results

## For Python Scripts (scripts/):
1. Check syntax with `python -m py_compile scripts/filename.py`
2. Verify all paths use `pathlib.Path` with relative references from project root
3. Confirm logging is configured (using `logging` module)
4. Verify output files (figures, tables) are directed to `output/figures/` or `output/tables/`
5. If Python is available, run: `python scripts/filename.py`
6. Check log output for errors

## Common Pitfalls:
- **Bibliography not found in slides**: prez/ needs BIBINPUTS=../paper: to find salinity.bib
- **Preamble not found**: Both paper/ and prez/ need TEXINPUTS=../Preambles: for shared style files
- **Assuming success**: Always verify output files exist AND contain correct content
- **Hardcoded paths in Python**: All paths should use pathlib.Path with relative references

## Verification Checklist:
```
[ ] Output file created successfully
[ ] No compilation/execution errors
[ ] Figures/tables display correctly
[ ] All references and citations resolve
[ ] Opened in viewer to confirm visual appearance
[ ] Reported results to user
```
