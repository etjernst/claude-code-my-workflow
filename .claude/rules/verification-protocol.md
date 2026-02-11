---
paths:
  - "paper/**/*.tex"
  - "prez/**/*.tex"
  - "scripts/**/*.do"
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

## For Stata Scripts (scripts/):
1. Check that the .do file has no obvious syntax errors
2. Verify globals/paths reference project directory structure
3. Confirm log file open/close commands are present
4. Verify output files (figures, tables) are directed to `output/figures/` or `output/tables/`
5. If Stata is available, run: `stata-mp -b do scripts/filename.do`
6. Check log file for errors

## Common Pitfalls:
- **Bibliography not found in slides**: prez/ needs BIBINPUTS=../paper: to find bibliography.bib
- **Preamble not found**: Both paper/ and prez/ need TEXINPUTS=../Preambles: for shared style files
- **Assuming success**: Always verify output files exist AND contain correct content
- **Hardcoded paths in Stata**: All paths should use globals set in master.do

## Verification Checklist:
```
[ ] Output file created successfully
[ ] No compilation/execution errors
[ ] Figures/tables display correctly
[ ] All references and citations resolve
[ ] Opened in viewer to confirm visual appearance
[ ] Reported results to user
```
