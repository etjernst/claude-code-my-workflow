# Workflow Quick Reference

**Project:** The Productive Cost of Salty Water
**Tools:** LaTeX (paper + slides), Python (analysis)
**Model:** Contractor (you direct, Claude orchestrates)

---

## The Loop

```
Your instruction
    |
[PLAN] (if multi-file or unclear) -> Show plan -> Your approval
    |
[EXECUTE] Implement, verify, done
    |
[REPORT] Summary + what's ready
    |
Repeat
```

---

## I Ask You When

- **Design forks:** "Option A (fast) vs. Option B (robust). Which?"
- **Code ambiguity:** "Spec unclear on X. Assume Y?"
- **Replication edge case:** "Just missed tolerance. Investigate?"
- **Scope question:** "Also refactor Y while here, or focus on X?"

---

## I Just Execute When

- Code fix is obvious (bug, pattern application)
- Verification (tolerance checks, compilation)
- Documentation (logs, commits)
- Plotting (per established standards)

---

## Quality Gates (No Exceptions)

| Score | Action |
|-------|--------|
| >= 80 | Ready to commit |
| < 80  | Fix blocking issues |

---

## Non-Negotiables

- **Paths:** Python scripts use relative paths from project root; LaTeX uses TEXINPUTS for Preambles/
- **Figures:** Publication-ready, polished, beautiful. All output to output/figures/
- **Tables:** All output to output/tables/
- **Writing style:** Active voice, strong verbs, no nominalizations, no bold subheadings, no `\paragraph{}`
- **Tolerance thresholds:** 1e-6 for point estimates, 1e-4 for SEs

---

## Skills

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex (paper/ or prez/) |
| `/proofread [file]` | Grammar, style, citation, reference review |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/validate-bib` | Cross-reference citations against bibliography |
| `/review-paper [file]` | Manuscript review with econometric focus |

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed -- just a research value check (2 min)
- See `.claude/rules/exploration-fast-track.md`

---

## Next Step

You provide task -> I plan (if needed) -> Your approval -> Execute -> Done.
