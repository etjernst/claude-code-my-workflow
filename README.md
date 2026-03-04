# Claude Code academic workflow

Source of truth for my Claude Code infrastructure: skills, agents, rules, hooks, and sync scripts for economics research projects using LaTeX/Beamer, Python, and Stata.

## How it works

Generic infrastructure lives at **user level** (`~/.claude/`) and applies to every project automatically. This repo is where that infrastructure is developed and version-controlled. Individual projects only need a lightweight `CLAUDE.md` describing the research question, data, and folder structure.

### What lives where

| Level | Location | Contents |
|-------|----------|----------|
| User | `~/.claude/skills/` | 23 slash commands (compile-latex, review-stata, commit, etc.) |
| User | `~/.claude/agents/` | 8 review agents (proofreader, domain-reviewer, etc.) |
| User | `~/.claude/rules/` | 19 workflow rules (quality gates, code conventions, etc.) |
| User | `~/.claude/hooks/` | Hook scripts (protect-files, context-monitor, etc.) |
| User | `~/.claude/settings.json` | Permissions, hook wiring, env vars |
| User | `~/.claude/CLAUDE.md` | Global preferences (OS, shell, writing style, git) |
| Project | `CLAUDE.md` | Research question, data paths, folder structure |
| Project | `quality_reports/` | Session logs, plans |
| Project | `project/` | Your actual research files (syncs with Dropbox) |

### Architecture

```
~/.claude/                          ← Generic (installed from this repo)
├── skills/  agents/  rules/        ← Apply to ALL projects
├── hooks/                          ← Hook scripts
└── settings.json                   ← Permissions + hook wiring

any-project/                        ← Project-specific only
├── CLAUDE.md                       ← Research question, data, commands
├── project/                        ← Your files (Dropbox sync target)
├── slides/  preambles/  figures/   ← Beamer infrastructure
├── scripts/  explorations/         ← Analysis code
└── quality_reports/                ← Session logs, plans
```

## Setup

### First time (install user-level infrastructure)

```bash
cd C:/git/fresh-workflow
bash install.sh
```

This copies all skills, agents, rules, and hook scripts to `~/.claude/`. Run it again after pulling updates.

### New project

1. Clone this repo as your project base:

```bash
git clone https://github.com/etjernst/claude-code-my-workflow.git my-project
cd my-project
git remote rename origin workflow
git remote set-url --push workflow DISABLE
# If git or gh added an upstream remote (pedrohcgs), disable pushes to it:
git remote set-url --push upstream DISABLE
git remote add origin https://github.com/YOUR_USERNAME/my-project.git
git push -u origin main
gh repo set-default YOUR_USERNAME/my-project
```

2. Drop existing project files into `project/`.

3. Edit `CLAUDE.md`: fill in the project name, research question, data sources, and folder structure. Everything else is inherited from `~/.claude/`.

4. If using Dropbox sync, run the one-time setup (see below).

5. Start Claude Code and paste the starter prompt:

```bash
claude
```

> I am starting to work on **[PROJECT NAME]** in this repo. **[Describe your project in 2--3 sentences.]**
>
> The workflow infrastructure (skills, agents, rules, hooks) is installed at user level. Please read `CLAUDE.md`, fill in any remaining placeholders, explore `project/` to map the file structure. If `sync-pull.sh` exists, run it to pull any collaborator changes from Dropbox. Then enter plan mode for my first task.

### Existing repo (no commits to remote)

If you've cloned someone else's repo and want Claude's workflow infrastructure without pushing any Claude files to their remote, use `.git/info/exclude`---a local-only gitignore that is never tracked or committed:

```bash
cd /path/to/their-repo

# Tell git to ignore Claude workflow files locally
echo "CLAUDE.md" >> .git/info/exclude
echo "MEMORY.md" >> .git/info/exclude
echo "quality_reports/" >> .git/info/exclude

# Create a project CLAUDE.md so Claude knows the context
cp C:/git/fresh-workflow/CLAUDE.md ./CLAUDE.md
# Edit CLAUDE.md: fill in project name, research question, folder structure
```

The user-level infrastructure (`~/.claude/`) already applies automatically---no per-project install needed. The `CLAUDE.md` gives Claude project-specific context (research question, data, commands) while `.git/info/exclude` keeps it invisible to git status, diff, and push.

## Dropbox and Overleaf sync

The `project/` subdirectory syncs bidirectionally with a Dropbox folder. Everything outside `project/` (slides, scripts, `.claude/`, quality_reports) never touches Dropbox---isolation by scoping, not filtering. Universal artifacts (`.pyc`, LaTeX build files, OS junk) are also excluded; see `.syncignore` for the full list.

Optional Overleaf support pushes output directories (tables, figures) to an Overleaf-linked Dropbox folder on every commit, and pulls paper edits back at session start.

### What's automatic vs manual

After the one-time setup, almost everything is automatic:

| Action | When | How |
|--------|------|-----|
| Push to Dropbox | Every commit | Automatic (post-commit hook) |
| Conflict detection | Every commit | Automatic (pre-commit hook blocks if Dropbox has newer files) |
| Pull from Dropbox | Session start | Automatic (starter prompt tells Claude to run `sync-pull.sh`) |
| Pull after blocked commit | When needed | Claude runs `sync-pull.sh` after the pre-commit hook tells it to |

The only scenario requiring manual intervention is if the pre-commit hook blocks a commit and you're working outside Claude Code (e.g., committing from the terminal). In that case, run `bash sync-pull.sh` and retry the commit.

### One-time setup

The setup script configures Dropbox sync paths and installs git hooks. It has two modes:

Interactive mode asks you for paths one at a time. Use this when setting up from the terminal yourself:

```bash
bash templates/setup-sync.sh
```

Non-interactive mode takes all paths as flags. Use this when Claude Code is doing the setup for you (e.g., during the starter prompt), since Claude can't answer interactive prompts:

```bash
bash templates/setup-sync.sh \
  --dropbox "C:/Users/me/Dropbox/shared-project" \
  --overleaf "C:/Users/me/Dropbox/Apps/Overleaf/my-paper" \
  --push "project/output/tables:tables,project/output/figures:figures" \
  --pull ".:project/paper"
```

All flags are optional---omit `--overleaf` if you don't use it, omit `--push`/`--pull` if you only need the main Dropbox sync. The script creates:

| File | Purpose |
|------|---------|
| `.sync-config` | Machine-specific paths (gitignored) |
| `.git/hooks/pre-commit` | Blocks commit if Dropbox has newer files |
| `.git/hooks/post-commit` | Pushes `project/` to Dropbox after commit |
| `sync-pull.sh` | Pulls collaborator changes from Dropbox |

After setup, do an initial pull to bring in existing Dropbox contents:

```bash
bash sync-pull.sh
```

### Safety guarantees

- All syncs use `robocopy /E /XO` (never `/MIR`): never deletes destination files, never overwrites newer files
- The pre-commit hook runs a dry-run check against Dropbox before every commit. If a collaborator updated files that are newer than your local copies, the commit is blocked with a list of conflicting files
- The post-commit hook pushes `project/` to Dropbox after every successful commit
- These are standard git hooks, so they fire on every commit regardless of whether it comes from Claude Code, the terminal, or a GUI
- Escape hatch: `git commit --no-verify` skips the pre-commit check if you're sure the timestamp difference is harmless

If the pre-commit hook blocks:

```
CONFLICT: These Dropbox files are NEWER than your local copies:
    analysis.do
    data/survey_round2.dta

COMMIT BLOCKED. Your collaborator has newer files on the remote.
Pull first:  bash sync-pull.sh
Then retry:  git commit
```

### Without Dropbox

Skip setup entirely. Everything works without sync---just manage files manually.

## Infrastructure improvements

Skills, agents, rules, and hooks live at `~/.claude/` and are edited in place during any project session. If Claude improves a skill while you're working, the improvement is already live for all projects immediately---no propagation step needed.

The only reason to touch this repo is version control: if you want to track what changed, commit the updated files here. To copy changes back:

```bash
cd C:/git/fresh-workflow
# Overwrite with current user-level versions
cp -r ~/.claude/skills/.  .claude/skills/
cp -r ~/.claude/agents/.  .claude/agents/
cp -r ~/.claude/rules/.   .claude/rules/
cp -r ~/.claude/hooks/.   .claude/hooks/
git diff                   # review what changed
git add -p && git commit   # commit what you want
```

This is optional housekeeping, not a required workflow step. Your live infrastructure is always `~/.claude/`, and it's always up to date.

To pull project-level template updates (preambles, scripts) into an existing project:

```bash
cd /path/to/my-project
bash C:/git/fresh-workflow/templates/sync-from-workflow.sh
git diff                 # review
git add -p && git commit
```

## Skills

All available via `/command` in any project.

| Command | What it does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/extract-tikz [LectureN]` | TikZ → PDF → SVG |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/review-python [file]` | Python code quality review |
| `/review-stata [file]` | Stata .do file quality review |
| `/slide-excellence [file]` | Combined multi-agent review |
| `/validate-bib` | Cross-reference citations |
| `/devils-advocate` | Challenge slide design |
| `/create-lecture` | Full lecture creation |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/review-plan [file]` | Stress-test a plan with expert critique |
| `/data-analysis [dataset]` | End-to-end Stata household survey analysis |
| `/python-analysis [dataset]` | End-to-end Python analysis |
| `/context-status` | Check context usage and session health |
| `/learn` | Extract reusable knowledge into a skill |

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- XeLaTeX via MikTeX (Windows) or TeX Live
- Python (Anaconda)
- Stata (stata-mp on PATH)
- GitHub CLI (`gh`) for PR workflows

Not all are needed---install only what your project uses. Claude Code is the only hard requirement.

## Origin

Adapted from [Pedro Sant'Anna's Claude Code workflow](https://github.com/pedrohcgs/claude-code-my-workflow). Original: R + Quarto + Beamer. This version: Stata + Python + LaTeX/Beamer on Windows, with user-level infrastructure and Dropbox sync.
