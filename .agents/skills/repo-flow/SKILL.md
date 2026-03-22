---
name: repo-flow
description: >-
  Use this skill when the user asks to start, validate, package, or integrate repository changes
  in this repo using its scripted workflow (make qa-local, make create-pr, make finalize-merge)
  and policy gates (branch naming, task file presence, Linear traceability, rebase-only
  integration). Use it even when requested indirectly ("open a PR", "finish merge", "prep
  branch"). Do not use for editorial drafting or content-only edits that do not involve repo
  workflow mechanics, and do not use for generic git advice outside this repository.
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
5. Before any repo edits for a task issue, set the Linear issue state to `In Progress`.
6. Before any repo edits for a task issue, ensure the issue is linked to the active execution cycle.
7. If either Linear mutation fails, stop and report the blocker.
8. For task branches, require `docs/tasks/CWS-<id>.md` to exist; do not maintain mutable status text in the task file.
9. Keep Linear as mutable execution-status source of truth and keep PR traceability links current.

## Outputs

- Branch and PR actions consistent with repo policy.
- Validation evidence from required local checks.
- PR packaging with correct title/body/traceability fields.
- Rebase-only integration flow with explicit self-review checkpoint.

## Done Criteria

- Work is packaged in a PR with clean commits.
- Required local checks have passed (see Validation Loop for execution protocol).
- Integration path is explicit, rebase-only, and policy-compliant.

## Gotchas

Known failure modes specific to this workflow. Other skills should adopt a similar section when
non-obvious failure modes accumulate from real incidents.

- `gt sync --force` after partial stack merges deletes branches and closes PRs. Never use it to
  reconcile a partially merged stack.
- `gh pr merge` directly bypasses validation gates in `make finalize-merge`. Always use
  `make finalize-merge PR=...` for single-PR merges.
- For Graphite stacks, `make finalize-merge` only merges one PR and does not manage Graphite
  metadata or retarget children. Use `gt merge` or Graphite web for full-stack merges.

## Rules

- Start repo-changing work from `main` on a fresh `cws/*` branch.
- Do not commit until the full local QA gate passes.
- Re-run the same local QA gate on the committed tree before push or rebase integration.
- Run local checks before opening a PR.
- Require valid `gh` authentication for PR and rebase integration commands.
- Keep history linear and prefer rebase-only integration behavior.
- Do not require external reviewer approval for this repo; require explicit self-review instead.
- For task branches, require `docs/tasks/CWS-<id>.md` to exist; do not maintain mutable status text in the task file.
- Use Linear as the mutable execution-status source of truth; keep task files focused on execution brief and evidence pointers.
- Before repo edits on a task issue, Linear state MUST be `In Progress` and cycle linkage MUST be present.
- If setting `In Progress` or cycle linkage fails, stop execution and report the blocker.
- MUST NOT use `gh pr merge` directly — use `make finalize-merge PR=...`.
- MUST NOT use `gt sync --force` to reconcile after partial stack merges.
- For full-stack merges, use `gt merge` or Graphite web. Single-PR merges from a stack via `make finalize-merge PR=...` are allowed but only merge that PR — retarget children manually if needed.
- MUST NOT create bulk commits — use atomic commits (one logical change per commit).

## Validation Loop

1. Run `make qa-local`. If it passes, proceed to commit.
2. If it fails, diagnose the issue (invoke `superpowers:systematic-debugging` if available), fix, and re-run.
3. If `make qa-local` fails twice consecutively, stop and report (per AGENTS.md loop safety).
4. Do not commit until `make qa-local` passes.

## Cross-Skill References

These are Claude Code plugin skills — SHOULD be invoked if available during repo-flow execution.
They are platform-provided (not repo-local), so agents on other platforms may skip them.

- `superpowers:verification-before-completion` — invoke before claiming work is done.
- `superpowers:systematic-debugging` — invoke if `make qa-local` fails.
- `commit-commands:commit` — invoke for commit creation conventions.

## Trigger Quality Check

After updating this skill description, sanity-check with 6 to 10 prompts:

- Should trigger: branch start, `make create-pr`, `make finalize-merge`, rollout gate failures.
- Should not trigger: pure editorial drafting, pure fact-checking, generic git question without repo workflow context.
