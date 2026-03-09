# Claude Code academic workflow

Source of truth for my Claude Code infrastructure: skills, agents, rules, and hooks for economics research projects using LaTeX/Beamer, Python, and Stata.

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
| Project | `project/` | Symlink to Dropbox folder |

### Architecture

```
~/.claude/                          ← Generic (installed from this repo)
├── skills/  agents/  rules/        ← Apply to ALL projects
├── hooks/                          ← Hook scripts
└── settings.json                   ← Permissions + hook wiring

any-project/                        ← Project-specific only
├── CLAUDE.md                       ← Research question, data, commands
├── project/ → Dropbox/...          ← Symlink to Dropbox folder
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

2. Create a symlink from `project/` to your Dropbox folder (see [Linking project files](#linking-project-files) below).

3. Edit `CLAUDE.md`: fill in the project name, research question, data sources, Dropbox path, and folder structure. Everything else is inherited from `~/.claude/`.

4. Start Claude Code and paste the starter prompt:

```bash
claude
```

> I am starting to work on **[PROJECT NAME]** in this repo. **[Describe your project in 2--3 sentences.]**
>
> The workflow infrastructure (skills, agents, rules, hooks) is installed at user level. Please read `CLAUDE.md`, fill in any remaining placeholders, explore `project/` to map the file structure. Then enter plan mode for my first task.

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

## Linking project files

Project files (code, data, output) live in Dropbox and stay there. A single symlink (`project/` → Dropbox folder) lets git and Claude Code access them without copying or syncing. Edits write directly to Dropbox.

Git tracks code files through the symlink using an ignore-everything-then-whitelist approach in `.gitignore`. Code files (`.do`, `.py`, `.R`, `.tex`, etc.) are tracked regardless of where they sit in the Dropbox folder structure. Everything else (data, output, figures) is ignored by default.

### New project

Create the symlink from the repo root. On Windows, use an elevated (admin) terminal:

```bash
# Windows (requires admin privileges)
cmd //c "mklink /D project C:\Users\me\Dropbox\shared-project"
```

On macOS/Linux:

```bash
ln -s ~/Dropbox/shared-project project
```

Then record the Dropbox path in `CLAUDE.md` under the project-specific context section, so Claude can reference it in future sessions.

### Migrating from an existing project/ directory

If `project/` already exists as a real directory (from an earlier setup), follow these steps before creating the symlink:

1. Confirm nothing is uncommitted:

```bash
git status
```

2. Check whether any files in `project/` differ from the Dropbox versions. If the same files exist in both locations, compare them:

```bash
diff -rq project/ /path/to/Dropbox/folder/
```

If files differ, resolve the differences before proceeding.

3. If `project/` contains files that do NOT exist in the Dropbox folder, stop and move them to Dropbox first.

4. Remove `project/` from git tracking and delete the directory:

```bash
git rm -r --cached project/   # if tracked
rm -rf project/
```

5. Create the symlink (see above) and commit.

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


## Origin

Adapted from [Pedro Sant'Anna's Claude Code workflow](https://github.com/pedrohcgs/claude-code-my-workflow). Original: R + Quarto + Beamer. This version: Stata + Python + LaTeX/Beamer on Windows, with user-level infrastructure.
