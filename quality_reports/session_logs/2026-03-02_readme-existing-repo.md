# Session Log: 2026-03-02 -- README: existing repo setup

**Status:** COMPLETED

## Objective

Add instructions to the README for using Claude's workflow infrastructure in an existing cloned repo without committing or pushing any Claude files to that repo's remote.

## Changes made

| File | Change | Reason |
|------|--------|--------|
| `README.md` | Added "Existing repo (no commits to remote)" subsection under Setup | Users need a path for repos they don't own |

## Design decisions

| Decision | Alternatives considered | Rationale |
|----------|------------------------|-----------|
| `.git/info/exclude` over `.gitignore` | Append to `.gitignore` and gitignore the gitignore | `.git/info/exclude` is inherently local---never tracked, zero risk of accidental push |

## Open questions / blockers

- None
