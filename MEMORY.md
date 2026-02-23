# Project Memory

Corrections and learned facts that persist across sessions.
When a mistake is corrected, append a `[LEARN:category]` entry below.

---

<!-- Append new entries below. Most recent at bottom. -->

## Workflow patterns

[LEARN:workflow] Requirements specification phase catches ambiguity before planning---reduces rework 30-50%. Use spec-then-plan for complex/ambiguous tasks (>1 hour or >3 files).

[LEARN:workflow] Spec-then-plan protocol: AskUserQuestion (3-5 questions) → create `quality_reports/specs/YYYY-MM-DD_description.md` with MUST/SHOULD/MAY requirements → declare clarity status (CLEAR/ASSUMED/BLOCKED) → get approval → then draft plan.

[LEARN:workflow] Context survival before compression: (1) Update MEMORY.md with [LEARN] entries, (2) Ensure session log current (last 10 min), (3) Active plan saved to disk, (4) Open questions documented. The pre-compact hook displays checklist.

[LEARN:workflow] Plans, specs, and session logs must live on disk (not just in conversation) to survive compression and session boundaries. Quality reports only at merge time.

## Design philosophy

[LEARN:design] Framework-oriented > prescriptive rules. Constitutional governance works as a TEMPLATE with examples users customize to their domain.

[LEARN:design] Generic means working for any academic workflow: pure LaTeX, Python, Stata, any domain. Test recommendations across use cases.

## File organization

[LEARN:files] Specifications go in `quality_reports/specs/YYYY-MM-DD_description.md`. Templates belong in `templates/` with descriptive names.

## Memory system

[LEARN:memory] Two-tier memory: MEMORY.md (generic patterns, committed) and `.claude/state/personal-memory.md` (machine-specific, gitignored).
