# My Claude Code Setup

**A Comprehensive Guide to Multi-Agent Slide Development, Code Review, and Research Automation**

*Last updated: 2026-02-13*

---

## 1. Why This Workflow Exists

### The Problem

If you've ever built lecture slides, you know the pain:

- **Context loss between sessions.** You pick up where you left off, but Claude doesn't remember *why* you chose that notation, *what* the instructor approved, or *which* bugs were fixed last time.
- **Quality is inconsistent.** One slide has perfect spacing; the next overflows. Citations compile in Overleaf but break locally. Figures look great on your screen but pixelated on a projector.
- **Review is manual and exhausting.** You proofread 140 slides by hand. You miss a typo in an equation. A student catches it during lecture.
- **No one checks the math.** Grammar checkers catch "teh" but not a flipped sign in a decomposition theorem.

This workflow solves all of these problems. You describe what you want --- "create a new lecture on synthetic control" or "run the replication analysis for Table 2" --- and Claude handles the rest: plans the approach, implements it, runs specialized reviewers, fixes issues, verifies quality, and presents results. Like a contractor who manages the entire job.

### What Makes Claude Code Different

Claude Code runs on your computer with full access to your file system, terminal, and git. It works as a **CLI tool**, a **VS Code extension**, or through the **Claude Desktop app** --- same capabilities, same configuration, different interface. Here is what that enables:

| Capability | What It Means for You |
|-----------|----------------------|
| Read & edit your files | Surgical edits to `.tex`, `.py`, `.do` files in place |
| Run shell commands | Compile LaTeX, run Python/Stata scripts --- directly |
| Access git history | Commits, PRs, branches --- all from the conversation |
| Persistent memory | CLAUDE.md + MEMORY.md survive across sessions |
| Orchestrator mode | Claude autonomously plans, implements, reviews, fixes, and verifies |
| Multi-agent workflows | 8 specialized agents for proofreading, layout, pedagogy, code review |
| Quality gates | Automated scoring --- nothing ships below 80/100 |

> **Note:** You don't need all of this on day one. This guide describes the full system --- 8 agents, 17 skills, 17 rules. That is the ceiling, not the floor. **Start with just CLAUDE.md and 2--3 skills** (`/compile-latex`, `/proofread`, `/commit`). Add rules and agents as you discover what you need. The template is designed for progressive adoption: fork it, fill in the placeholders, and start working. Everything else is there when you're ready.

---

## 2. Getting Started

You need two things: fork the repo, and paste a prompt. Claude handles everything else.

### Step 1: Fork & Clone

```bash
# Fork this repo on GitHub (click "Fork" on the repo page), then:
git clone https://github.com/YOUR_USERNAME/claude-code-my-workflow.git my-project
cd my-project
```

Replace `YOUR_USERNAME` with your GitHub username.

### Step 2: Start Claude Code and Paste This Prompt

Open your terminal in the project directory, run `claude`, and paste the following. Fill in the **bolded placeholders** with your project details:

<details>
<summary><strong>Using VS Code or Claude Desktop instead of the terminal?</strong></summary>

Everything in this guide works the same in any Claude Code interface. In **VS Code**, open the Claude Code panel (click the Claude icon in the sidebar or press Cmd+Shift+P / Ctrl+Shift+P and search for "Claude Code: Open"). In **Claude Desktop**, open your project folder and start a local session. Then paste the starter prompt below.

The guide shows terminal commands because they are the most universal way to explain things, but every skill, agent, hook, and rule works identically regardless of which interface you use.

</details>

**Starter Prompt:**

> I am starting to work on **[PROJECT NAME]** in this repo. **[Describe your project in 2--3 sentences --- what you're building, who it's for, what tools you use (e.g., LaTeX/Beamer, Stata, Python).]**
>
> I want our collaboration to be structured, precise, and rigorous --- even if it takes more time. When creating visuals, everything must be polished and publication-ready. I don't want to repeat myself, so our workflow should be smart about remembering decisions and learning from corrections.
>
> I've set up the Claude Code academic workflow (forked from `pedrohcgs/claude-code-my-workflow`). The configuration files are already in this repo (`.claude/`, `CLAUDE.md`, templates, scripts). Please read them, understand the workflow, and then **update all configuration files to fit my project** --- fill in placeholders in `CLAUDE.md`, adjust rules if needed, and propose any customizations specific to my use case.
>
> After that, use the plan-first workflow for all non-trivial tasks. Once I approve a plan, switch to contractor mode --- coordinate everything autonomously and only come back to me when there's ambiguity or a decision to make. For our first few sessions, check in with me a bit more often so I can learn how the workflow operates.
>
> Enter plan mode and start by adapting the workflow configuration for this project.

**What this does:** Claude will read `CLAUDE.md` and all the rules, fill in your project name, institution, Beamer environments, and project state table, then propose any rule adjustments for your specific use case. You approve the plan, and Claude handles the rest. From there, you just describe what you want to build.

### Optional: Manual Setup

If you prefer to configure things yourself instead of letting Claude handle it:

<details>
<summary><strong>Manual Configuration Steps</strong></summary>

**Customize CLAUDE.md** --- Open `CLAUDE.md` and replace all `[BRACKETED PLACEHOLDERS]`:

1. **Project name and institution**
2. **Folder structure** (adjust to your layout)
3. **Current project state** (your lectures/papers)
4. **Beamer environments** (your custom LaTeX environments)

**Create your knowledge base** --- Open `.claude/rules/knowledge-base-template.md` and fill in:

1. **Notation registry** --- every symbol you use, where it's introduced, and anti-patterns
2. **Applications database** --- datasets, papers, and packages you reference
3. **Design principles** --- what you've approved and what you've overridden

**Configure permissions** --- Review `.claude/settings.json`. The template includes permissions for git, LaTeX, Python, Stata, and utility scripts. Add any additional tools you use.

**Test it:**

```bash
# In Claude Code, type:
/compile-latex MyFirstLecture
/proofread slides/MyFirstLecture.tex
python scripts/quality_score.py slides/MyFirstLecture.tex
```

</details>

> **Tip:** You don't need to fill everything in upfront. Start with 5--10 notation entries and add more as you develop lectures. The starter prompt will set up the essentials --- you can always refine later.

---

## 3. The System in Action

With setup covered, here is what the system actually *does*. This section walks through the core mechanisms: specialized agents, automatic quality scoring, and the orchestrator.

### Why Specialized Agents Beat One-Size-Fits-All

Consider proofreading a 140-slide lecture deck. You could ask Claude:

> "Review these slides for grammar, layout, math correctness, code quality, and pedagogical flow."

Claude will skim everything and catch some issues. But it will miss:

- The equation on slide 42 where a subscript changed from $m_t^{d=0}$ to $m_t^0$
- The TikZ diagram where two labels overlap at presentation resolution
- The Python script that uses `k=10` covariates but the slide says `k=5`

Now compare with specialized agents:

| Agent | Focus | What It Catches |
|-------|-------|-----------------|
| `proofreader` | Grammar only | "principle" vs "principal" |
| `slide-auditor` | Layout only | Text overflow on slide 37 |
| `pedagogy-reviewer` | Flow only | Missing framing sentence before Theorem 3.1 |
| `python-reviewer` | Code only | Missing `np.random.seed()` |
| `domain-reviewer` | Substance | Slide says 10,000 MC reps, code runs 1,000 |

Each agent reads the same file but examines a different dimension with full attention. The `/slide-excellence` skill runs them all in parallel.

### The Orchestrator: Coordinating Agents Automatically

Individual agents are specialists. Skills like `/slide-excellence` coordinate a few agents for specific tasks. But in day-to-day work, you should not have to think about which agents to run. That is the orchestrator's job.

The **orchestrator protocol** (`.claude/rules/orchestrator-protocol.md`) is an auto-loaded rule that activates after any plan is approved. It implements the plan, runs the verifier, selects review agents based on file types, applies fixes, re-verifies, and scores against quality gates. It loops until the score meets threshold or max rounds are exhausted.

You never invoke the orchestrator manually --- it is the default mode of operation for any non-trivial task. Skills remain available for standalone use (e.g., `/proofread` for a quick grammar check), but the orchestrator handles the full lifecycle automatically.

### Quality Scoring: The 80/90/95 System

Every file gets a quality score from 0 to 100:

| Score | Threshold | Meaning | Action |
|-------|-----------|---------|--------|
| **80+** | Commit | Safe to save progress | `git commit` allowed |
| **90+** | PR | Ready for deployment | `gh pr create` encouraged |
| **95+** | Excellence | Exceptional quality | Aspirational target |
| **< 80** | Blocked | Critical issues exist | Must fix before committing |

Points are deducted for issues:

| Issue | Deduction | Why Critical |
|-------|-----------|-------------|
| Compilation failure | -100 | Unusable output |
| Broken citation | -15 | Academic integrity |
| Equation typo | -10 | Teaches wrong content |
| Text overflow | -5 | Content cut off |
| Label overlap | -5 | Diagram illegible |
| Notation inconsistency | -3 | Student confusion |

The verification protocol (`.claude/rules/verification-protocol.md`) requires that Claude compile or run every output before reporting a task as complete. The orchestrator enforces this as an explicit step in its loop. This means Claude **cannot** say "done" without actually checking the output.

### Creating Your Own Domain Reviewer

The template includes `domain-reviewer.md` --- a skeleton for building a substance reviewer specific to your field.

Every domain can benefit from five review lenses:

| Lens | What It Checks | Example (Economics) | Example (Physics) |
|------|---------------|--------------------|--------------------|
| **Assumption Audit** | Are stated assumptions sufficient? | Is overlap required for ATT? | Is the adiabatic approximation valid here? |
| **Derivation Check** | Does the math check out? | Do decomposition terms sum? | Do the units balance? |
| **Citation Fidelity** | Do slides match cited papers? | Is the theorem from the right paper? | Is the experimental setup correctly described? |
| **Code-Theory Alignment** | Does code implement the formula? | Python script matches the slide equation? | Simulation parameters match theory? |
| **Logic Chain** | Does the reasoning flow? | Can a PhD student follow backwards? | Are prerequisites established? |

To customize, open `.claude/agents/domain-reviewer.md` and fill in your domain's checks.

---

## 4. The Building Blocks

Understanding the configuration layers helps you customize the workflow and debug when things go wrong.

### CLAUDE.md --- Your Project's Constitution

`CLAUDE.md` is the single most important file. Claude reads it at the start of every session. But here is the critical insight: **Claude reliably follows about 100--150 custom instructions.** Your system prompt already uses ~50, leaving ~100--150 for your project. CLAUDE.md and always-on rules share this budget.

This means CLAUDE.md should be a **slim constitution** --- short directives and pointers, not comprehensive documentation. Aim for ~120 lines:

- **Core principles** --- 4--5 bullets (plan-first, verify-after, quality gates, LEARN tags)
- **Folder structure** --- where everything lives
- **Commands** --- compilation, analysis, key tools
- **Customization tables** --- Beamer environments
- **Current state** --- what's done, what's in progress
- **Skill quick reference** --- table of available slash commands

Move everything else into `.claude/rules/` files (with path-scoping so they only load when relevant).

> **Important:** Keep CLAUDE.md under 150 lines. If it exceeds ~150 lines, Claude starts ignoring rules silently. Put detailed standards in path-scoped rules (`.claude/rules/`) instead --- they only load when Claude works on matching files, so they don't compete for attention.

### Rules --- Domain Knowledge That Auto-Loads

Rules are markdown files in `.claude/rules/` that Claude loads automatically. The key design principle is **path-scoping**: rules with a `paths:` YAML frontmatter only load when Claude works on matching files.

**Always-on rules** (no `paths:` frontmatter) load every session. Keep these few and lean:

```
.claude/rules/
+-- plan-first-workflow.md       # ~35 lines -- plan before you build
+-- orchestrator-protocol.md     # ~40 lines -- contractor mode loop
+-- session-logging.md           # ~22 lines -- three logging triggers
```

**Path-scoped rules** load only when relevant:

```
.claude/rules/
+-- python-code-conventions.md   # paths: ["**/*.py"] -- Python standards
+-- stata-code-conventions.md    # paths: ["**/*.do"] -- Stata standards
+-- quality-gates.md             # paths: ["*.tex", "*.py", "*.do"] -- scoring
+-- verification-protocol.md     # paths: ["*.tex", "*.py", "*.do"] -- verify before done
+-- replication-protocol.md      # paths: ["*.py", "*.do"] -- replicate first
+-- exploration-folder-protocol.md  # paths: ["explorations/**"] -- sandbox rules
+-- orchestrator-research.md     # paths: ["*.py", "*.do", "explorations/**"] -- simple loop
+-- ...14 path-scoped rules total
```

This design keeps always-on context under ~100 lines while providing rich, domain-specific guidance exactly when Claude needs it.

#### Example: Path-Scoped Python Code Conventions Rule

```yaml
---
paths:
  - "**/*.py"
  - "scripts/**/*.py"
---
```

```markdown
# Python Code Standards

## Reproducibility
- np.random.seed() called ONCE at top
- All imports at top, grouped: stdlib, third-party, local
- All paths relative to repository root

## Visual Identity
COLORS = {
    "primary_blue": "#012169",
    "primary_gold": "#f2a900",
}
```

The `paths:` block means this rule only loads when Claude reads or edits a `.py` file. When Claude works on a `.tex` file, this rule doesn't consume any of the instruction budget.

### Skills --- Reusable Slash Commands

Skills are multi-step workflows invoked with `/command`. Each skill lives in `.claude/skills/[name]/SKILL.md`:

```yaml
---
name: compile-latex
description: Compile LaTeX with 3-pass XeLaTeX + bibtex
disable-model-invocation: true
argument-hint: "[filename without .tex extension]"
---

# Steps:
1. cd to slides/
2. Run xelatex pass 1
3. Run bibtex
4. Run xelatex pass 2
5. Run xelatex pass 3
6. Check for errors
7. Report results
```

**Key skills in the template:**

| Skill | Purpose | When to Use |
|-------|---------|------------|
| `/compile-latex` | Build PDF from .tex | After any Beamer edit |
| `/proofread` | Grammar and consistency check | Before every commit |
| `/slide-excellence` | Full multi-agent review | Before major milestones |
| `/create-lecture` | New lecture from scratch | Starting a new topic |
| `/commit` | Stage, commit, PR, merge | After any completed task |
| `/review-python` | Python code review | After writing/modifying scripts |
| `/review-stata` | Stata .do file review | After writing/modifying do-files |
| `/data-analysis` | End-to-end analysis | Empirical analysis phase |

### Agents --- Specialized Reviewers

Agents are the real power of this system. Each agent is an expert in one dimension of quality:

```
.claude/agents/
+-- proofreader.md        # Grammar, typos, consistency
+-- slide-auditor.md      # Visual layout, overflow, spacing
+-- pedagogy-reviewer.md  # Narrative arc, notation clarity, pacing
+-- python-reviewer.md    # Python code quality and reproducibility
+-- stata-reviewer.md     # Stata .do file quality and conventions
+-- tikz-reviewer.md      # TikZ diagram visual quality
+-- verifier.md           # Task completion verification
+-- domain-reviewer.md    # YOUR domain-specific substance review
```

> **Note:** A single Claude prompt trying to check grammar, layout, math, and code simultaneously will do a mediocre job at all of them. Specialized agents focus on one dimension and do it thoroughly. The `/slide-excellence` skill runs them all in parallel, then synthesizes results.

#### Multi-Model Strategy: Cost vs. Quality

Not all agents need the same model. By default, all agents use `model: inherit` (they use whatever model your main session runs). But you can customize this to optimize cost:

| Task Type | Recommended Model | Why |
|-----------|-------------------|-----|
| Planning, complex review | `model: opus` | Needs deep understanding |
| Fast, constrained work | `model: haiku` | Speed matters more than depth |
| Default | `model: inherit` | Uses whatever the main session runs |

To change an agent's model, edit its YAML frontmatter:

```yaml
---
name: python-reviewer
model: haiku   # was: inherit
---
```

### Settings --- Permissions and Hooks

`.claude/settings.json` controls what Claude is allowed to do. Here is a simplified excerpt:

```json
{
  "permissions": {
    "allow": [
      "Bash(git status *)",
      "Bash(xelatex *)",
      "Bash(C:\\Users\\...\\python.exe *)",
      "Bash(stata-mp *)"
    ]
  },
  "hooks": {
    "Stop": [
      {
        "hooks": [{
          "type": "command",
          "command": "\"C:\\Users\\...\\python.exe\" .claude/hooks/log-reminder.py",
          "timeout": 10
        }]
      }
    ]
  }
}
```

The **Stop hook** runs a fast Python script after every response. No LLM call, no latency. It checks whether the session log is current and reminds Claude to update it if not.

The template includes four hooks:

| Hook | Event | What It Does |
|------|-------|-------------|
| Session log reminder | `Stop` | Reminds Claude to create/update session logs |
| Desktop notification | `Notification` | Toast notification when Claude needs attention |
| File protection | `PreToolUse` | Blocks accidental edits to protected files |
| Context snapshot | `PreCompact` | Saves context to disk before auto-compression |

> **Tip:** Use **command-based hooks** for fast, mechanical checks (file exists? counter threshold?). Use **rules** for nuanced judgment (did Claude verify correctly?). Avoid prompt-based hooks that trigger an LLM call on every response --- the latency adds up fast.

### Memory --- Cross-Session Persistence

Claude Code has an auto-memory system at `~/.claude/projects/[project]/memory/MEMORY.md`. This file persists across sessions and is loaded into every conversation.

Use it for:

- Key project facts that never change
- Corrections you don't want repeated (`[LEARN:tag]` format)
- Current plan status

```markdown
# Auto Memory

## Key Facts
- Project uses XeLaTeX with MikTeX, not pdflatex
- Bibliography file: Bibliography_base.bib
- Python via Anaconda; Stata for econometrics

## Corrections Log
- [LEARN:python] Package X drops obs silently when covariate is missing
- [LEARN:citation] Post-LASSO is Belloni (2013), NOT Belloni (2014)
- [LEARN:pdf] Always pass pages parameter when reading PDFs
```

#### Plans --- Compression-Resistant Task Memory

Every non-trivial plan is saved to `quality_reports/plans/` with a timestamp. Plans survive auto-compression and session boundaries.

#### Session Logs --- Why-Not-Just-What History

Git commits record what changed, but not *why*. Session logs fill this gap. Claude writes to `quality_reports/session_logs/` at three points: right after plan approval, incrementally during implementation, and at session end.

#### How It All Fits Together

| Layer | File | Survives Compression? | Purpose |
|-------|------|----------------------|---------|
| Project context | `CLAUDE.md` | Yes (on disk) | Project rules, folder structure, commands |
| Corrections | `MEMORY.md` | Yes (on disk) | Prevent repeating past mistakes |
| Task strategy | `quality_reports/plans/` | Yes (on disk) | Plan survives planning-to-implementation handoff |
| Decision reasoning | `quality_reports/session_logs/` | Yes (on disk) | Record *why* decisions were made |
| Conversation | Claude's context window | **No** (compressed) | Current working memory |

The first four layers are your safety net. Anything written to disk survives indefinitely. The conversation context is ephemeral.

---

## 5. Workflow Patterns

### Pattern 1: Plan-First Development

The plan-first pattern ensures that non-trivial tasks begin with thinking, not typing.

Without a plan, Claude starts editing immediately, discovers a dependency, and has to undo work. With a plan, the approach is agreed upon before any edits happen.

```
Non-trivial task arrives
  |
  +-- Step 1: Enter Plan Mode (EnterPlanMode)
  +-- Step 2: Draft plan (approach, files, verification)
  +-- Step 3: Save to quality_reports/plans/YYYY-MM-DD_description.md
  +-- Step 4: Present plan to user
  +-- Step 5: User approves (or revises)
  +-- Step 6: Save initial session log (capture context while fresh)
  +-- Step 7: Orchestrator takes over (see Pattern 2)
  +-- Step 8: Update session log + plan status to COMPLETED
```

#### Context Preservation: Prefer Auto-Compression

- **`/clear`** --- destroys everything. Starting over from zero.
- **Auto-compression** --- graceful degradation. Keeps the most important context.

The rule: **avoid `/clear`** --- prefer auto-compression. Always save important context to disk first. Plans and important decisions live in files on disk, where they cannot be compressed away.

### Pattern 2: Contractor Mode (Orchestrator)

Once a plan is approved, the orchestrator takes over. Think of it as a **general contractor**: you are the client, the plan is the blueprint, and the orchestrator hires specialists, inspects their work, and only calls you when the job passes inspection.

```
User: "Create a new lecture on synthetic control"
  |
  |-- Plan-first (Pattern 1): draft plan, save to disk, get approval
  |
  |-- User: "Approved"
  |
  +-- Orchestrator activates:
        |
        Step 1: IMPLEMENT
        |  Execute plan steps
        |
        Step 2: VERIFY
        |  Compile LaTeX, run scripts, check output
        |
        Step 3: REVIEW (agents selected by file type)
        |  +--- proofreader ------+
        |  +--- slide-auditor ----+  (parallel)
        |  +--- pedagogy-reviewer +
        |
        Step 4: FIX
        |  Apply fixes: Critical -> Major -> Minor
        |
        Step 5: RE-VERIFY
        |  Compile again, confirm fixes are clean
        |
        Step 6: SCORE
        |  Apply quality-gates rubric
        |
        +-- Score >= 80?
              YES -> Present summary to user
              NO  -> Loop to Step 3 (max 5 rounds)
```

#### Agent Selection

The orchestrator selects agents based on which files were touched:

| Files Modified | Agents Selected |
|---------------|----------------|
| `.tex` only | proofreader + slide-auditor + pedagogy-reviewer |
| `.py` scripts | python-reviewer |
| `.do` scripts | stata-reviewer |
| TikZ diagrams present | tikz-reviewer |
| Domain content | domain-reviewer (if configured) |

#### "Just Do It" Mode

> "Create the lecture. Just do it."

The orchestrator still runs the full verify-review-fix loop (quality is non-negotiable), but skips the final approval pause and auto-commits if the score is 80 or above.

### Pattern 3: Creating a New Lecture

The `/create-lecture` skill guides you through a structured lecture creation workflow:

```
/create-lecture
  |
  +-- Phase 1: Gather materials (papers, outlines)
  +-- Phase 2: Design slide structure
  +-- Phase 3: Draft Beamer slides
  +-- Phase 4: Generate figures (Python/TikZ)
  +-- Phase 5: Polish and verify
  |     +-- /slide-excellence (domain + visual + pedagogy)
  |     +-- /proofread (grammar/typos)
  |     +-- /visual-audit (layout)
  +-- Phase 6: Commit and report
```

### Pattern 4: Replication-First Coding

When working with papers that have replication packages:

```
Phase 1: Inventory original code
  +-- Record "gold standard" numbers (Table X, Column Y = Z.ZZ)

Phase 2: Translate (e.g., Stata -> Python or vice versa)
  +-- Match original specification EXACTLY (same covariates, same clustering)

Phase 3: Verify match
  +-- Compare every target: paper value vs. our value
  +-- Tolerance: < 0.01 for estimates, < 0.05 for SEs
  +-- If mismatch: STOP. Investigate before proceeding.

Phase 4: Only then extend
  +-- New estimators, new specifications, course-specific figures
```

> **Important:** In one course, we discovered that a widely-used package silently produced **incorrect estimates** due to a subtle specification issue. Without the replication-first protocol, these wrong numbers would have been taught to PhD students. Never skip replication.

### Pattern 5: Multi-Agent Review

The `/slide-excellence` skill runs multiple agents in parallel:

```
/slide-excellence slides/Lecture5_Topic.tex
  |
  +-- Agent 1: Visual Audit (slide-auditor)
  +-- Agent 2: Pedagogical Review (pedagogy-reviewer)
  +-- Agent 3: Proofreading (proofreader)
  +-- Agent 4: TikZ Review (tikz-reviewer, if applicable)
  +-- Agent 5: Substance Review (domain-reviewer)
  |
  +-- Synthesize: Combined quality score + prioritized fix list
```

### Pattern 6: Self-Improvement Loop

Every correction gets tagged for future reference:

```markdown
## Corrections Log
- [LEARN:notation] T_t = 1{t=2} is deterministic -> use T_i in {1,2}
- [LEARN:citation] Post-LASSO is Belloni (2013), NOT Belloni (2014)
- [LEARN:python] Package X: ALWAYS include intercept in design matrix
- [LEARN:pdf] Always pass pages parameter when reading PDFs
```

These tags are searchable and persist in MEMORY.md across sessions.

### Pattern 7: Devil's Advocate

At any design decision, invoke the Devil's Advocate:

> "Create a Devil's Advocate. Have it challenge this slide design with 5-7 specific pedagogical questions."

This catches unstated assumptions, alternative orderings, notation confusion, and cognitive load issues.

### Research Workflows

#### Pattern 8: Parallel Agents for Research Tasks

Claude Code can spawn **multiple agents simultaneously**. The orchestrator recognizes independent subtasks and spawns parallel agents automatically.

| Scenario | Sequential (slow) | Parallel (fast) |
|----------|-------------------|-----------------|
| Reviewing a lecture | Run proofreader, then auditor, then pedagogy | Run all 3 simultaneously |
| Analyzing 3 papers | Read paper 1, then 2, then 3 | Spawn 3 agents, each reading one paper |
| Generating figures | Create plot 1, then plot 2, then plot 3 | Spawn agents for independent plots |

Practical limits: **3 agents** is the sweet spot. Agents are independent --- they cannot see each other's work.

#### Pattern 9: Research Exploration Workflow

All experimental work goes into `explorations/` first:

```
explorations/
+-- [active-project]/
|   +-- README.md           # Goal, hypotheses, status
|   +-- python/             # Python code iterations
|   +-- stata/              # Stata .do files
|   +-- scripts/            # Test scripts
|   +-- output/             # Results
+-- ARCHIVE/
    +-- completed_[name]/   # Graduated to production
    +-- abandoned_[name]/   # Documented why stopped
```

| Question | Answer | Workflow |
|----------|--------|----------|
| "Will this ship?" | YES | Plan-First (80/100 quality) |
| "Am I testing an idea?" | YES | Fast-Track (60/100 quality) |
| "Does this improve the project?" | NO | Don't build it |

The **kill switch** is explicit: at any point, stop, archive with a one-paragraph explanation, and move on. No guilt, no sunk cost.

#### Pattern 10: Research Skills

Five skills support the research workflow:

| Skill | What It Does | When to Use |
|-------|-------------|-------------|
| `/lit-review [topic]` | Search, synthesize, and identify gaps | Starting a new project or section |
| `/research-ideation [topic]` | Generate research questions and strategies | Brainstorming phase |
| `/interview-me [topic]` | Interactive interview to formalize an idea | When you have intuition but not a plan |
| `/review-paper [file]` | Full manuscript review with referee objections | Before submission or after a draft |
| `/data-analysis [data]` | End-to-end analysis with publication-ready output | Empirical analysis phase |

---

## 6. Customizing for Your Domain

### Step 1: Build Your Knowledge Base

The knowledge base (`.claude/rules/knowledge-base-template.md`) provides skeleton tables for notation conventions, lecture progression, applications, design principles, anti-patterns, and code pitfalls.

### Step 2: Create Your Domain Reviewer

Copy `.claude/agents/domain-reviewer.md` and customize the 5 lenses for your field.

### Step 3: Add Field-Specific Coding Standards

Add pitfalls and conventions to `.claude/rules/python-code-conventions.md` and/or `.claude/rules/stata-code-conventions.md`.

### Step 4: Add Project-Specific Skills

If you have recurring workflows, create new skills:

```bash
mkdir -p .claude/skills/my-new-skill
```

Then create `SKILL.md` with YAML frontmatter + step-by-step instructions.

### Tips from Iteration

1. **Keep CLAUDE.md under 150 lines.** Use path-scoped rules for detailed standards.
2. **Add rules incrementally.** Don't try to write all rules upfront.
3. **Use the [LEARN] format.** Every correction gets tagged and persisted.
4. **Verify everything.** Never skip compilation or execution checks.
5. **Session logs matter.** Document design decisions, not just what changed.
6. **Devil's Advocate early.** Challenge structure before you've built 50 slides on a shaky foundation.
7. **Progressive disclosure.** Start with CLAUDE.md + 2--3 rules. Add more as your workflow matures.

---

## Appendix: File Reference

### All Agents

| Agent | File | Purpose |
|-------|------|---------|
| Proofreader | `.claude/agents/proofreader.md` | Grammar, typos, consistency |
| Slide Auditor | `.claude/agents/slide-auditor.md` | Visual layout, overflow, spacing |
| Pedagogy Reviewer | `.claude/agents/pedagogy-reviewer.md` | Narrative arc, notation clarity |
| Python Reviewer | `.claude/agents/python-reviewer.md` | Python code quality, reproducibility |
| Stata Reviewer | `.claude/agents/stata-reviewer.md` | Stata .do file quality, conventions |
| TikZ Reviewer | `.claude/agents/tikz-reviewer.md` | Diagram visual quality |
| Verifier | `.claude/agents/verifier.md` | Task completion verification |
| Domain Reviewer | `.claude/agents/domain-reviewer.md` | Your domain-specific review |

### All Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| `/compile-latex` | `.claude/skills/compile-latex/` | XeLaTeX 3-pass compilation (MikTeX) |
| `/extract-tikz` | `.claude/skills/extract-tikz/` | TikZ to SVG conversion |
| `/proofread` | `.claude/skills/proofread/` | Run proofreading agent |
| `/visual-audit` | `.claude/skills/visual-audit/` | Run layout audit agent |
| `/pedagogy-review` | `.claude/skills/pedagogy-review/` | Run pedagogy review agent |
| `/review-python` | `.claude/skills/review-python/` | Run Python code review agent |
| `/review-stata` | `.claude/skills/review-stata/` | Run Stata code review agent |
| `/slide-excellence` | `.claude/skills/slide-excellence/` | Combined multi-agent review |
| `/validate-bib` | `.claude/skills/validate-bib/` | Bibliography validation |
| `/devils-advocate` | `.claude/skills/devils-advocate/` | Design challenge questions |
| `/create-lecture` | `.claude/skills/create-lecture/` | Full lecture creation |
| `/commit` | `.claude/skills/commit/` | Stage, commit, PR, and merge |
| `/lit-review` | `.claude/skills/lit-review/` | Literature search and synthesis |
| `/research-ideation` | `.claude/skills/research-ideation/` | Research questions and strategies |
| `/interview-me` | `.claude/skills/interview-me/` | Interactive research interview |
| `/review-paper` | `.claude/skills/review-paper/` | Manuscript review |
| `/data-analysis` | `.claude/skills/data-analysis/` | End-to-end Python/Stata analysis |

### All Rules

**Always-on** (load every session):

| Rule | File | Purpose |
|------|------|---------|
| Plan-First Workflow | `plan-first-workflow.md` | Plan mode + context preservation |
| Orchestrator Protocol | `orchestrator-protocol.md` | Contractor mode loop |
| Session Logging | `session-logging.md` | Three logging triggers |

**Path-scoped** (load only when working on matching files):

| Rule | File | Triggers On |
|------|------|------------|
| Verification Protocol | `verification-protocol.md` | `.tex`, `*.py`, `*.do` |
| Single Source of Truth | `single-source-of-truth.md` | `figures/`, `.tex` |
| Quality Gates | `quality-gates.md` | `.tex`, `*.py`, `*.do` |
| Python Code Conventions | `python-code-conventions.md` | `*.py` |
| Stata Code Conventions | `stata-code-conventions.md` | `*.do` |
| TikZ Quality | `tikz-visual-quality.md` | `.tex` |
| PDF Processing | `pdf-processing.md` | `master_supporting_docs/` |
| Proofreading Protocol | `proofreading-protocol.md` | `.tex`, `quality_reports/` |
| No Pause | `no-pause-beamer.md` | `.tex` |
| Replication Protocol | `replication-protocol.md` | `*.py`, `*.do` |
| Knowledge Base | `knowledge-base-template.md` | `.tex`, `*.py`, `*.do` |
| Orchestrator Research | `orchestrator-research.md` | `*.py`, `*.do`, `explorations/` |
| Exploration Folder | `exploration-folder-protocol.md` | `explorations/` |
| Exploration Fast-Track | `exploration-fast-track.md` | `explorations/` |

### Hooks

| Hook | Type | Configuration |
|------|------|--------------|
| Session log reminder | Stop (command) | `.claude/hooks/log-reminder.py` |
| Desktop notification | Notification (command) | `.claude/hooks/notify.sh` |
| File protection | PreToolUse (command) | `.claude/hooks/protect-files.sh` |
| Context snapshot | PreCompact (command) | `.claude/hooks/pre-compact.sh` |
