---
name: repo-flow
description: Use this skill when the user asks to start, validate, package, or integrate repository changes in this repo using its scripted workflow (`make qa-local`, `make create-pr`, `make finalize-merge`) and policy gates (branch naming, task file presence, Linear traceability, rebase-only integration). Use it even when requested indirectly ("open a PR", "finish merge", "prep branch"). Do not use for editorial drafting or content-only edits that do not involve repo workflow mechanics, and do not use for generic git advice outside this repository.
---

# Repo Flow

Use this skill for repository workflow mechanics only.

## Trigger Boundaries

### Should Trigger

- Start work on a new task branch.
- Run repo checks and validate readiness for PR.
- Create or normalize PR metadata using repo scripts.
- Finalize integration with rebase-only workflow and check gates.
- Resolve branch/PR workflow policy conflicts in this repository.

### Should Not Trigger

- Drafting or editing post content where repo flow is not the problem.
- Fact checking or editorial QA requests.
- Generic cross-repo git tutoring with no repository-specific workflow ask.

## Inputs

- Current branch and working tree state.
- Target issue/branch context (for task branches, `CWS-<id>`).
- Repository policy files and scripts:
  `AGENTS.md`, `scripts/create-pr.sh`, `scripts/finalize-merge.sh`, and `make` targets.

## Procedure

1. Read `references/branch-pr-merge.md`.
2. Read `references/context7-verification.md` only when command behavior depends on official docs.
3. Use repository scripts and `make` targets instead of ad hoc git/gh sequences.
4. Run `make qa-local` before commit, before PR creation, and again on the committed tree before push or rebase integration.
5. For task branches, require `docs/tasks/CWS-<id>.md` to exist; treat local task-file status as informational only.
6. Keep Linear as mutable execution-status source of truth and keep PR traceability links current.

## Outputs

- Branch and PR actions consistent with repo policy.
- Validation evidence from required local checks.
- PR packaging with correct title/body/traceability fields.
- Rebase-only integration flow with explicit self-review checkpoint.

## Done Criteria

- Work is packaged in a PR with clean commits.
- Required local checks have passed.
- Integration path is explicit, rebase-only, and policy-compliant.

## Rules

- Start repo-changing work from `main` on a fresh `codex/*` branch.
- Do not commit until the full local QA gate passes.
- Re-run the same local QA gate on the committed tree before push or rebase integration.
- Run local checks before opening a PR.
- Require valid `gh` authentication for PR and rebase integration commands.
- Keep history linear and prefer rebase-only integration behavior.
- Do not require external reviewer approval for this repo; require explicit self-review instead.
- For task branches, require `docs/tasks/CWS-<id>.md` to exist; do not treat local task-file `Status` text as merge-gating state.
- Use Linear as the mutable execution-status source of truth; keep task files focused on execution brief and evidence pointers.

## Trigger Quality Check

After updating this skill description, sanity-check with 6 to 10 prompts:

- Should trigger: branch start, `make create-pr`, `make finalize-merge`, rollout gate failures.
- Should not trigger: pure editorial drafting, pure fact-checking, generic git question without repo workflow context.
