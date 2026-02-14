# My Claude Code Setup

> **Work in progress.** This is how I use Claude Code for academic work — creating lecture slides, running Stata and Python analyses, and managing LaTeX/Beamer workflows. I keep updating these files as I learn. Sharing with friends and colleagues.

A starter kit for academics using [Claude Code](https://code.claude.com/docs/en/overview) with **LaTeX/Beamer + Stata + Python**. Clone it for each new project, keep the link for workflow updates. You describe what you want; Claude plans the approach, runs specialized agents, fixes issues, verifies quality, and presents results — like a contractor who handles the entire job.

---

## Quick Start (5 minutes)

### 1. Clone & Set Up Remotes

```bash
# Clone the workflow repo as a new project:
git clone https://github.com/etjernst/claude-code-my-workflow.git my-project
cd my-project

# Keep the workflow repo as 'workflow' remote (for pulling updates later):
git remote rename origin workflow

# Point 'origin' to your new project repo:
git remote add origin https://github.com/YOUR_USERNAME/my-project.git
git push -u origin main
```

To pull workflow improvements into an existing project later:
```bash
git fetch workflow && git merge workflow/main
```

### 2. Start Claude Code and Paste This Prompt

```bash
claude
```

**Using VS Code?** Open the Claude Code panel instead.

Then paste the following, filling in your project details:

> I am starting to work on **[PROJECT NAME]** in this repo. **[Describe your project in 2-3 sentences -- what you're building, who it's for, what tools you use.]**
>
> I want our collaboration to be structured, precise, and rigorous. When creating visuals, everything must be polished and publication-ready.
>
> I've set up the Claude Code academic workflow (forked from `pedrohcgs/claude-code-my-workflow`). The configuration files are already in this repo. Please read them, understand the workflow, and then **update all configuration files to fit my project** -- fill in placeholders in `CLAUDE.md`, adjust rules if needed, and propose any customizations specific to my use case.
>
> After that, use the plan-first workflow for all non-trivial tasks. Once I approve a plan, switch to contractor mode -- coordinate everything autonomously and only come back to me when there's ambiguity or a decision to make.
>
> Enter plan mode and start by adapting the workflow configuration for this project.

**What this does:** Claude reads all the configuration files, fills in your project name, institution, and preferences, then enters contractor mode. You approve the plan and Claude handles the rest.

---

## How It Works

### Contractor Mode

You describe a task. Claude plans the approach, implements it, runs specialized review agents, fixes issues, re-verifies, and scores against quality gates -- all autonomously. You see a summary when the work meets quality standards. Say "just do it" and it auto-commits too.

### Specialized Agents

Instead of one general-purpose reviewer, 8 focused agents each check one dimension:

- **proofreader** -- grammar/typos
- **slide-auditor** -- visual layout
- **pedagogy-reviewer** -- teaching quality
- **python-reviewer** -- Python code quality
- **stata-reviewer** -- Stata .do file quality
- **domain-reviewer** -- field-specific correctness (template -- customize for your field)

Each is better at its narrow task than a generalist would be. The `/slide-excellence` skill runs them all in parallel.

### Quality Gates

Every file gets a score (0-100). Scores below threshold block the action:
- **80** -- commit threshold
- **90** -- PR threshold
- **95** -- excellence (aspirational)

---

## What's Included

<details>
<summary><strong>8 agents, 17 skills, 17 rules, 4 hooks</strong> (click to expand)</summary>

### Agents (`.claude/agents/`)

| Agent | What It Does |
|-------|-------------|
| `proofreader` | Grammar, typos, overflow, consistency review |
| `slide-auditor` | Visual layout audit (overflow, font consistency, spacing) |
| `pedagogy-reviewer` | Pedagogical review (narrative arc, notation density, pacing) |
| `python-reviewer` | Python code quality, reproducibility, and domain correctness |
| `stata-reviewer` | Stata .do file quality, reproducibility, and conventions |
| `tikz-reviewer` | TikZ diagram visual critique |
| `verifier` | End-to-end task completion verification |
| `domain-reviewer` | **Template** for your field-specific substance reviewer |

### Skills (`.claude/skills/`)

| Skill | What It Does |
|-------|-------------|
| `/compile-latex` | 3-pass XeLaTeX compilation with bibtex (MikTeX) |
| `/extract-tikz` | TikZ diagrams to PDF to SVG pipeline |
| `/proofread` | Launch proofreader on a file |
| `/visual-audit` | Launch slide-auditor on a file |
| `/pedagogy-review` | Launch pedagogy-reviewer on a file |
| `/review-python` | Launch Python code reviewer |
| `/review-stata` | Launch Stata .do file reviewer |
| `/slide-excellence` | Combined multi-agent review |
| `/validate-bib` | Cross-reference citations against bibliography |
| `/devils-advocate` | Challenge design decisions before committing |
| `/create-lecture` | Full lecture creation workflow |
| `/commit` | Stage, commit, create PR, and merge to main |
| `/lit-review` | Literature search, synthesis, and gap identification |
| `/research-ideation` | Generate research questions and empirical strategies |
| `/interview-me` | Interactive interview to formalize a research idea |
| `/review-paper` | Manuscript review: structure, econometrics, referee objections |
| `/data-analysis` | End-to-end Python/Stata analysis with publication-ready output |

### Research Workflow

| Feature | What It Does |
|---------|-------------|
| Exploration folder | Structured `explorations/` sandbox with graduate/archive lifecycle |
| Fast-track workflow | 60/100 quality threshold for rapid prototyping |
| Simplified orchestrator | implement, verify, score, done (no multi-round reviews) |
| Enhanced session logging | Structured tables for changes, decisions, verification |
| Merge-only reporting | Quality reports at merge time only |
| Math line-length exception | Long lines acceptable for documented formulas |
| Workflow quick reference | One-page cheat sheet at `.claude/WORKFLOW_QUICK_REF.md` |

### Rules (`.claude/rules/`)

Rules use path-scoped loading: **always-on** rules load every session (~100 lines total); **path-scoped** rules load only when Claude works on matching files.

**Always-on** (no `paths:` frontmatter -- load every session):

| Rule | What It Enforces |
|------|-----------------|
| `plan-first-workflow` | Plan mode for non-trivial tasks + context preservation |
| `orchestrator-protocol` | Contractor mode: implement, verify, review, fix, score |
| `session-logging` | Three logging triggers: post-plan, incremental, end-of-session |

**Path-scoped** (load only when working on matching files):

| Rule | Triggers On | What It Enforces |
|------|------------|-----------------|
| `verification-protocol` | `.tex`, `*.py`, `*.do` | Task completion checklist |
| `single-source-of-truth` | `figures/`, `.tex` | No content duplication; Beamer is authoritative |
| `quality-gates` | `.tex`, `*.py`, `*.do` | 80/90/95 scoring + tolerance thresholds |
| `python-code-conventions` | `*.py` | Python coding standards |
| `stata-code-conventions` | `*.do` | Stata coding standards |
| `tikz-visual-quality` | `.tex` | TikZ diagram visual standards |
| `pdf-processing` | `master_supporting_docs/` | PyPDF2 text extraction + Read tool visual fallback |
| `proofreading-protocol` | `.tex`, `quality_reports/` | Propose-first, then apply with approval |
| `no-pause-beamer` | `.tex` | No overlay commands in Beamer |
| `replication-protocol` | `*.py`, `*.do` | Replicate original results before extending |
| `knowledge-base-template` | `.tex`, `*.py`, `*.do` | Notation/application registry template |
| `orchestrator-research` | `*.py`, `*.do`, `explorations/` | Simple orchestrator for research |
| `exploration-folder-protocol` | `explorations/` | Structured sandbox for experimental work |
| `exploration-fast-track` | `explorations/` | Lightweight exploration workflow (60/100 threshold) |

**Templates** (`templates/`) -- reference formats for session logs, quality reports, and exploration READMEs. Not auto-loaded.

### Hooks (`.claude/settings.json`)

| Hook | Type | What It Does |
|------|------|-------------|
| `notify.sh` | Notification | Toast notification when Claude needs attention |
| `protect-files.sh` | PreToolUse | Blocks edits to protected files (raw data, configs) |
| `pre-compact.sh` | PreCompact | Saves context to disk before auto-compression |
| `log-reminder.py` | Stop | Reminds to create session log if none exists |

</details>

---

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| [Claude Code](https://code.claude.com/docs/en/overview) | Everything | `npm install -g @anthropic-ai/claude-code` |
| XeLaTeX | LaTeX compilation | [MikTeX](https://miktex.org/download) (Windows) or [TeX Live](https://tug.org/texlive/) |
| [Stata](https://www.stata.com/) | Econometrics / data analysis | Licensed software |
| [Python (Anaconda)](https://www.anaconda.com/) | Analysis scripts, PDF processing | [anaconda.com](https://www.anaconda.com/download) |
| [gh CLI](https://cli.github.com/) | PR workflow | `winget install GitHub.cli` (Windows) |

Not all tools are needed -- install only what your project uses. Claude Code is the only hard requirement.

---

## Adapting for Your Field

1. **Fill in the knowledge base** (`.claude/rules/knowledge-base-template.md`) with your notation, applications, and design principles
2. **Customize the domain reviewer** (`.claude/agents/domain-reviewer.md`) with review lenses specific to your field
3. **Add field-specific coding pitfalls** to `.claude/rules/python-code-conventions.md` or `.claude/rules/stata-code-conventions.md`
4. **Customize the workflow quick reference** (`.claude/WORKFLOW_QUICK_REF.md`) with your non-negotiables and preferences
5. **Set up the exploration folder** (`explorations/`) for experimental work

---

## Additional Resources

- [Claude Code Documentation](https://code.claude.com/docs/en/overview)
- [Writing a Good CLAUDE.md](https://code.claude.com/docs/en/memory) -- official guidance on project memory

---

## Origin

This infrastructure was extracted from **Econ 730: Causal Panel Data** at Emory University, developed by Pedro Sant'Anna using Claude Code. The original project used R + Quarto + Beamer and produced 6 complete PhD lecture decks with 800+ slides. This fork has been adapted for a **Stata + Python + LaTeX/Beamer** workflow on Windows.

---

## License

MIT License. Use freely for teaching, research, or any academic purpose.
