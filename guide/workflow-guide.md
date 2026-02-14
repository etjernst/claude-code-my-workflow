# Workflow Reference

Internal reference for the Claude Code academic workflow. Covers how tasks flow, what each configuration layer does, and what's in the repo.

---

## Task Flow

Every non-trivial task follows the same loop, regardless of file type:

```
Task arrives
  |
  +-- PLAN: Enter plan mode, draft approach, save to quality_reports/plans/
  +-- APPROVE: User reviews and approves
  +-- IMPLEMENT: Execute the plan
  +-- VERIFY: Compile LaTeX / run Python / run Stata — check output
  +-- REVIEW: Run agents matched to file types (see Agent Selection below)
  +-- FIX: Apply fixes (critical → major → minor)
  +-- RE-VERIFY: Confirm fixes are clean
  +-- SCORE: Run quality_score.py — must hit 80/100 to commit
  +-- Loop to REVIEW if score < 80 (max 5 rounds)
```

**"Just do it" mode:** Same loop, but skips the final approval pause and auto-commits if score >= 80.

**Limits:** Max 5 review-fix rounds. Max 2 verification retries.

---

## Agent Selection

The orchestrator picks agents based on which files were modified:

| Files Modified | Agents Run |
|---------------|------------|
| `.tex` | proofreader, slide-auditor, pedagogy-reviewer |
| `.py` | python-reviewer |
| `.do` | stata-reviewer |
| TikZ code in `.tex` | tikz-reviewer (in addition to above) |
| Domain content | domain-reviewer (if configured) |

All review agents run in parallel. The `/slide-excellence` skill runs all slide agents explicitly.

---

## Quality Scoring

`python scripts/quality_score.py <file>` scores files from 0 to 100.

### Thresholds

| Score | Gate | Effect |
|-------|------|--------|
| 80+ | Commit | `git commit` allowed |
| 90+ | PR | `gh pr create` encouraged |
| 95+ | Excellence | Aspirational |
| < 80 | Blocked | Must fix before committing |

### Actual Deductions (from `quality_score.py`)

**Beamer/LaTeX:**

| Check | Deduction | How Detected |
|-------|-----------|-------------|
| LaTeX syntax error (mismatched environments) | -100 (auto-fail) | Regex env stack matching |
| Undefined citation key | -15 per key | Cross-reference against `.bib` |
| Overfull hbox risk (>120 chars in frame) | -10 per line | Line length in `\begin{frame}...\end{frame}` |
| Equation overflow (>120 chars) | -10 per line | Line length in math environments |

**Python:**

| Check | Deduction | How Detected |
|-------|-----------|-------------|
| Syntax error | -100 (auto-fail) | `py_compile` |
| Hardcoded absolute path | -20 per line | Regex for `/Users/`, `C:\`, etc. |
| Missing random seed | -10 | Detects `np.random`/`random.` without seed call |
| Missing module docstring | -5 | Checks first non-comment line |
| Missing `__name__` guard | -3 | Functions defined but no main guard |

**Stata:**

| Check | Deduction | How Detected |
|-------|-----------|-------------|
| Hardcoded absolute path | -20 per line | Same regex as Python |
| Missing `clear all` | -10 | Not found in first 20 lines |
| Missing `set seed` (when randomness detected) | -10 | Bootstrap/simulate/etc. without seed |
| Missing header comment | -5 | No `*` or `//` in first 5 lines |
| Missing log file | -5 | No `log using` or `cmdlog using` |

These are automated, lightweight checks. Review agents catch deeper issues (notation consistency, pedagogy, code-theory alignment) that the script cannot.

---

## Configuration Layers

### CLAUDE.md

Loaded every session. Keep under ~150 lines — Claude follows ~100-150 custom instructions total, shared between CLAUDE.md and always-on rules. Contains: project name, folder structure, commands, Beamer environments, project state, skill reference.

### Rules (`.claude/rules/`)

Markdown files auto-loaded by Claude. Two types:

**Always-on** (no `paths:` frontmatter — load every session, ~100 lines total):

| Rule | What It Does |
|------|-------------|
| `plan-first-workflow.md` | Plan mode before non-trivial tasks, context preservation |
| `orchestrator-protocol.md` | Implement → verify → review → fix → score loop |
| `session-logging.md` | Log after plan approval, incrementally, and at session end |

**Path-scoped** (load only when working on matching file patterns):

| Rule | Triggers On | What It Does |
|------|------------|-------------|
| `quality-gates.md` | `slides/**/*.tex`, `scripts/**/*.py`, `stata/**/*.do` | 80/90/95 scoring thresholds |
| `verification-protocol.md` | `slides/**/*.tex`, `scripts/**/*.py`, `stata/**/*.do` | Must compile/run before reporting done |
| `python-code-conventions.md` | `**/*.py` | Python coding standards |
| `stata-code-conventions.md` | `**/*.do` | Stata coding standards |
| `replication-protocol.md` | `scripts/**/*.py`, `stata/**/*.do` | Replicate original results before extending |
| `single-source-of-truth.md` | `figures/**/*`, `slides/**/*.tex` | No content duplication |
| `proofreading-protocol.md` | `slides/**/*.tex`, `quality_reports/**` | Propose changes first, apply after approval |
| `no-pause-beamer.md` | `slides/**/*.tex` | No overlay commands in Beamer |
| `tikz-visual-quality.md` | `slides/**/*.tex` | TikZ diagram standards |
| `knowledge-base-template.md` | `slides/**/*.tex`, `scripts/**/*.py`, `stata/**/*.do` | Notation and application registry |
| `pdf-processing.md` | `master_supporting_docs/**` | PyPDF2 for text, Read tool for visuals |
| `orchestrator-research.md` | `scripts/**/*.py`, `stata/**/*.do`, `explorations/**` | Simplified orchestrator for research code |
| `exploration-folder-protocol.md` | `explorations/**` | Structured sandbox with archive lifecycle |
| `exploration-fast-track.md` | `explorations/**` | 60/100 threshold for rapid prototyping |

### Skills (`.claude/skills/`)

Slash commands that run multi-step workflows. Each lives in `.claude/skills/<name>/SKILL.md`.

**Slides:**

| Skill | What It Does |
|-------|-------------|
| `/compile-latex` | 3-pass XeLaTeX + bibtex (MikTeX) |
| `/extract-tikz` | TikZ diagrams to PDF to SVG |
| `/proofread` | Grammar, typos, overflow review |
| `/visual-audit` | Slide layout audit |
| `/pedagogy-review` | Narrative arc, notation, pacing |
| `/slide-excellence` | All slide agents in parallel |
| `/validate-bib` | Cross-reference citations against `.bib` |
| `/devils-advocate` | Challenge design with pedagogical questions |
| `/create-lecture` | Full lecture creation workflow |

**Code:**

| Skill | What It Does |
|-------|-------------|
| `/review-python` | Python code quality review |
| `/review-stata` | Stata .do file quality review |
| `/data-analysis` | End-to-end Python/Stata analysis pipeline |

**Research:**

| Skill | What It Does |
|-------|-------------|
| `/lit-review` | Literature search, synthesis, gap identification |
| `/research-ideation` | Generate research questions and empirical strategies |
| `/interview-me` | Interactive interview to formalize a research idea |
| `/review-paper` | Manuscript review with referee objections |

**Workflow:**

| Skill | What It Does |
|-------|-------------|
| `/commit` | Stage, commit, create PR, merge to main |

### Agents (`.claude/agents/`)

Each agent reviews one dimension. They give directions, not code.

| Agent | Scope |
|-------|-------|
| `proofreader` | Grammar, typos, overflow, consistency |
| `slide-auditor` | Visual layout, spacing, box fatigue |
| `pedagogy-reviewer` | Narrative arc, prerequisites, notation clarity, pacing |
| `python-reviewer` | Code quality, reproducibility, project compliance |
| `stata-reviewer` | Code quality, reproducibility, conventions |
| `tikz-reviewer` | Label positions, overlap, visual consistency |
| `verifier` | Task completion — did it compile, run, produce output? |
| `domain-reviewer` | **Template** — customize 5 lenses for your field |

**Model selection:** Agents default to `model: inherit`. Override in YAML frontmatter: `model: opus` for deep review, `model: haiku` for fast constrained tasks.

### Hooks (`.claude/settings.json`)

Command-based hooks — no LLM calls, no latency.

| Hook | Event | What It Does |
|------|-------|-------------|
| `notify.sh` | Notification | Toast notification when Claude needs attention |
| `protect-files.sh` | PreToolUse (Edit/Write) | Blocks edits to protected files |
| `pre-compact.sh` | PreCompact | Saves context to disk before auto-compression |
| `log-reminder.py` | Stop | Reminds Claude to create/update session logs |

### Memory

| Layer | Location | Survives Compression? |
|-------|----------|----------------------|
| Project config | `CLAUDE.md` | Yes (on disk) |
| Corrections | `MEMORY.md` (auto-memory) | Yes (on disk) |
| Plans | `quality_reports/plans/` | Yes (on disk) |
| Session logs | `quality_reports/session_logs/` | Yes (on disk) |
| Conversation | Claude's context window | No |

Corrections use `[LEARN:tag]` format in MEMORY.md. Plans and session logs are written to disk so they survive context compression and session boundaries.

---

## Exploration Workflow

All experimental work goes in `explorations/` with a lower quality bar:

| Question | Workflow | Threshold |
|----------|----------|-----------|
| Will this ship? | Plan-First | 80/100 |
| Am I testing an idea? | Fast-Track | 60/100 |

```
explorations/
+-- [active-project]/
|   +-- README.md       # Goal, hypotheses, status
|   +-- python/         # Python iterations
|   +-- stata/          # Stata .do files
|   +-- output/         # Results
+-- ARCHIVE/
    +-- completed_*/    # Graduated to production
    +-- abandoned_*/    # Documented why stopped
```

Kill switch: stop, archive with a one-paragraph explanation, move on.

---

## Replication Protocol

When working with papers that have replication packages:

1. **Inventory** original code — record gold-standard numbers (Table X, Column Y = Z.ZZ)
2. **Translate** (e.g., Stata to Python) — match original specification exactly
3. **Verify** — compare every target. Tolerance: < 0.01 for estimates, < 0.05 for SEs. Mismatch = stop and investigate.
4. **Extend** only after match confirmed — new estimators, specifications, figures

---

## Context Management

- **Prefer auto-compression** over `/clear` — auto-compression keeps important context, `/clear` destroys everything
- **Save to disk** before compression: plans, session logs, design decisions
- **Session recovery:** Read CLAUDE.md + most recent plan + `git log --oneline -10` + `git diff`
