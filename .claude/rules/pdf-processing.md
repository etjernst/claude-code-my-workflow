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

1. **Get page count** --- run PyPDF2 `len(reader.pages)`
2. **Extract full text** --- dump to `.txt` file via Python script
3. **Route by size:**
   - **Under 40 pages** --- standard pathway (below)
   - **40+ pages** --- chunked pathway (below)

### Standard Pathway (under 40 pages)

1. **Read the text file** --- use Read tool on the extracted `.txt`
2. **Visual spot-check** --- use Read tool with `pages` on the PDF if tables/figures need visual inspection
3. **Clean up** --- delete extracted text file when done

### Chunked Pathway (40+ pages)

Large documents overwhelm context. Process them in chunks, building structured notes incrementally.

**Step 1: Split into chunks (~15 pages each)**

Split the extracted `.txt` file using section boundaries when possible. Look for these markers in order of preference:

- Numbered sections (`1.`, `2.`, `1 Introduction`, `2 Data`)
- All-caps headings (`INTRODUCTION`, `METHODOLOGY`, `RESULTS`)
- Common academic headings (`Introduction`, `Literature Review`, `Data`, `Methodology`, `Empirical Strategy`, `Identification`, `Results`, `Discussion`, `Conclusion`, `References`, `Appendix`)

If no section headers are detected, fall back to page markers (`--- Page N ---`) and split at ~15-page intervals.

Write each chunk to a separate file: `paper_chunk_01.txt`, `paper_chunk_02.txt`, etc.

```python
# Splitting logic (adapt as needed)
import re

with open(r'path\to\paper_text.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# Try section headers first
section_pattern = re.compile(
    r'\n(?=(?:\d+\.?\s+[A-Z]|[A-Z]{4,}\s|'
    r'(?:Introduction|Literature Review|Data|'
    r'Methodology|Empirical Strategy|Identification|'
    r'Results|Discussion|Conclusion|References|'
    r'Appendix)\b))',
    re.MULTILINE
)
splits = [m.start() for m in section_pattern.finditer(text)]

if len(splits) < 3:
    # Fall back to page markers, ~15 pages per chunk
    page_pattern = re.compile(r'\n--- Page (\d+) ---')
    pages = [m.start() for m in page_pattern.finditer(text)]
    splits = pages[::15]

# Write chunks
splits = [0] + splits + [len(text)]
for i in range(len(splits) - 1):
    chunk = text[splits[i]:splits[i+1]]
    with open(f'path/to/paper_chunk_{i+1:02d}.txt',
              'w', encoding='utf-8') as f:
        f.write(chunk)
```

**Step 2: Process each chunk sequentially**

For each chunk file:
1. Read the chunk with the Read tool
2. Append structured notes to a working notes file (`paper_notes.md`) with:
   - **Section/pages covered**
   - **Key arguments and claims**
   - **Methods and data** (if applicable)
   - **Findings and evidence**
   - **Questions or items to revisit**
3. Drop the chunk from context (do not re-read previous chunks)

Notes file format:
```markdown
## Chunk 1: [Section name or page range]
- **Arguments:** ...
- **Methods:** ...
- **Findings:** ...
- **Questions:** ...
```

**Step 3: Synthesize from notes**

After all chunks are processed, work exclusively from `paper_notes.md`. Do not re-read the original text or chunks. The notes file is the working document for any downstream task (summarization, review, slide creation, etc.).

**Step 4: Visual spot-check**

Use the Read tool with `pages` on the original PDF for any tables, figures, or equations flagged in the notes as needing visual inspection.

**Step 5: Clean up**

Delete all chunk files and the extracted text file when done. Keep `paper_notes.md` if the user wants it for reference.

