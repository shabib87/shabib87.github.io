---
name: repo-flow
description: Standardize git, validation, PR, and rebase-only integration workflow for this repository. Use when starting new work, running repo checks, preparing a pull request, finalizing rebase integration, or aligning work with the repo's trunk-based development policy.
---

# Repo Flow

Use this skill for repo mechanics.

## Workflow

1. Read `references/branch-pr-merge.md`.
2. Read `references/context7-verification.md` when command behavior depends on official docs.
3. Use the scripts in this skill and the repo root `scripts/` commands instead of ad hoc git/gh sequences.
4. Require `make qa-local` before commit, before PR creation, and again on the committed tree before push or rebase integration.

## Output Expectations

- clean branch creation
- consistent PR title/body
- local-first validation before PR
- solo self-review rebase integration flow

## Done Criteria

- the work is packaged in a PR with clean commits
- local checks passed
- the rebase-only integration path is explicit and safe for a solo maintainer

## Rules

- Start repo-changing work from `main` on a fresh `codex/*` branch.
- Do not commit until the full local QA gate passes.
- Re-run the same local QA gate on the committed tree before push or rebase integration.
- Run local checks before opening a PR.
- Require valid `gh` authentication for PR and rebase integration commands.
- Keep history linear and prefer rebase-only integration behavior.
- Do not require external reviewer approval for this repo; require explicit self-review instead.
