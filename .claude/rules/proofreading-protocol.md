---
paths:
  - "slides/**/*.tex"
  - "projects/**/*.md"
  - "projects/**/*.tex"
  - "quality_reports/**"
---

# Proofreading agent protocol (mandatory)

**Every document file MUST be reviewed before any commit or PR.**

**CRITICAL RULE: The agent must NEVER apply changes directly. It proposes all changes for review first.**

## What the agent checks

1. Grammar---subject-verb agreement, missing articles, wrong prepositions
2. Passive voice---flag every passive construction, propose active alternative (high priority)
3. Typos---misspellings, search-and-replace corruption, duplicated words
4. Formatting---overflow (LaTeX), heading hierarchy (Markdown), dash usage
5. Consistency---notation, citation style, terminology, heading case (sentence case only)
6. Writing style---no bold labels, no nominalizations, strong verbs, flush em dashes, no orphan words

## Three-phase workflow

### Phase 1: Review and propose (no edits)

Each agent:
1. Reads the entire file
2. Produces a report with every proposed change:
   - Location (line number or section heading)
   - Current text
   - Proposed fix
   - Category (grammar / passive voice / typo / formatting / consistency / writing style)
3. Saves report to `quality_reports/` (e.g., `quality_reports/filename_report.md`)
4. Does NOT modify any source files

### Phase 2: Review and approve

The user reviews the proposed changes:
- Accepts all, accepts selectively, or requests modifications
- Only after explicit approval does the agent proceed

### Phase 3: Apply fixes

Apply only approved changes:
- Use Edit tool; use `replace_all: true` for issues with multiple instances
- Verify each edit succeeded
- Report completion summary
