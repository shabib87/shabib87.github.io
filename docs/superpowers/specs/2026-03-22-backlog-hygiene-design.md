# Backlog Hygiene, Label Cleanup, and Cycle Rebaseline

**Date:** 2026-03-22
**Linear issue:** Sub-issue of CWS-81
**Status:** Implemented

## Objective

Bring the Linear backlog, repo planning docs, branch conventions, and repo-flow skill into a
consistent, platform-agnostic, post-CWS-82 state. This is a one-time cleanup that resolves
accumulated drift from the workspace rebaseline (CWS-80), dual-platform pivot (CWS-82), and
priority restack.

## Context

The backlog has accumulated several categories of drift:

- Stale metadata: project target dates past due, issues missing milestones, Codex-specific titles
  after dual-platform pivot.
- Label bloat: 39 labels with significant redundancy.
- Structural gaps: CWS-44 (agent-context.md) not closed despite file existing, CWS-82 Graphite
  lessons not encoded in repo-flow skill, branch prefix still `codex/` instead of
  platform-agnostic.
- Planning drift: cycle layout written March 19 is stale after priority restack, editorial chain
  blocked on human-gated voice profile work (CWS-14/48).

## Decision: Soft Cycles

Cycles are soft containers. Spillover is expected and items carry forward. No rigid sprint
boundaries. The WIP cap (5 active, 3 agent-executable) provides flow discipline. A 30-second
"what spilled and why?" gut check at cycle end provides the feedback loop.

## Linear Ticket

- Parent: CWS-81
- Title: `[DEV] Backlog hygiene, label cleanup, and cycle rebaseline`
- Project: [ORCHESTRATION] Agentic Workflow Design
- Milestone: M1 Contract Canonicalization
- Priority: High
- Labels: `Workflow`, `agent-task`
- Gate type: `PR_REQUIRED`

## Phase 1 — Linear Mutations

### Issues to Close/Cancel

| Issue | Action | Rationale |
|-------|--------|-----------|
| CWS-1, 2, 3, 4 | Cancel | Linear onboarding noise |
| CWS-7 | Audit-close | Label taxonomy exists (39 labels), cleanup is happening now |
| CWS-44 | Close after agent-context.md fix | File exists and is maintained, schema just needs alignment |

### Issues to Update

| Issue | Changes |
|-------|---------|
| CWS-63 | Low priority, ORCHESTRATION/M4, blockedBy CWS-55 |
| CWS-83, 84, 85, 86, 87 | Low priority, defer past April 19; add history cleanup note to CWS-83 description |
| CWS-90 | Medium priority; update scope to repo-level allow rules only (hard security lives in user-level hooks) |
| CWS-14 | Add comment: voice profile interview session required; blocks CWS-24/40/46/47/51 |
| CWS-25, 32 | Wire blockedBy CWS-13 (Vale config prerequisite) |
| CWS-88, 89, 91 | Assign milestone M2 Tooling Foundation |
| CWS-66, 67, 68, 70, 71, 72 | Assign milestones; rename titles to platform-agnostic |
| CWS-29, 39, 58 | Rename titles to platform-agnostic |
| CWS-21 | Evaluate priority bump (post CWS-82 PR decomposition lesson) |
| CWS-81 | Update remaining scope comment (what's left after this cleanup) |

### Project Updates

Remove target dates from all 4 projects:
- [INFRA] Repo Process & Tooling (was March 19)
- [ORCHESTRATION] Agentic Workflow Design (was March 20)
- [EDITORIAL] Content Quality System (was March 21)
- Blog Content Pipeline (none — no change needed)

### Label Cleanup (39 → 15)

**Keep (15):**

| Label | Purpose |
|-------|---------|
| `Spec` | Has written specification |
| `Ready` | Pickup-ready, no blockers |
| `agent-task` | Work to be executed by an AI agent (update description to platform-agnostic) |
| `human-task` | Human executes |
| `Infra` | Infrastructure/tooling domain |
| `Workflow` | Process/workflow domain |
| `epic:dx-setup` | DX setup epic (absorbs epic:adr, epic:dor-dod) |
| `epic:editorial-qa` | Editorial quality epic (absorbs epic:publish-draft) |
| `epic:ci-pipeline` | CI pipeline epic (absorbs epic:git-hooks) |
| `epic:safety` | Safety and security epic (absorbs epic:security) |
| `epic:skills` | Skill authoring epic |
| `epic:reasoning` | Reasoning skills epic (absorbs epic:triggers) |
| `epic:slack` | Slack integration epic |
| `epic:dispatch` | Dispatch workflow epic |
| `epic:agents-config` | Agent config epic |

**Delete (24):**
`Dev`, `Refinement-Needed`, `Merge-Ready`, `Review`, `Implementation`, `Editorial-Update`,
`Editorial-New`, `Hybrid`, `Improvement`, `Feature`, `Bug`, `Agent`, `Human`, `Waiting-Agent`,
`Waiting-Human`, `Linear`, `Codex`, `epic:dor-dod`, `epic:adr`, `epic:publish-draft`,
`epic:git-hooks`, `epic:security`

Before deleting, relabel affected issues: migrate issues from absorbed epics to their new parent
epic label.

### Cycle Layout Rewrite

Rewrite `docs/planning/linear-reorg-2026-03.md` cycle allocations based on:
- Current priorities after restack
- Dependency backbone (unchanged)
- Editorial chain blocked until voice profile interview (CWS-14/48 gate)
- CWS-83 family deferred past April 19
- New issues CWS-88-92 placed appropriately

## Phase 2 — Repo Changes (Graphite Stack)

### Stack Structure

4 stacked PRs, each a single logical concern. Merge with `gt merge` (full stack).

| PR # | Scope | Branch Slug | Key Files |
|------|-------|-------------|-----------|
| 1 (base) | Branch prefix rename `codex/` → `cws/` | `cws/<id>-branch-prefix-rename` | ~15 files, mechanical |
| 2 | AGENTS.md label taxonomy + agent-context.md rewrite | `cws/<id>-label-taxonomy-agent-context` | AGENTS.md, docs/agent-context.md |
| 3 | repo-flow skill hardening | `cws/<id>-repo-flow-hardening` | SKILL.md, branch-pr-merge.md |
| 4 (top) | Planning doc rewrite + task file | `cws/<id>-planning-doc-rewrite` | linear-reorg-2026-03.md, docs/tasks/ |

### Stack Workflow

1. `git checkout -b cws/<id>-branch-prefix-rename main` → `gt track --parent main`
2. Commit PR 1 changes → `gt create --all -m "refactor: rename branch prefix codex/ to cws/"`
3. Commit PR 2 changes → `gt create --all -m "chore: add label taxonomy and rewrite agent-context"`
4. Commit PR 3 changes → `gt create --all -m "chore: harden repo-flow skill per CWS-82 lessons"`
5. Commit PR 4 changes → `gt create --all -m "docs: rewrite cycle layout and planning doc"`
6. `gt submit --stack --no-interactive --publish`
7. Merge: `gt merge` (full stack, not individual PRs)

The base branch (PR 1) uses the NEW prefix convention being introduced.

### Branch Prefix Rename (codex/ → cws/)

Convention change: `codex/cws-<id>-<slug>` becomes `cws/<id>-<slug>`.
Phase branches: `codex/phase-<n>-<slug>` becomes `cws/phase-<n>-<slug>`.

The `.codex/` directory is unchanged — that is the Codex platform config directory.

Files to update (~15):

**Convention files:**
- `AGENTS.md` (line 102-103)
- `CLAUDE.md` (line 60)
- `.github/pull_request_template.md` (line 3)
- `.agents/skills/repo-flow/SKILL.md` (line 60)
- `.agents/skills/repo-flow/references/branch-pr-merge.md` (line 6)

**Scripts with regex validation:**
- `.codex/rollout/active-plan.yaml` (lines 6-7, task and phase patterns)
- `scripts/create-pr.sh` (line 121, hardcoded regex)
- `scripts/start-phase.sh` (line 98, hardcoded prefix)
- `scripts/run-codex-checks.sh` (line 15, hardcoded regex)
- `.agents/skills/repo-flow/scripts/infer-pr-metadata.sh` (line 6, prefix strip)

**Docs referencing convention:**
- `.codex/prompts/repo-workflow.md` (line 6)
- `.codex/docs/multi-agent-rollout-checklist.md` (lines 9-10)
- `.codex/docs/multi-agent-red-team.md` (lines 16-17)
- `.codex/docs/workflows.md` (lines 49-50)

**Historical task files (leave unchanged):**
- `docs/tasks/CWS-16.md`, `CWS-77.md`, `CWS-78.md`, `CWS-79.md` — immutable records

### agent-context.md Rewrite

Rewrite `docs/agent-context.md` to match the CWS-44 schema with all 8 required sections:
1. Last Synced From Linear
2. Stale After
3. Active Phase
4. Top Priorities
5. Open Decisions
6. Active Risks
7. Next 10 Actions
8. Recent Completions

Move current "Confirmed Baseline" and "Lessons Learned" content to
`docs/planning/linear-reorg-2026-03.md`. Remove ad hoc "Backlog" section (belongs in Linear).

### AGENTS.md Updates

Add `## Label Taxonomy` section listing the 15 approved labels with the rule:
"Do not create new labels without human approval."

Update branch prefix in Task-File Convention section.

### repo-flow Skill Hardening

Update `.agents/skills/repo-flow/SKILL.md` per agentskills.io best practices and CWS-82 lessons:

**Add Gotchas section:**
- `gt sync --force` after partial stack merges deletes branches and closes PRs
- `gh pr merge` directly bypasses validation gates in `make finalize-merge`

**Add MUST NOT rules to Rules section:**
- MUST NOT use `gh pr merge` directly — use `make finalize-merge`
- MUST NOT use `gt sync --force` to reconcile after partial stack merges
- For stacks, MUST use `gt merge` or Graphite web, not individual PR merges
- MUST NOT create bulk commits — use atomic commits (one logical change per commit)

**Add validation loop pattern:**
- Run `make qa-local`. If it fails, fix issues and re-run. Do not commit until it passes.
- If it fails twice consecutively, stop and report (per AGENTS.md loop safety).

**Add cross-skill references (Claude Code plugin skills — MUST be invoked during execution):**
- `superpowers:verification-before-completion` — invoke before claiming work is done
- `superpowers:systematic-debugging` — invoke if `make qa-local` fails
- `commit-commands:commit` — invoke for commit creation conventions

**Update branch prefix** from `codex/*` to `cws/*`.

Update `references/branch-pr-merge.md` with matching prefix changes.

### Planning Doc Update

Rewrite `docs/planning/linear-reorg-2026-03.md`:
- Absorb "Confirmed Baseline" and "Lessons Learned" content from agent-context.md
- Updated cycle layout reflecting current state
- Updated dependency backbone if any changes
- Record this cleanup session's decisions and rationale

### Task File

Create `docs/tasks/CWS-<id>.md` for this issue before PR creation.

## Validation

- `make qa-local` before commit and on committed tree
- CWS-44 validation command:
  `rg -n "Last Synced|Stale After|Active Phase|Top Priorities|Open Decisions|Active Risks|Next 10 Actions|Recent Completions" docs/agent-context.md`
- Branch prefix grep: `rg "codex/" AGENTS.md CLAUDE.md .agents/skills/repo-flow/SKILL.md` should
  return zero matches after update

## Integration

- Graphite stack of 4 PRs
- Merge with `gt merge` (full stack) or Graphite web "Merge stack"
- MUST NOT use `make finalize-merge` on individual stack PRs
- MUST NOT use `gt sync --force`
- If stack breaks: cherry-pick onto fresh branch from main (per repo-flow policy)

## Out of Scope

- Voice profile interview (CWS-14) — separate session with writing samples
- Docker sandbox setup (CWS-92) — separate task
- Repo split (CWS-83 family) — deferred past April 19
- Other skill audits beyond repo-flow — future work
- Actual implementation of any non-cleanup issues
