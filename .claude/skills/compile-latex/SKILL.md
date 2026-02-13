---
name: compile-latex
description: Compile a Beamer LaTeX slide deck with XeLaTeX (3 passes + bibtex) using MikTeX on Windows. Use when compiling lecture slides.
disable-model-invocation: true
argument-hint: "[filename without .tex extension]"
allowed-tools: ["Read", "Bash", "Glob"]
---

# Compile Beamer LaTeX Slides

Compile a Beamer slide deck using XeLaTeX with full citation resolution (MikTeX on Windows).

## Steps

1. **Navigate to Slides/ directory** and compile with 3-pass sequence:

```bash
cd Slides
xelatex --include-directory=../Preambles -interaction=nonstopmode $ARGUMENTS.tex
bibtex --include-directory=.. $ARGUMENTS
xelatex --include-directory=../Preambles -interaction=nonstopmode $ARGUMENTS.tex
xelatex --include-directory=../Preambles -interaction=nonstopmode $ARGUMENTS.tex
```

2. **Check for warnings:**
   - Grep output for `Overfull \\hbox` warnings
   - Grep for `undefined citations` or `Label(s) may have changed`
   - Report any issues found

3. **Open the PDF** for visual verification:
   ```bash
   start Slides/$ARGUMENTS.pdf
   ```

4. **Report results:**
   - Compilation success/failure
   - Number of overfull hbox warnings
   - Any undefined citations
   - PDF page count

## Why 3 passes?
1. First xelatex: Creates `.aux` file with citation keys
2. bibtex: Reads `.aux`, generates `.bbl` with formatted references
3. Second xelatex: Incorporates bibliography
4. Third xelatex: Resolves all cross-references with final page numbers

## Important
- **Always use XeLaTeX**, never pdflatex
- **`--include-directory`** is required (MikTeX syntax): your Beamer theme lives in `Preambles/`
- **bibtex `--include-directory`** is required: your `.bib` file lives in the repo root
