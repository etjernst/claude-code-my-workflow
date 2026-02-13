---
paths:
  - "master_supporting_docs/**"
---

# PDF Processing

## Default: PyPDF2 Text Extraction

For text-heavy documents (papers, guidelines, syllabi), extract text with PyPDF2 — already installed in Anaconda. This is fast (~1s for 50 pages) and context-efficient (~30K tokens vs. massive image tokens).

```python
import PyPDF2
reader = PyPDF2.PdfReader(r'path\to\paper.pdf')
print(f'Pages: {len(reader.pages)}')
for i, page in enumerate(reader.pages):
    print(f'\n--- Page {i+1} ---')
    print(page.extract_text())
```

For large PDFs, extract to a text file first, then read the text file:

```python
import PyPDF2
reader = PyPDF2.PdfReader(r'path\to\paper.pdf')
with open(r'path\to\paper_text.txt', 'w', encoding='utf-8') as f:
    for i, page in enumerate(reader.pages):
        f.write(f'\n--- Page {i+1} ---\n')
        f.write(page.extract_text())
```

## Complement: Read Tool for Visual Inspection

Use the Read tool with `pages` parameter only when you need to see layout, figures, charts, or tables that don't extract well as text. Always specify `pages` — bare reads fail on PDFs over 10 pages.

```
Read tool: pages "1-5"   (TOC pass)
Read tool: pages "12-15" (specific figures)
```

**Max 20 pages per Read call.** For longer ranges, split into parallel batches.

## Processing Strategy

1. **Get page count** — run PyPDF2 `len(reader.pages)`
2. **Extract full text** — dump to `.txt` file via Python script
3. **Read the text file** — use Read tool on the extracted text
4. **Visual spot-check** — use Read tool with `pages` only if tables/figures need visual inspection
5. **Clean up** — delete extracted text file when done

