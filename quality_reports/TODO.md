# Future Improvements

## Quality Scorer

- [ ] **Environment-aware runt detection** — Current orphan/runt checker only catches source-level runts (short trailing lines in the `.tex` source). It misses rendered runts where LaTeX reflows text into narrow environments (columns, tcolorbox). Fix: track current environment (full frame vs `\column{0.48}` vs tcolorbox), estimate effective text width in characters, concatenate source lines into paragraphs, simulate line breaks, and flag short final lines. Won't be pixel-perfect but would catch most cases.
