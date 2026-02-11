---
paths:
  - "paper/**/*.tex"
  - "prez/**/*.tex"
  - "quality_reports/**"
---

# Proofreading Agent Protocol (MANDATORY)

**Every paper or slide file MUST be reviewed before any commit or PR.**

**CRITICAL RULE: The agent must NEVER apply changes directly. It proposes all changes for review first.**

## What the Agent Checks

1. **Grammar** -- subject-verb agreement, missing articles, wrong prepositions
2. **Typos** -- misspellings, search-and-replace corruption, duplicated words
3. **Overflow** -- overfull hbox warnings, content exceeding page/slide boundaries
4. **Consistency** -- notation, citation style (`\citet` vs `\citep`), terminology
5. **Academic quality** -- informal abbreviations, missing words, awkward phrasing
6. **Figure/table references** -- `\ref{}` targets exist, all figures/tables are referenced in text
7. **Section cross-references** -- `\label{}`/`\ref{}` pairs are consistent

## Writing Style Standard

The agent enforces these preferences (see CLAUDE.md for full list):

- Minimal adverbs and adjectives; prefer strong verbs and nouns
- Limit prepositional phrases
- Prefer active voice whenever possible
- Minimal use of "to be" in all forms (is, are, were, was)
- Convert nominalizations into verbs
- No correlative conjunctions
- No bold subheadings, bold labels, or `\paragraph{}` markers in prose
- Create structure using paragraphs and transitions, not typographic emphasis
- Clear topic sentences for every paragraph

## Three-Phase Workflow

### Phase 1: Review & Propose (NO EDITS)

Each agent:
1. Reads the entire file
2. Produces a **report** with every proposed change:
   - Location (line number or section)
   - Current text
   - Proposed fix
   - Category (grammar / typo / overflow / consistency / style / reference)
3. Saves report to `quality_reports/` (e.g., `quality_reports/paper_proofread_report.md`)
4. **Does NOT modify any source files**

### Phase 2: Review & Approve

The user reviews the proposed changes:
- Accepts all, accepts selectively, or requests modifications
- **Only after explicit approval** does the agent proceed

### Phase 3: Apply Fixes

Apply only approved changes:
- Use Edit tool; use `replace_all: true` for issues with multiple instances
- Verify each edit succeeded
- Report completion summary
