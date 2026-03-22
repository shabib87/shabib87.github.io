# Backlog Hygiene, Label Cleanup, and Cycle Rebaseline — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the Linear backlog, repo planning docs, branch conventions, and repo-flow skill into a consistent, platform-agnostic, post-CWS-82 state.

**Architecture:** Phase 1 performs all Linear API mutations (no repo changes). Phase 2 creates a Graphite stack of 4 PRs — each PR is one logical concern. The stack merges with `gt merge` (full stack), never individual PR merges.

**Tech Stack:** Linear MCP tools, Graphite CLI (`gt`), GitHub CLI (`gh`), `make qa-local`, bash scripts.

**Spec:** `docs/superpowers/specs/2026-03-22-backlog-hygiene-design.md`

---

## File Map

### Phase 1 — Linear Only (no repo files touched)

All mutations happen through Linear MCP tools. No files created or modified.

### Phase 2 — Repo Changes (Graphite Stack)

**PR 1 — Branch prefix rename `codex/` → `cws/`:**
- Modify: `AGENTS.md:102-103`
- Modify: `CLAUDE.md:60`
- Modify: `.github/pull_request_template.md:2-3`
- Modify: `.agents/skills/repo-flow/SKILL.md:60`
- Modify: `.agents/skills/repo-flow/references/branch-pr-merge.md:6`
- Modify: `.codex/rollout/active-plan.yaml:6-7`
- Modify: `scripts/create-pr.sh:121`
- Modify: `scripts/start-phase.sh:97-98`
- Modify: `scripts/run-codex-checks.sh:15`
- Modify: `.agents/skills/repo-flow/scripts/infer-pr-metadata.sh:6`
- Modify: `.codex/prompts/repo-workflow.md:6`
- Modify: `.codex/docs/multi-agent-rollout-checklist.md:9-10`
- Modify: `.codex/docs/multi-agent-red-team.md:16-17`
- Modify: `.codex/docs/workflows.md:49-50`
- Skip (immutable records): `docs/tasks/CWS-16.md`, `CWS-77.md`, `CWS-78.md`, `CWS-79.md`

**PR 2 — Label taxonomy + agent-context rewrite:**
- Modify: `AGENTS.md` (add `## Label Taxonomy` section after line 169)
- Rewrite: `docs/agent-context.md` (full rewrite to CWS-44 schema: 8 required sections)

**PR 3 — repo-flow skill hardening:**
- Modify: `.agents/skills/repo-flow/SKILL.md` (add Gotchas, MUST NOT rules, validation loop, cross-skill references)
- Modify: `.agents/skills/repo-flow/references/branch-pr-merge.md` (already has Stack Merge Policy; update branch prefix references)

**PR 4 — Planning doc rewrite + task file:**
- Rewrite: `docs/planning/linear-reorg-2026-03.md`
- Create: `docs/tasks/CWS-93.md` (task file for this cleanup issue)

---

## Task 0: Create Linear Issue

**Files:** None (Linear API only)

- [ ] **Step 1: Create Linear issue as sub-issue of CWS-81**

Use `mcp__claude_ai_Linear__save_issue` with:
```
title: "[DEV] Backlog hygiene, label cleanup, and cycle rebaseline"
teamId: (CodeWithShabib team)
parentId: CWS-81's ID
priority: 2 (High)
labelNames: ["Workflow", "agent-task"]
projectId: [ORCHESTRATION] Agentic Workflow Design
milestoneId: M1 Contract Canonicalization
```

Record the created issue ID (e.g., `CWS-93`) — used for branch names, task file, and PR traceability throughout the rest of this plan.

- [ ] **Step 2: Set issue to In Progress**

Use `mcp__claude_ai_Linear__save_issue` to update state to `In Progress`.

- [ ] **Step 3: Link to active cycle**

Use `mcp__claude_ai_Linear__list_cycles` to find the active cycle, then update the issue's cycle linkage.

---

## Task 1: Phase 1 — Close/Cancel Issues

**Files:** None (Linear API only)

CWS-1, 2, 3, 4 were already cancelled in a prior session (Linear onboarding noise). Verify they show as Cancelled in Linear — no action needed unless they were reopened.

- [ ] **Step 1: Audit-close CWS-7 (Label Taxonomy)**

Use `mcp__claude_ai_Linear__save_issue` to:
- Set state to `Done`
- Add comment: "Closing: label taxonomy exists (39 labels). Cleanup to 15 labels is being executed as part of CWS-93 (backlog hygiene)."

- [ ] **Step 2: Fix agent-context.md format (prep for CWS-44 close)**

This is done in Task 5 (PR 2). CWS-44 will be closed after agent-context.md is rewritten with all 8 required sections. Add a comment now:

Use `mcp__claude_ai_Linear__save_comment`:
- Issue: CWS-44
- Comment: "agent-context.md rewrite in progress as part of CWS-93. Will match the 8-section schema from AC. Closing after PR merges."

---

## Task 2: Phase 1 — Update Issues

**Files:** None (Linear API only)

- [ ] **Step 1: Update CWS-63**

Use `mcp__claude_ai_Linear__save_issue`:
- Priority: 4 (Low)
- Project: [ORCHESTRATION] Agentic Workflow Design
- Milestone: M4
- Add blockedBy: CWS-55

- [ ] **Step 2: Update CWS-83, 84, 85, 86, 87 (repo split family)**

For each issue, use `mcp__claude_ai_Linear__save_issue`:
- Priority: 4 (Low)

For CWS-83 specifically, add to description: "Must include git history rewrite to remove infra work from public commit history."

- [ ] **Step 3: Update CWS-90**

Use `mcp__claude_ai_Linear__save_issue`:
- Priority: 3 (Medium)
- Update description/title to be platform-agnostic. Scope: repo-level allow rules only (hard security lives in user-level hooks).

- [ ] **Step 4: Add comment to CWS-14**

Use `mcp__claude_ai_Linear__save_comment`:
- "Voice profile interview session required before this can proceed. Blocks CWS-24, CWS-40, CWS-46, CWS-47, CWS-51. User will share writing samples in a dedicated session."

- [ ] **Step 5: Wire CWS-25 and CWS-32 blockedBy CWS-13**

Use `mcp__claude_ai_Linear__save_issue` for each:
- Add relation: blockedBy CWS-13 (Vale config prerequisite)

- [ ] **Step 6: Assign milestones to CWS-88, 89, 91**

Use `mcp__claude_ai_Linear__save_issue` for each:
- Milestone: M2 Tooling Foundation

- [ ] **Step 7: Rename and assign milestones to CWS-66, 67, 68, 70, 71, 72**

For each issue:
- Rename title to platform-agnostic language (remove Codex-specific wording)
- Assign appropriate milestone
- AC should include checking official docs for both Codex and Claude Code

- [ ] **Step 8: Rename CWS-29, 39, 58 to platform-agnostic**

Use `mcp__claude_ai_Linear__save_issue` for each:
- Update title to remove platform-specific wording

- [ ] **Step 9: Evaluate CWS-21 priority bump**

Read CWS-21 current state. Based on CWS-82 PR decomposition lesson, consider bumping priority. Update if warranted.

- [ ] **Step 10: Update CWS-81 scope comment**

Use `mcp__claude_ai_Linear__save_comment`:
- Document what remains of CWS-81 scope after this cleanup completes.

---

## Task 3: Phase 1 — Project Updates and Label Cleanup

**Files:** None (Linear API only)

- [ ] **Step 1: Remove target dates from projects**

Use `mcp__claude_ai_Linear__save_project` for each:
- `[INFRA] Repo Process & Tooling` — remove target date
- `[ORCHESTRATION] Agentic Workflow Design` — remove target date
- `[EDITORIAL] Content Quality System` — remove target date

(Blog Content Pipeline has no date — skip.)

- [ ] **Step 2: List all current labels**

Use `mcp__claude_ai_Linear__list_issue_labels` to get the full list with IDs.

- [ ] **Step 3: Identify issues on labels being deleted**

For each of the 24 labels to delete, check which issues use them. Plan relabeling:
- `epic:dor-dod` → `epic:dx-setup`
- `epic:adr` → `epic:dx-setup`
- `epic:publish-draft` → `epic:editorial-qa`
- `epic:git-hooks` → `epic:ci-pipeline`
- `epic:security` → `epic:safety`
- `epic:triggers` → `epic:reasoning`
- Other labels (`Dev`, `Refinement-Needed`, `Merge-Ready`, `Review`, `Implementation`, etc.) — just remove, no replacement needed.

- [ ] **Step 4: Relabel affected issues**

For each issue on an absorbed label, use `mcp__claude_ai_Linear__save_issue` to:
- Add the new parent epic label
- Remove the old label

- [ ] **Step 5: Update `agent-task` label description**

Note: The Linear MCP toolset has `create_issue_label` but no `update_issue_label`. If label description update is not available via MCP, use the Linear web UI to set the `agent-task` description to "Work to be executed by an AI agent".

- [ ] **Step 6: Delete the 23 unused/absorbed labels**

After all issues are relabeled, delete each label. Note: The Linear MCP toolset may not have a `delete_issue_label` tool. If not, use the Linear web UI to delete labels.

Labels to delete: `Dev`, `Refinement-Needed`, `Merge-Ready`, `Review`, `Implementation`, `Editorial-Update`, `Editorial-New`, `Hybrid`, `Improvement`, `Feature`, `Bug`, `Agent`, `Human`, `Waiting-Agent`, `Waiting-Human`, `Linear`, `Codex`, `epic:dor-dod`, `epic:adr`, `epic:publish-draft`, `epic:git-hooks`, `epic:security`, `epic:triggers`

---

## Task 4: Phase 2 Setup — Create Branch and Stack Base

**Files:** None (git/Graphite setup only)

**Important:** The Linear issue ID from Task 0 is needed here. In all branch names below, replace `<id>` with the actual issue number (e.g., `93`).

- [ ] **Step 1: Ensure clean working tree**

Run:
```bash
git status
```
Expected: clean working tree on `main`. If dirty, stash or resolve before continuing.

- [ ] **Step 2: Pull latest main**

Run:
```bash
git pull origin main
```

- [ ] **Step 3: Create base branch for PR 1**

Run:
```bash
git checkout -b cws/<id>-branch-prefix-rename main
gt track --parent main
```

Note: This branch itself uses the NEW `cws/` prefix convention being introduced.

---

## Task 5: PR 1 — Branch Prefix Rename (`codex/` → `cws/`)

**Files:**
- Modify: `AGENTS.md:102-103`
- Modify: `CLAUDE.md:60`
- Modify: `.github/pull_request_template.md:2-3`
- Modify: `.agents/skills/repo-flow/SKILL.md:60`
- Modify: `.agents/skills/repo-flow/references/branch-pr-merge.md:6`
- Modify: `.codex/rollout/active-plan.yaml:6-7`
- Modify: `scripts/create-pr.sh:121`
- Modify: `scripts/start-phase.sh:97-98`
- Modify: `scripts/run-codex-checks.sh:15`
- Modify: `.agents/skills/repo-flow/scripts/infer-pr-metadata.sh:6`
- Modify: `.codex/prompts/repo-workflow.md:6`
- Modify: `.codex/docs/multi-agent-rollout-checklist.md:9-10`
- Modify: `.codex/docs/multi-agent-red-team.md:16-17`
- Modify: `.codex/docs/workflows.md:49-50`

**Not testable with unit tests** — these are convention/config/doc changes. Validation is `make qa-local` + grep verification.

- [ ] **Step 1: Update `AGENTS.md` lines 102-103**

Change:
```markdown
- Task branches use `codex/cws-<id>-<slug>`. (The `codex/` prefix is a repo convention, not a
  platform restriction.)
```
To:
```markdown
- Task branches use `cws/<id>-<slug>`.
```

- [ ] **Step 2: Update `CLAUDE.md` line 60**

Change:
```markdown
- Same branch convention: `codex/cws-<id>-<slug>` (the `codex/` prefix is a repo convention,
  not a platform restriction).
```
To:
```markdown
- Same branch convention: `cws/<id>-<slug>`.
```

- [ ] **Step 3: Update `.github/pull_request_template.md` lines 2-3**

Change:
```markdown
- Branch: `codex/cws-<id>-<slug>` (task) or `codex/phase-<n>-<slug>` (rollout)
```
To:
```markdown
- Branch: `cws/<id>-<slug>` (task) or `cws/phase-<n>-<slug>` (rollout)
```

- [ ] **Step 4: Update `.agents/skills/repo-flow/SKILL.md` line 60**

Change:
```markdown
- Start repo-changing work from `main` on a fresh `codex/*` branch.
```
To:
```markdown
- Start repo-changing work from `main` on a fresh `cws/*` branch.
```

- [ ] **Step 5: Update `.agents/skills/repo-flow/references/branch-pr-merge.md` line 6**

Change:
```markdown
- create a `codex/<type>-<slug>` branch
```
To:
```markdown
- create a `cws/<type>-<slug>` branch
```

- [ ] **Step 6: Update `.codex/rollout/active-plan.yaml` lines 6-7**

Change:
```yaml
task_branch_pattern: '^codex/cws-\d+-[a-z0-9-]+$'
phase_branch_pattern: '^codex/phase-(\d+)-[a-z0-9-]+$'
```
To:
```yaml
task_branch_pattern: '^cws/\d+-[a-z0-9-]+$'
phase_branch_pattern: '^cws/phase-(\d+)-[a-z0-9-]+$'
```

- [ ] **Step 7: Update `scripts/create-pr.sh` line 121**

Change:
```bash
if [[ "$branch" =~ ^codex/cws-([0-9]+)-[a-z0-9-]+$ ]]; then
```
To:
```bash
if [[ "$branch" =~ ^cws/([0-9]+)-[a-z0-9-]+$ ]]; then
```

- [ ] **Step 8: Update `scripts/start-phase.sh` lines 97-98**

Change:
```bash
suffix="${inferred#codex/"${type}"-}"
branch_name="codex/phase-${phase}-${suffix}"
```
To:
```bash
suffix="${inferred#cws/"${type}"-}"
branch_name="cws/phase-${phase}-${suffix}"
```

- [ ] **Step 9: Update `scripts/run-codex-checks.sh` line 15**

Change:
```bash
if [[ "$branch" =~ ^codex/phase-([0-9]+)(-|$) ]]; then
```
To:
```bash
if [[ "$branch" =~ ^cws/phase-([0-9]+)(-|$) ]]; then
```

- [ ] **Step 10: Update `.agents/skills/repo-flow/scripts/infer-pr-metadata.sh` line 6**

Change:
```bash
subject="${branch#codex/}"
```
To:
```bash
subject="${branch#cws/}"
```

- [ ] **Step 11: Update `.codex/prompts/repo-workflow.md` line 6**

Change:
```markdown
- Start repo-changing work from `main` on a fresh `codex/*` branch using `make start-work`.
```
To:
```markdown
- Start repo-changing work from `main` on a fresh `cws/*` branch using `make start-work`.
```

- [ ] **Step 12: Update `.codex/docs/multi-agent-rollout-checklist.md` lines 9-10**

Change:
```markdown
- [ ] `task_branch_pattern` allows task branches (`^codex/cws-\d+-...`)
- [ ] `phase_branch_pattern` remains phase-based (`^codex/phase-(\d+)-...`)
```
To:
```markdown
- [ ] `task_branch_pattern` allows task branches (`^cws/\d+-...`)
- [ ] `phase_branch_pattern` remains phase-based (`^cws/phase-(\d+)-...`)
```

- [ ] **Step 13: Update `.codex/docs/multi-agent-red-team.md` lines 16-17**

Read file first to confirm exact content, then update any `codex/` branch references to `cws/`.

- [ ] **Step 14: Update `.codex/docs/workflows.md` lines 49-50**

Change:
```markdown
- Normal task branches use Linear-first naming (`codex/cws-<id>-...`).
- Rollout governance remains phase-based and sequential for rollout branches (`codex/phase-<n>-...`).
```
To:
```markdown
- Normal task branches use Linear-first naming (`cws/<id>-...`).
- Rollout governance remains phase-based and sequential for rollout branches (`cws/phase-<n>-...`).
```

- [ ] **Step 15: Verify no remaining `codex/` branch references**

Run (searches for `codex/` as a branch prefix pattern, not as a directory path):
```bash
rg "codex/(cws|phase|[a-z]+-)" AGENTS.md CLAUDE.md .agents/skills/repo-flow/SKILL.md .agents/skills/repo-flow/references/branch-pr-merge.md .github/pull_request_template.md scripts/create-pr.sh scripts/start-phase.sh scripts/run-codex-checks.sh .agents/skills/repo-flow/scripts/infer-pr-metadata.sh .codex/prompts/repo-workflow.md .codex/docs/multi-agent-rollout-checklist.md .codex/docs/multi-agent-red-team.md .codex/docs/workflows.md .codex/rollout/active-plan.yaml
```
Expected: zero matches. If any remain, fix before proceeding.

Also verify with a broader search (will match `.codex/` directory paths — those are expected and fine):
```bash
rg "codex/" AGENTS.md CLAUDE.md .agents/skills/repo-flow/SKILL.md .github/pull_request_template.md
```
Expected: zero matches in these non-`.codex/` files. The `.codex/` directory name is intentionally unchanged — that is the Codex platform config directory, not a branch prefix.

- [ ] **Step 16: Run `make qa-local`**

Run:
```bash
make qa-local
```
Expected: all checks pass. If any fail, fix and re-run. If it fails twice consecutively, stop and report.

- [ ] **Step 17: Commit PR 1**

Run:
```bash
gt create --all -m "refactor: rename branch prefix codex/ to cws/"
```

---

## Task 6: PR 2 — Label Taxonomy in AGENTS.md + agent-context.md Rewrite

**Files:**
- Modify: `AGENTS.md` (add `## Label Taxonomy` section)
- Rewrite: `docs/agent-context.md` (CWS-44 8-section schema)

- [ ] **Step 1: Add Label Taxonomy section to AGENTS.md**

Add after the `## Platform Applicability` section (after line 169), before `## Bash Security Baseline`:

```markdown
## Label Taxonomy

Approved labels (15). Do not create new labels without human approval.

| Label | Purpose |
|-------|---------|
| `Spec` | Has written specification |
| `Ready` | Pickup-ready, no blockers |
| `agent-task` | Work to be executed by an AI agent |
| `human-task` | Human executes |
| `Infra` | Infrastructure/tooling domain |
| `Workflow` | Process/workflow domain |
| `epic:dx-setup` | DX setup epic |
| `epic:editorial-qa` | Editorial quality epic |
| `epic:ci-pipeline` | CI pipeline epic |
| `epic:safety` | Safety and security epic |
| `epic:skills` | Skill authoring epic |
| `epic:reasoning` | Reasoning skills epic |
| `epic:slack` | Slack integration epic |
| `epic:dispatch` | Dispatch workflow epic |
| `epic:agents-config` | Agent config epic |
```

- [ ] **Step 2: Rewrite `docs/agent-context.md`**

Replace entire file with the CWS-44 8-section schema. Content should reflect current state after Phase 1 Linear mutations complete. The 8 required sections:

```markdown
# Agent Context Ledger (Linear-Synced Cache)

This file is a bounded cache for agent continuity.

- Source of truth: Linear issues, projects, initiatives, and documents.
- Freshness SLA: 24 hours.
- Planning memory file: `docs/planning/linear-reorg-2026-03.md`
- Either platform (Codex or Claude Code) can update this ledger.
- If stale, do not trust this file until a new Linear sync pass is completed.

## Last Synced From Linear

- Synced at: `<current timestamp>`
- Synced by: `Claude Code`
- Scope: `CWS-93 backlog hygiene, label cleanup, and cycle rebaseline`
- Linear anchors:
  - `Content & Thought Leadership`
  - `Agentic Delivery Platform`
  - `Blog Content Pipeline`
  - `CWS-93` (In Progress)

## Stale After

- `<current timestamp + 24h>`
- Rule: if current time is later than this timestamp, run a new Linear sync before execution.

## Active Phase

- CWS-93 (backlog hygiene) is in progress.
- Phase 1 (Linear mutations) complete. Phase 2 (repo changes) in Graphite stack.
- CWS-80 (Done), CWS-82 (Done).

## Top Priorities

1. Complete CWS-93 backlog hygiene (this task)
2. CWS-81 normalization (parent)
3. Infrastructure chain: CWS-18 → CWS-5 → CWS-12

## Open Decisions

- CWS-14/48 voice profile interview: scheduling TBD
- CWS-83 repo split: deferred post-April 19, requires git history rewrite
- Cycle date correction: not available through current Linear MCP toolset

## Active Risks

- Editorial chain blocked until voice profile interview (CWS-14/48)
- Semgrep post-tool hook erroring (no SEMGREP_APP_TOKEN) — non-blocking but noisy

## Next 10 Actions

1. Merge CWS-93 Graphite stack
2. Close CWS-44 after agent-context.md rewrite merges
3. Close CWS-7 after label cleanup merges
4. Update CWS-81 remaining scope
5. Pick up CWS-18 (next infrastructure task)
6. Pick up CWS-5 (blocked by CWS-18)
7. Schedule CWS-14 voice profile interview session
8. Pick up CWS-13 (Vale config — unblocks CWS-25, CWS-32)
9. Pick up CWS-23 (unblocks CWS-36, CWS-31, CWS-38)
10. Correct Linear cycle dates through supported tooling

## Recent Completions

- CWS-80: Workspace rebaseline and drift audit (Done, merged)
- CWS-82: Dual-platform pivot — Claude Code as peer platform (Done, merged)
- CWS-1, 2, 3, 4: Cancelled (Linear onboarding noise)
```

Exact timestamps and issue ID will be filled at execution time based on current state.

- [ ] **Step 3: Validate CWS-44 acceptance criteria**

Run:
```bash
rg -n "Last Synced|Stale After|Active Phase|Top Priorities|Open Decisions|Active Risks|Next 10 Actions|Recent Completions" docs/agent-context.md
```
Expected: 8 matches, one per section header.

- [ ] **Step 4: Run `make qa-local`**

Run:
```bash
make qa-local
```
Expected: all checks pass.

- [ ] **Step 5: Commit PR 2**

Run:
```bash
gt create --all -m "chore: add label taxonomy and rewrite agent-context per CWS-44"
```

---

## Task 7: PR 3 — repo-flow Skill Hardening

**Files:**
- Modify: `.agents/skills/repo-flow/SKILL.md`
- Modify: `.agents/skills/repo-flow/references/branch-pr-merge.md` (branch prefix already updated in PR 1; verify no remaining issues)

- [ ] **Step 1: Add Gotchas section to SKILL.md**

Add after the `## Done Criteria` section (after line 57), before `## Rules`:

```markdown
## Gotchas

- `gt sync --force` after partial stack merges deletes branches and closes PRs. Never use it to
  reconcile a partially merged stack.
- `gh pr merge` directly bypasses validation gates in `make finalize-merge`. Always use
  `make finalize-merge PR=...` for single-PR merges.
- For Graphite stacks, `make finalize-merge` only merges one PR and does not manage Graphite
  metadata or retarget children. Use `gt merge` or Graphite web for full-stack merges.
```

- [ ] **Step 2: Add MUST NOT rules to Rules section**

Append to the existing `## Rules` section:

```markdown
- MUST NOT use `gh pr merge` directly — use `make finalize-merge PR=...`.
- MUST NOT use `gt sync --force` to reconcile after partial stack merges.
- For stacks, MUST use `gt merge` or Graphite web, not individual PR merges.
- MUST NOT create bulk commits — use atomic commits (one logical change per commit).
```

- [ ] **Step 3: Add validation loop pattern**

Add after the Rules section:

```markdown
## Validation Loop

1. Run `make qa-local`. If it fails, fix issues and re-run.
2. Do not commit until `make qa-local` passes.
3. If `make qa-local` fails twice consecutively, stop and report (per AGENTS.md loop safety).
4. If `make qa-local` fails, invoke `superpowers:systematic-debugging` to diagnose.
```

- [ ] **Step 4: Add cross-skill references**

Add after the Validation Loop section:

```markdown
## Cross-Skill References

These are Claude Code plugin skills — MUST be invoked during repo-flow execution:

- `superpowers:verification-before-completion` — invoke before claiming work is done.
- `superpowers:systematic-debugging` — invoke if `make qa-local` fails.
- `commit-commands:commit` — invoke for commit creation conventions.
```

- [ ] **Step 5: Verify branch prefix already updated in SKILL.md**

The branch prefix on line 60 should already read `cws/*` from PR 1. Verify:
```bash
grep "codex/" .agents/skills/repo-flow/SKILL.md
```
Expected: zero matches.

- [ ] **Step 6: Verify branch-pr-merge.md branch prefix**

The branch prefix on line 6 should already read `cws/` from PR 1. Verify:
```bash
grep "codex/" .agents/skills/repo-flow/references/branch-pr-merge.md
```
Expected: zero matches (Stack Merge Policy section uses `gt merge` / `make finalize-merge`, not branch name patterns).

- [ ] **Step 7: Run `make qa-local`**

Run:
```bash
make qa-local
```
Expected: all checks pass.

- [ ] **Step 8: Commit PR 3**

Run:
```bash
gt create --all -m "chore: harden repo-flow skill per CWS-82 lessons and agentskills.io"
```

---

## Task 8: PR 4 — Planning Doc Rewrite + Task File

**Files:**
- Rewrite: `docs/planning/linear-reorg-2026-03.md`
- Create: `docs/tasks/CWS-93.md`

- [ ] **Step 1: Create task file**

Create `docs/tasks/CWS-93.md`:

```markdown
# CWS-93: Backlog Hygiene, Label Cleanup, and Cycle Rebaseline

- Linear: https://linear.app/codewithshabib/issue/CWS-93
- Parent: CWS-81
- Branch: `cws/<id>-backlog-hygiene`
- Spec: `docs/superpowers/specs/2026-03-22-backlog-hygiene-design.md`
- Plan: `docs/superpowers/plans/2026-03-22-backlog-hygiene.md`

## Scope

Phase 1: Linear mutations (label cleanup 37→15, issue updates, project date removal, cycle rewrite)
Phase 2: Graphite stack of 4 PRs (branch prefix rename, AGENTS.md+agent-context, repo-flow hardening, planning doc rewrite)

## Evidence

- `make qa-local` passed on committed tree
- CWS-44 8-section validation passed
- Branch prefix grep returned zero matches
- Label count reduced from 37 to 15
```

- [ ] **Step 2: Rewrite `docs/planning/linear-reorg-2026-03.md`**

Rewrite the file with:
- Absorb "Confirmed Baseline" and "Lessons Learned" content from old agent-context.md
- Updated cycle layout reflecting current priorities after restack
- Updated dependency backbone
- Record this cleanup session's decisions and rationale
- Mark CWS-82 stack merge lessons as encoded in repo-flow skill
- Note editorial chain blocked on CWS-14/48
- Note CWS-83 family deferred post-April 19

Key content to absorb from old agent-context.md:
- **Confirmed Baseline** section (initiatives, projects, repurposed issues)
- **Lessons Learned** section (CWS-82 stack merge incident — now encoded in repo-flow)

Updated cycle layout should reflect:
- CWS-1-4 cancelled
- CWS-7 closing (label taxonomy done)
- CWS-44 closing (agent-context fixed)
- New issues CWS-88-92 placed appropriately
- CWS-83 family deferred to Low/post-April-19
- Editorial chain blocked until voice profile interview (CWS-14/48)
- Soft cycle model (spillover expected, WIP cap provides discipline)

- [ ] **Step 3: Run `make qa-local`**

Run:
```bash
make qa-local
```
Expected: all checks pass.

- [ ] **Step 4: Commit PR 4**

Run:
```bash
gt create --all -m "docs: rewrite cycle layout and planning doc post-hygiene cleanup"
```

---

## Task 9: Submit and Verify Stack

- [ ] **Step 1: Submit the full stack**

Run:
```bash
gt submit --stack --no-interactive --publish
```

This creates 4 PRs in Graphite, properly stacked.

- [ ] **Step 2: Verify all 4 PRs were created**

Run:
```bash
gt log --stack
```
Expected: 4 PRs listed, all targeting correct bases.

- [ ] **Step 3: Verify CI passes on all PRs**

Check GitHub checks:
```bash
gh pr checks <pr-number>
```
for each PR. Wait for CI to complete. If any fail, fix on the appropriate branch, amend, and `gt submit --stack --no-interactive`.

- [ ] **Step 4: Self-review each PR**

Review each PR's diff to confirm:
- PR 1: Only branch prefix changes, no `.codex/` directory renames
- PR 2: AGENTS.md has label taxonomy, agent-context.md has all 8 sections
- PR 3: SKILL.md has Gotchas, MUST NOT rules, validation loop, cross-skill refs
- PR 4: Planning doc is comprehensive, task file exists

- [ ] **Step 5: Invoke `superpowers:verification-before-completion`**

Before claiming stack is ready, invoke this skill to verify all acceptance criteria.

---

## Task 10: Post-Merge Cleanup

After the stack is merged (via `gt merge` or Graphite web):

- [ ] **Step 1: Close CWS-44**

Use `mcp__claude_ai_Linear__save_issue`:
- State: Done
- Comment: "agent-context.md rewritten to CWS-44 8-section schema. Merged in CWS-93 stack."

- [ ] **Step 2: Close CWS-7**

Should already be closed from Task 1 Step 1.

- [ ] **Step 3: Update CWS-81 remaining scope**

Use `mcp__claude_ai_Linear__save_comment`:
- Document what remains of CWS-81 after this cleanup.

- [ ] **Step 4: Mark cleanup issue as Done**

Use `mcp__claude_ai_Linear__save_issue`:
- State: Done

- [ ] **Step 5: Update `.remember/remember.md`**

Invoke `remember:remember` skill to save handoff state.
