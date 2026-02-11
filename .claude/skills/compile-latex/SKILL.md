---
name: compile-latex
description: Compile a LaTeX file (paper or slides) with XeLaTeX (3 passes + bibtex). Works with files in paper/ or prez/.
disable-model-invocation: true
argument-hint: "[filename without .tex extension]"
allowed-tools: ["Read", "Bash", "Glob"]
---

# Compile LaTeX

Compile a LaTeX file using XeLaTeX with full citation resolution. Automatically detects whether the file is in `paper/` or `prez/`.

## Steps

1. **Determine the file location:**
   - If `$ARGUMENTS` contains a path (e.g., `prez/slides`), use that directory
   - If the file exists in `paper/`, compile from `paper/`
   - If the file exists in `prez/`, compile from `prez/`
   - Default to `paper/` if ambiguous

2. **Compile with 3-pass sequence:**

**For paper/ (bibliography is co-located):**
```bash
cd paper
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
bibtex $ARGUMENTS
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
```

**For prez/ (bibliography lives in paper/):**
```bash
cd prez
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
BIBINPUTS=../paper:$BIBINPUTS bibtex $ARGUMENTS
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
```

**Alternative (latexmk):**
```bash
cd [paper|prez]
TEXINPUTS=../Preambles:$TEXINPUTS BIBINPUTS=../paper:$BIBINPUTS latexmk -xelatex -interaction=nonstopmode $ARGUMENTS.tex
```

3. **Check for warnings:**
   - Grep output for `Overfull \\hbox` warnings
   - Grep for `undefined citations` or `Label(s) may have changed`
   - Report any issues found

4. **Open the PDF** for visual verification:
   ```bash
   start $ARGUMENTS.pdf
   ```

5. **Report results:**
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
- **TEXINPUTS** is required: shared style files live in `Preambles/`
- **BIBINPUTS** is needed for prez/ only: the `.bib` file lives in `paper/`
- For paper/, bibtex finds bibliography.bib in the same directory automatically
