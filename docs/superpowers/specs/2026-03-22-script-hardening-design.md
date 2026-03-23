# CWS-94: Harden PR Scripts for Stack, Sandbox, and Agent Workflows — Design Spec

**Status:** Design approved, pending implementation
**Parent:** CWS-81
**Date:** 2026-03-22
**Linear:** CWS-94

---

## Problem Statement

The PR workflow scripts (`create-pr.sh`, `finalize-merge.sh`) and the rollout governance CI
check were built for a single-branch, phase-based, `gh`-always-works model. CWS-93 removed
phase rollout support from the validator and `active-plan.yaml`, but left the scripts and CI
workflow referencing the removed `phase_branch_pattern`. **Both `make create-pr` and
`make finalize-merge` are broken TODAY** — the scripts require `phase_branch_pattern` from
`active-plan.yaml` but it was already removed. Additionally:

- Dependabot and bot PRs cannot pass the `rollout-governance` CI check (PR #46 blocked).
- `gh` CLI fails in Claude Code sandbox (TLS cert issue), with no fallback.
- `finalize-merge.sh` requires interactive confirmation, blocking agent execution.
- PR body is hardcoded ("Standardize the change...") regardless of actual changes.
- `run-codex-checks.sh` uses backtick shell interpolation (semgrep risk).
- No mechanism to keep `docs/agent-context.md` fresh after merges.
- The `repo-flow` skill does not reflect the current workflow.
- GitHub Actions uses deprecated Node.js 20 (`actions/checkout@v4`).

## Design Decisions

### D1: Exempt patterns for governance validator

Add `exempt_branch_patterns` list to `active-plan.yaml`. The validator skips branch-name
validation for branches matching any exempt pattern but still validates plan structure.

```yaml
exempt_branch_patterns:
  - '^dependabot/'
  - '^renovate/'
  - '^gh-pages$'
```

### D2: Remove all phase logic from scripts

Remove `phase_branch_pattern` references from `create-pr.sh` and `finalize-merge.sh`.
Remove phase-specific gating (prior-phase-merged checks). Simplify both scripts to
task-branch-only mode.

### D3: `gh` CLI with `curl` fallback

**Note:** `gh` and `gt` are in the Claude Code sandbox allowlist, so `gh` should work
in most agent sessions. The `curl` fallback exists for CI environments where `gh` is
not installed, or environments where `gh auth` is not configured.

Both scripts attempt `gh` first. If `gh` fails (auth check or command execution), fall
back to `curl` + GitHub REST API. Token resolution order: (1) `GITHUB_TOKEN` env var,
(2) `gh auth token` output, (3) fail with clear error. Extract the fallback logic into
`scripts/lib/github-api.sh` as shared functions:
- `github_api_get <endpoint>` — GET with auth
- `github_api_post <endpoint> <json_body>` — POST/PATCH with auth
- `gh_or_curl_pr_view <branch>` — view PR details
- `gh_or_curl_pr_create <base> <head> <title> <body>` — create PR
- `gh_or_curl_pr_edit <pr> <title> <body>` — edit PR metadata
- `gh_or_curl_pr_merge <pr> <method>` — merge PR

### D4: Non-interactive mode

`finalize-merge.sh` accepts `--yes` or `--no-interactive` flag. When set, skip the
`read -r confirm` prompt and proceed directly. The flag is also honored by
`make finalize-merge PR=... YES=1`.

### D5: Stack merge support

`finalize-merge.sh` detects Graphite stacks via `gt log --stack`. When a stack is
detected and `--stack` flag is passed:
- Use `gt merge` for full-stack merge (preferred path)
- Fall back to bottom-up individual PR merges if `gt merge` fails
- Pull main and clean up branches after merge

Single-PR merge remains the default (no `--stack` flag).

### D6: Per-branch PR body generation (template-driven)

Replace the hardcoded "Standardize the change..." body with dynamic content that
**respects `.github/pull_request_template.md`** for ALL PRs — single or stacked.
The template defines the canonical PR body structure; `create-pr.sh` must populate
its sections programmatically rather than bypassing it.

Generated body sections (mapped to template):
- **Summary:** derived from commit messages on the branch (`git log --oneline base..HEAD`)
- **Why:** extracted from Linear issue title/description if available, else left for author
- **Linear Traceability:** parent and issue links extracted from branch name (`cws/<id>-<slug>`)
- **Validation:** always `make qa-local` (pre-filled)
- **Affected files:** already computed (keep existing logic)
- **Affected URLs:** already computed (keep existing logic)
- **Traceability Checklist:** auto-checked where deterministic (branch name, task file existence)

For stacked PRs (`gt submit --stack`), the same template sections apply to each PR
in the stack. Graphite's `--no-interactive` mode replaces the template body with
whatever `create-pr.sh` generates, so the script must produce template-compliant output.

### D7: Agent-context staleness mechanism

**Post-merge refresh (in `finalize-merge.sh`):**
After successful merge, update the "Stale After" timestamp in `docs/agent-context.md`
to `now + 24 hours`. This is a mechanical timestamp bump, not a full content refresh.
Commit the update as part of the merge flow if on main.

**Session-start staleness warning (Claude Code hook):**
Add a `SessionStart` hook that reads the "Stale After" timestamp from
`docs/agent-context.md` and emits a warning if current time exceeds it. The hook
does NOT auto-refresh — it warns the agent to perform a Linear sync before executing.

Implementation: shell script at `.claude/hooks/check-agent-context-staleness.sh` that
parses the timestamp and outputs a warning message. Registered in
`.claude/settings.json` under `hooks.SessionStart` with matcher `startup|resume|compact`.
Must fail-closed (exit 2 on error, never fail-open).

### D8: Opportunistic `codex` → agent-agnostic renaming

As we modify files in this task, rename Codex-specific nomenclature:
- `run-codex-checks.sh` → `run-workflow-checks.sh`
- Makefile target `codex-check` → `workflow-check`
- Update all references in other scripts, CI workflows, and docs that point to these
- Variable names and comments within touched files: `codex` → `workflow` or neutral terms
- Do NOT rename the `.codex/` directory itself (larger change, separate ticket)

### D9: repo-flow skill as authoritative workflow reference

Update `.agents/skills/repo-flow/SKILL.md` to:
- Remove all phase-mode documentation
- Document the full task-only lifecycle: `make start-work` → branch → commit →
  `make create-pr` → CI → `make finalize-merge`
- Document stack workflow: `gt create` → `gt submit --stack` → `gt merge`
- Document `curl` fallback: when and how to use it
- Document `--yes` flag for agent contexts
- Document exempt branch patterns
- Ensure frontmatter `filePattern` and `bashPattern` trigger on all workflow scripts
  and git operations so agents automatically pick up the skill

### D10: Fix `run-workflow-checks.sh` backtick interpolation

Replace backtick git command interpolation with `Open3.capture2` or `IO.popen` in the
inline Ruby within `run-workflow-checks.sh` (the backtick-interpolated git commands in
the governance change detection block). This prevents semgrep from flagging the file on
future edits.

### D11: Bump GitHub Actions to latest versions

Bump `actions/checkout` from `@v4` to `@v6` (latest as of March 2026, see
https://github.com/actions/checkout/releases/tag/v6.0.2) across all workflow files.
This resolves the Node.js 20 deprecation warning on PR #46.

## Scope Exclusions

- `.codex/` directory rename (separate, larger migration)
- `start-phase.sh` script (phase workflow deprecated, script can be removed later)
- Full agent-context content refresh (CWS-81 handles this)
- `create-pr.sh` stack iteration (Graphite handles multi-branch submission via
  `gt submit --stack`; `create-pr.sh` normalizes metadata for current branch only)

## File Map

### PR 1 — Phase removal + governance fix + rename (urgent, unblocks PR #46)

- Modify: `.codex/rollout/active-plan.yaml` (add `exempt_branch_patterns`)
- Modify: `scripts/validate-rollout-governance.rb` (handle exempt patterns)
- Modify: `scripts/tests/rollout_governance_test.rb` (add exempt pattern tests)
- Rename: `scripts/run-codex-checks.sh` → `scripts/run-workflow-checks.sh`
- Modify: `scripts/run-workflow-checks.sh` (remove phase refs, fix backticks, update
  self-referencing target check from `codex-check` to `workflow-check`, update governance
  change detection regex from `run-codex-checks` to `run-workflow-checks`)
- Modify: `scripts/create-pr.sh` (remove phase logic)
- Modify: `scripts/finalize-merge.sh` (remove phase logic)
- Modify: `scripts/tests/finalize_merge_workflow_test.rb` (remove phase pattern assertions)
- Modify: `scripts/tests/repo_ruby_activation_test.rb` (update `CODEX_CHECK_PATH` constant)
- Modify: `Makefile` (rename `codex-check` target to `workflow-check`)
- Modify: `.github/workflows/rollout-governance.yml` (update script ref)
- Modify: `scripts/run-local-qa.sh` (update `make codex-check` to `make workflow-check`)
- Modify: `scripts/site-audit.sh` (update `codex-check` target validation)
- Modify: `.codex/docs/tooling.md` (update `codex-check` references)
- Modify: `.codex/docs/multi-agent-orchestration.md` (update `codex-check` references)
- Modify: `.codex/docs/multi-agent-rollout-checklist.md` (update `codex-check` references)
- Create: `.codex/rollout/evidence/cws-94-phase-removal-governance-fix.md`

### PR 2 — Fallback, non-interactive, stack merge, dynamic body

- Create: `scripts/lib/github-api.sh` (shared `gh`/`curl` fallback functions)
- Modify: `scripts/create-pr.sh` (use fallback lib, dynamic PR body)
- Modify: `scripts/finalize-merge.sh` (use fallback lib, `--yes` flag, `--stack` flag)
- Modify: `Makefile` (add `YES=1` and `STACK=1` variables)
- Modify: `scripts/tests/rollout_governance_test.rb` (if governance changes needed)
- Create: `.codex/rollout/evidence/cws-94-fallback-and-flags.md`

### PR 3 — Staleness mechanism + repo-flow skill update

- Create: `.claude/hooks/check-agent-context-staleness.sh` (SessionStart hook)
- Modify: `scripts/finalize-merge.sh` (post-merge staleness timestamp bump)
- Modify: `.agents/skills/repo-flow/SKILL.md` (full rewrite of workflow docs)
- Modify: `.agents/skills/repo-flow/references/branch-pr-merge.md` (update)
- Create: `.codex/rollout/evidence/cws-94-staleness-and-skill.md`
- Create: `docs/tasks/CWS-94.md` (task file)

## Validation

- `make qa-local` passes on each PR
- `make workflow-check` (renamed target) passes
- Rollout governance tests pass (including new exempt pattern tests)
- PR #46 (Dependabot) CI would pass with exempt patterns in place
- `make create-pr` and `make finalize-merge PR=... YES=1` work end-to-end
- `finalize-merge.sh --stack --yes` works with Graphite stacks
- SessionStart hook correctly warns when agent-context is stale
- repo-flow skill is picked up when running git/PR commands

## Risks

- **`curl` fallback token availability**: In CI, `GITHUB_TOKEN` is available. In Claude
  Code sandbox, `gh auth token` works. If neither is available, scripts fail with a clear
  error rather than silently degrading.
- **Graphite CLI availability**: `gt merge` requires Graphite. If not installed, fall back
  to individual PR merges. Scripts already check `command -v gt`.
- **Semgrep blocking edits**: The `run-workflow-checks.sh` inline Ruby uses backticks for
  git commands. Must replace with `Open3.capture2` or `IO.popen` to pass semgrep.
