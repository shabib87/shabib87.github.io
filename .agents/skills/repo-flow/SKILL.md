---
name: repo-flow
description: Standardize git, validation, PR, and merge workflow for this repository. Use when starting new work, running repo checks, preparing a pull request, finalizing a merge, or aligning work with the repo's linear-history policy.
---

# Repo Flow

Use this skill for repo mechanics.

## Workflow

1. Read `references/branch-pr-merge.md`.
2. Read `references/context7-verification.md` when command behavior depends on official docs.
3. Use the scripts in this skill and the repo root `scripts/` commands instead of ad hoc git/gh sequences.

## Output Expectations

- clean branch creation
- consistent PR title/body
- local-first validation before PR
- solo self-review merge flow

## Done Criteria

- the work is packaged in a PR with clean commits
- local checks passed
- the merge path is explicit and safe for a solo maintainer

## Rules

- Start repo-changing work from `main` on a fresh `codex/*` branch.
- Run local checks before opening a PR.
- Require valid `gh` authentication for PR and merge commands.
- Keep history linear and prefer rebase-based merge behavior.
- Do not require external reviewer approval for this repo; require explicit self-review instead.
