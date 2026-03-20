# CodeWithShabib Agentic Workflow Master Plan

_Last updated: 2026-03-20_
_Document type: Unified Master Plan (PRD + TRD)_
_Version: 3.4 — dual-platform pivot (Codex + Claude Code)_

---

## Document Location and Versioning

This Master Plan is stored in two locations:

1. **Primary (versioned):** `docs/master-plan.md` in the `shabib87/shabib87.github.io` repository. Changes to this file are tracked by git and follow the same PR workflow as all repo changes. Major revisions should reference an ADR.
2. **Reference copy in Linear:** Attach the current version as a Linear document or paste into the project description of `[ORCHESTRATION] Agentic Workflow Design`. This is a read reference only — the repo copy is authoritative.

The plan is NOT stored only in Linear because:

- Linear documents are not git-versioned
- Linear does not support diff/PR review of document changes
- The plan references repo structure that should be co-located

---

## Purpose

This document is the single source of truth for the agentic operating model for the `shabib87/shabib87.github.io` repository. It consolidates the current-state audit, constraints, target architecture, Linear operating model, Codex orchestration design, editorial quality system, CI strategy, ADR strategy, Slack setup, and the implementation backlog discussed across the planning sessions.

The goal is to run this repository like a small specialist team:

- **Shabib** is the human principal, reviewer, editor-in-chief, and final approver.
- **Agent platforms** (Codex, Claude Code) provide specialist contributors that execute scoped work.
- **Linear** is the source of truth for planning, status, ownership, and bottlenecks.
- **GitHub** is the implementation and review surface.
- **Graphite** is used only for free stacked PR workflow management (Hobby tier).
- **Slack** is used for operational visibility (free plan, max 10 integrations).
- **GitHub Pages** remains the deployment mechanism for the Jekyll site.

---

## North Star

### Desired experience

A new idea should flow like this:

1. Start a chat from **Perplexity** (iOS, Android, Mac, or web) or **ChatGPT** (iOS, Android, Mac, or web).
2. Create a **Linear issue** from the conversation (Perplexity via Linear connector; ChatGPT via conversation).
3. The Linear issue body becomes the **execution brief**.
4. If needed, the parent issue is decomposed into smaller sub-issues.
5. A GitHub `workflow_dispatch` is triggered (from ChatGPT web/Mac via Codex sidebar, Perplexity via GitHub connector, or `gh` CLI). The dispatch workflow prepares a branch, fetches the Linear brief, and writes `docs/tasks/CWS-NNN.md`.
6. Shabib starts **Codex** (CLI, Mac app, IDE extension, or Codex Cloud via ChatGPT web/iOS sidebar) with the correct orchestrator prompt.
7. Agents perform the scoped work and open a draft PR.
8. Local hooks catch most failures before push.
9. CI validates the PR with the correct pipeline.
10. Graphite manages stacks when work is split across multiple PRs.
11. Linear tracks progress, ownership, and review state.
12. GitHub Pages auto-deploys when merged to `main`.

### Human-in-the-loop: exactly two touchpoints

The only manual steps in the steady-state workflow are:

1. **Idea creation** — drafting a blog post idea, PRD, or task description in a Perplexity or ChatGPT conversation (iOS, Android, Mac, or web), then creating the Linear issue.
2. **Final review before merge** — reviewing the draft PR, running manual judgment checks if editorial, and approving/merging.

Everything between those two steps is automated: dispatch, branch prep, task file creation, Codex notification, agent execution, PR creation, CI validation, and Linear status sync.

> **Note:** Codex execution itself is currently a manual trigger (Shabib opens Codex with the task). This is the one intermediate step that cannot be fully automated yet — there is no public API to programmatically start a Codex task as of March 2026. The dispatch workflow should post a Slack notification and Linear comment so Shabib knows a task is ready for Codex pickup.

### Operating philosophy

- No work happens outside a **Linear issue**.
- No implementation happens without **tests first**.
- No editorial publishing happens without a **quality gate**.
- No expensive automation runs in CI if the same guardrail can run locally.
- No paid feature is required for the baseline system.
- Humans own final judgment; agents own execution.

---

## Definition of Ready

A ticket must meet ALL of the following criteria before an agent can pick it up.

Definition of Ready for agent-pickable tickets:

1. **Linear issue exists** with status = `Todo` and label = `agent-task`
2. **Title follows convention:** `[DEV]`, `[EDITORIAL-NEW]`, or `[EDITORIAL-UPDATE]` prefix
3. **Description is complete:** Contains the structured execution brief (goal, acceptance criteria, scope boundaries, files expected to change)
4. **Acceptance criteria are testable:** Each criterion maps to a deterministic check (test passes, lint passes, build succeeds) or an explicit human judgment check (marked as `[HUMAN-REVIEW]`)
5. **Scope is bounded:** Single concern, estimated ≤ 1 agent session. If larger, decompose into sub-issues first.
6. **Branch is prepared:** `docs/tasks/CWS-NNN.md` exists on a prepared branch (created by dispatch workflow)
7. **Dependencies are resolved:** No blockers from other issues. If the issue depends on another, that issue must be `Done`.
8. **Required skills exist:** If the task needs a specific agent skill, that skill must already be committed to the repo.

Who enforces DoR:

- The dispatch workflow enforces items 1-3 and 6 (automated).
- Shabib enforces items 4-5, 7-8 (human judgment at issue creation time).
- Agents should CHECK DoR at the start of every task and refuse to proceed if any item fails, posting a comment on the Linear issue explaining what's missing.

---

## Verified Current State

### Repository reality

The repository already has meaningful automation and orchestration foundations:

- A Jekyll site repo with `_config.yml`, `_posts/`, `_pages/`, `_includes/`, `_sass/`, `assets/`, `.github/`, `.codex/`, `.agents/`, and `scripts/`.
- A `_drafts/` folder at the repo root for Jekyll draft posts. **This folder is currently gitignored and must be tracked by git** for the agentic workflow to function (agents need to create and edit drafts in branches).
- A Makefile that already exposes setup, editorial, QA, repo-flow, and skill governance commands.
- A working Codex multi-agent configuration in `.codex/`.
- Repo-local skills in `.agents/skills/`.
- Existing bash and Ruby scripts for validation, governance, PR flow, publishing, and audits.
- Existing tests, though coverage is partial.

### Existing content posture

The blog has a mix of older iOS-era posts and stronger recent principal-level posts. This means the repo needs two editorial tracks:

- **new post creation** (drafts start in `_drafts/`, move to `_posts/` on publish)
- **historical post UX/SEO refresh without rewriting original prose**

### Existing CI posture

There are already GitHub Actions workflows in place, but they are too coarse and not yet split cleanly into development vs editorial responsibilities.

### Existing Linear posture

The Linear workspace already has a team created and the team key is now `CWS`. There are default onboarding issues in the team that should be archived before the real backlog is created.

---

## Hard Constraints

These constraints are mandatory and drive every design choice.

### Cost constraints

- No paid Graphite plan. Use Hobby tier only (CLI for stacked PRs, VS Code extension, MCP, limited AI reviews).
- No paid Slack dependencies. Free plan: 90-day message history, 10 app integrations max, messages >1 year permanently deleted.
- No OpenAI API key stored in GitHub Actions (except for Codex GitHub Action if adopted for PR review — see CI section).
- No Codex agent execution inside CI (except the official `openai/codex-action@v1` for lightweight PR review, which uses its own API key scope).
- Keep GitHub Actions usage lean by shifting validation left into local hooks.

### Shabib's device profile

| Device                | OS      | Role in workflow                                                                                            |
| --------------------- | ------- | ----------------------------------------------------------------------------------------------------------- |
| Mac (desktop/laptop)  | macOS   | Primary development, Codex (CLI, App, IDE extension), GitHub, Linear, Graphite CLI, local Jekyll builds     |
| iPhone                | iOS     | Perplexity, ChatGPT (+ Codex Cloud sidebar), Linear, Slack, GitHub — idea capture and task triage on the go |
| Android phone         | Android | Perplexity, ChatGPT, Linear, Slack — secondary mobile surface, same capabilities as iOS                     |
| GitHub-hosted runners | Linux   | CI only — runs GitHub Actions workflows. Not a user-facing surface.                                         |

**No Windows machines.** All tooling, scripts, Makefiles, and documentation must assume macOS for local development and Linux for CI. No PowerShell, no `.bat`/`.cmd` files, no Windows path separators.

### Scripting language policy

The repo currently has:

- **22 bash scripts** (.sh) — all orchestration, setup, lint, QA, CI, hooks, repo-flow
- **2 Ruby validation scripts** — `validate-multi-agent-contracts.rb`, `validate-rollout-governance.rb`
- **2 Ruby library files** — `publish_draft.rb`, `publish_draft_core.rb` (the publish-draft pipeline)
- **2 Ruby test files** — `publish_draft_test.rb`, `rollout_governance_test.rb` (Minitest)
- **1 bash library** — `tooling.sh`
- The **Makefile** (bash shell) dispatches everything

Policy:

- **Keep both languages.** Bash is the orchestration glue (90% of scripts). Ruby is used where Jekyll ecosystem alignment matters — publishing drafts, YAML/front-matter parsing, and validation logic that benefits from Minitest + structured error handling.
- **Rule:** New scripts default to bash. Use Ruby only when: (a) the script deeply interacts with Jekyll/YAML structures, (b) the logic requires test coverage via Minitest, or (c) it's extending existing Ruby modules.
- **Makefile remains the single entry point.** All scripts are invoked through `make` targets — neither agents nor humans should call scripts directly.
- **Both languages must be available in CI and local dev.** Ruby comes pre-installed on macOS and is available on `ubuntu-latest` runners. The `setup-dev.sh` script should verify both are present.

### Platform constraints

- Site is **Jekyll**.
- Deploy is **GitHub Pages with custom domain**.
- CI must **not** own deploy.
- GitHub Pages auto-deploy on merge remains the deploy mechanism.
- The `_drafts/` folder must be **tracked by git** (remove from `.gitignore`). Jekyll ignores `_drafts/` in production builds by default; drafts are only rendered with `jekyll serve --drafts` or `show_drafts: true` in `_config.yml`.

### Workflow constraints

- Linear is the project management source of truth.
- Graphite is used only for stacked PR workflow on the free Hobby tier. **Slack notifications from Graphite require Starter tier ($20/user/month) — not available on free.** Use GitHub Actions Slack webhooks instead.
- Perplexity (iOS, Android, Mac, web) can be used for issue creation (via Linear connector) and GitHub workflow dispatch (via GitHub connector).
- ChatGPT (iOS, Android, Mac, web) can be used for issue creation, Codex Cloud task delegation (via sidebar), and GitHub interaction (via connected GitHub app — read-only; push/PR via Codex).
- Codex execution remains a **manual trigger** — no public API exists to programmatically start Codex tasks as of March 2026. Shabib picks up tasks from any Codex surface (CLI, Mac app, IDE extension, Codex Cloud web/iOS/Android).

---

## Current Gaps and Problems

### 1. `_drafts/` is gitignored

The `_drafts/` folder is currently in `.gitignore`. Agents cannot create or collaborate on draft posts in branches. **Fix:** Remove `_drafts/` from `.gitignore` and commit the folder. Jekyll will not publish drafts in production builds unless explicitly configured.

### 2. CI is not yet intentionally split

Current workflows are useful but not optimized for cost or clarity. The system needs separate pipelines for:

- **development / tooling / infrastructure work**
- **editorial / post-quality work**

### 3. Local validation is not yet the primary gate

The correct cost-aware pattern is:

- fast checks in **pre-commit**
- heavier validation in **pre-push**
- CI as confirmation, not discovery

### 4. TDD is not yet first-class everywhere

Scripts exist, but not every script has complete test coverage. Tests need to become mandatory for all automation, including editorial validation scripts.

### 5. Editorial quality is only partially codified

The desired editorial quality system includes:

- front matter validation
- markdown lint
- spelling
- grammar
- storytelling structure
- tone and writing style
- audience alignment
- fact checking
- SEO
- principal-level authority

Only some of that is currently formalized.

### 6. Prompt and agent flow need stronger contracts

The repo already has prompts and agents, but they need a more explicit contract model tied to Linear issues, per-task `docs/tasks/CWS-NNN.md` input, and test-first behaviour.

### 7. Repo organization can be clearer

The repo is powerful but dense. It needs better top-level organization and a formal ADR structure so architectural choices are recorded and discoverable.

### 8. Slack visibility is not yet wired

Slack should be used for free visibility, but only with integrations available on free plans. The 10-integration limit must be budgeted carefully.

### 9. Task file is global, not per-issue

The current `CODEX_TASK.md` is a single file at a fixed location. It should be per-task under `docs/tasks/` with the Linear issue ID in the filename, persisted as a historical record after merge.

---

## Trigger Surfaces — Validated March 2026

### Perplexity (iOS, Android, Mac, Web)

**Available surfaces:** iOS app, Android app, Mac app (Perplexity Computer), web app (perplexity.ai).

Connected integrations (already active):

- **Linear** — create issues, query workspace
- **GitHub** — read repos, trigger workflow_dispatch via GitHub connector
- **Slack** — post messages, read channels

Use for:

- Idea shaping and research
- Repo-aware discussion
- Linear issue creation (via Linear connector)
- GitHub workflow dispatch trigger (via GitHub connector)
- Slack notifications

### ChatGPT (iOS, Android, Mac, Web)

**Available surfaces:** iOS app, Android app, Mac desktop app, web app (chatgpt.com).

Capabilities:

- **GitHub app connection** (Settings → Apps → GitHub): read-only access to repos for code analysis and discussion. **Cannot push code or trigger workflows directly.** Code changes go through Codex.
- **Codex Cloud** (sidebar in ChatGPT web, or via chatgpt.com/codex): delegate coding tasks that run in sandboxed cloud environments, produce PRs on connected GitHub repos. Also accessible from ChatGPT iOS/Android.
- **Codex App** (standalone Mac desktop app): multi-agent management, worktrees, automations.

Use for:

- Idea shaping and discussion
- Linear issue creation (via conversation, then manual creation or Codex task)
- Delegating Codex Cloud tasks from any surface (iOS, Android, Mac, web) via the Codex sidebar
- Code Q&A with connected GitHub repos

**Important limitation:** ChatGPT's GitHub integration is **read-only**. To trigger `workflow_dispatch`, use one of:

1. Perplexity (via GitHub connector)
2. `gh workflow run` from CLI
3. GitHub REST API call
4. GitHub Actions UI

### Codex (CLI, Mac App, IDE Extension, Cloud)

> **Note:** For Claude Code capabilities, see `CLAUDE.md` and `docs/sop.md` Section 1.8.

Available surfaces as of March 2026:

| Surface             | Platform                                             | Status                          |
| ------------------- | ---------------------------------------------------- | ------------------------------- |
| Codex CLI           | macOS (user), Linux (CI-only)                        | Stable, open-source, Rust-based |
| Codex Mac App       | macOS (Apple Silicon)                                | Stable since Feb 2026           |
| Codex IDE Extension | VS Code, Cursor, Windsurf, JetBrains (macOS)         | Stable                          |
| Codex Cloud         | Web (chatgpt.com/codex), ChatGPT iOS/Android sidebar | Stable                          |

Key capabilities:

- Multi-agent support (experimental in CLI; native in app)
- Worktrees for isolated agent work (app)
- Skills system (`.agents/skills/`) for repeatable workflows
- `AGENTS.md` for repo-level policy
- `openai/codex-action@v1` GitHub Action for CI-based PR review
- MCP server mode (Codex CLI as MCP server for Agents SDK orchestration)
- Default model: `gpt-5.3-codex`

**Trigger model:** Manual. Shabib starts Codex after the dispatch workflow prepares the branch and task file. No programmatic trigger API exists.

**Use only after** the issue exists and the branch has been prepared with `docs/tasks/CWS-NNN.md`.

Codex is not the planner of record. Linear is.

### Claude Code (CLI, IDE Extension)

Available surfaces as of March 2026:

| Surface                   | Platform                              | Status         |
| ------------------------- | ------------------------------------- | -------------- |
| Claude Code CLI           | macOS, Linux                          | Stable         |
| Claude Code IDE Extension | VS Code                               | Stable         |

Key capabilities:

- Dynamic subagent dispatch via `Agent` tool (prompt-based, no config files)
- `CLAUDE.md` as session-start instruction surface
- Persistent file-based memory system (`~/.claude/`)
- Git worktree isolation for subagents
- MCP support (Linear, Context7)
- Skills system (reads `.agents/skills/` SKILL.md files; agentskills.io compatible)
- Hooks system for automated behaviors

**Trigger model:** Manual. Same as Codex — Shabib starts Claude Code with the task after the
branch and task file are prepared.

**Use only after** the issue exists and the branch has been prepared with `docs/tasks/CWS-NNN.md`.

Claude Code is not the planner of record. Linear is.

---

## Canonical Flow

### Flow A: Development workflow

1. User discusses a repo/process/site improvement on **Perplexity or ChatGPT** (iOS, Android, Mac, or web).
2. Assistant creates a **[DEV]** Linear issue using the structured template (Perplexity via Linear connector; ChatGPT via conversation then manual creation).
3. If the task crosses more than two concern layers, it is decomposed into sub-issues.
4. **Workflow dispatch is triggered** via one of: Perplexity GitHub connector, `gh workflow run`, GitHub API, or GitHub UI.
5. GitHub dispatch workflow fetches the Linear issue body and writes `docs/tasks/CWS-NNN.md` into a new branch. Posts a Slack notification and Linear comment that the task is ready for Codex.
6. Shabib opens Codex (CLI, app, IDE extension, or Cloud) with the **dev orchestrator prompt**, pointing to the prepared branch.
7. Codex reads `docs/tasks/CWS-NNN.md`, verifies a failing test exists or writes it first.
8. Codex implements the task and opens a draft PR.
9. Local hooks and CI validate.
10. Shabib reviews, approves, and merges.

### Flow B: Editorial-new workflow

1. User has a new blog idea on **Perplexity or ChatGPT** (iOS, Android, Mac, or web).
2. Assistant creates a **[EDITORIAL-NEW]** Linear issue using the structured template.
3. If needed, work is decomposed into sub-issues or a short stack.
4. Dispatch is triggered (same mechanisms as Flow A).
5. GitHub writes `docs/tasks/CWS-NNN.md` to a prepared branch.
6. Shabib opens Codex with the **editorial-new orchestrator prompt**.
7. Agents create content in `_drafts/` first, then move through research, drafting, editing, fact-check framing, and publishing prep. When ready, the post is moved from `_drafts/` to `_posts/` with proper front matter and date.
8. Automated editorial checks run locally and in CI.
9. Manual judgment checks are run by Shabib via Codex prompts.
10. Shabib merges when satisfied.

### Flow C: Editorial-update workflow

1. User identifies an old post that needs SEO/UX refresh on **Perplexity or ChatGPT** (any surface).
2. Assistant creates an **[EDITORIAL-UPDATE]** Linear issue.
3. Dispatch writes `docs/tasks/CWS-NNN.md`.
4. Shabib runs Codex with the **editorial-update orchestrator prompt**.
5. The historical-post-editor applies metadata/UX/SEO-safe changes only.
6. Automated checks run.
7. SEO review and final manual sign-off occur.
8. Shabib merges.

---

## Per-Task File Strategy

### Why per-task files

A single `CODEX_TASK.md` creates conflicts when multiple tasks are in flight and loses history after each run. Per-task files solve both problems.

### Location and naming

```text
docs/tasks/CWS-NNN.md
```

Where `NNN` is the Linear issue number (e.g., `docs/tasks/CWS-42.md`).

### Lifecycle

| Phase                    | State                                                             |
| ------------------------ | ----------------------------------------------------------------- |
| Dispatch workflow runs   | File created at `docs/tasks/CWS-NNN.md` with Linear issue content |
| Codex picks up task      | Agent reads from `docs/tasks/CWS-NNN.md`                          |
| Task complete, PR merged | File persists as historical record                                |

### Single-Writer Status Model

- Linear is the mutable execution-status source of truth (`Backlog`/`Todo`/`In Progress`/`In Review`/`Done`).
- `docs/tasks/CWS-NNN.md` is a local execution-context snapshot and evidence pointer.
- Do not maintain mutable status fields in task files. Keep status transitions in Linear only.

### File structure

```markdown
# CWS-NNN: [Issue Title]

## Linear Issue

- **ID:** CWS-NNN
- **URL:** https://linear.app/codewithshabib/issue/CWS-NNN
- **Workflow:** [Dev | Editorial-New | Editorial-Update]
- **Executor:** [Agent | Human | Hybrid]
- **Created:** YYYY-MM-DD

## Brief

[Full issue description from Linear]

## Acceptance Criteria

[Extracted from issue body]

## Validation Commands

[Deterministic validation command list]

## Captured From Linear

- Timestamp: YYYY-MM-DD HH:MM:SS TZ

## Evidence (Optional)

- PR: https://github.com/<owner>/<repo>/pull/<id>
- Completed at: YYYY-MM-DDTHH:MM:SSZ

## Labels

[Labels from Linear]

## Decomposition

[Sub-issues if any, with their CWS IDs]
```

Canonical template: `docs/tasks/TEMPLATE.md`.

### Git tracking

The `docs/tasks/` directory is tracked by git. Task files are committed on the prepared branch by the dispatch workflow and persist through merge to `main`.

### Agent contract

Every orchestrator prompt must reference the task file by its per-task path:

> Read the execution brief from `docs/tasks/CWS-NNN.md` (the specific file path is provided when Codex is started).

---

## Linear Operating Model

### Team

- Team name: **Codewithshabib**
- Team key: **CWS**

### Clean-up step

Archive the default Linear onboarding issues before creating the real backlog:

- `CWS-1`
- `CWS-2`
- `CWS-3`
- `CWS-4`

These are onboarding artifacts, not project work.

### Statuses

Use the existing team workflow states:

- Backlog
- Todo
- In Progress
- In Review
- Done
- Canceled
- Duplicate

### Label taxonomy

#### Executor

Exactly one of:

- `Human`
- `Agent`
- `Hybrid`

#### Bottleneck

Exactly one of:

- `Waiting-Human`
- `Waiting-Agent`
- `Ready`

#### Workflow

Exactly one of:

- `Dev`
- `Editorial-New`
- `Editorial-Update`

#### Stage

Exactly one of:

- `Spec`
- `Implementation`
- `Review`
- `Merge-Ready`

#### Type / focus tags

Reusable labels:

- `Epic`
- `Task`
- `Chore`
- `ADR`
- `Slack`
- `CI`
- `Hooks`
- `TDD`
- `SEO`
- `Writing`
- `Fact-Check`

### Ownership model

#### Human means

A task requires Shabib to:

- make a decision
- define policy
- review architecture
- create accounts/workspaces/secrets
- approve final content or merge

#### Agent means

A task is safe for an agent to execute with the right prompt and constraints.

#### Hybrid means

An agent can do most of the implementation, but the task includes a human checkpoint or approval step.

### Linear ↔ GitHub integration

Linear's native GitHub integration (free, included) provides:

- PR linking via branch name containing issue ID (e.g., `feature/CWS-42-short-slug`)
- Automatic status transitions: issue moves to In Progress when PR is opened, Done when merged
- Bidirectional comment sync
- Assignee sync

Configure per-team workflow automations in Linear settings.

---

## Branching and PR Conventions

### Canonical branch names

- `feature/CWS-NNN-short-slug`
- `fix/CWS-NNN-short-slug`
- `editorial/CWS-NNN-short-slug`
- `chore/CWS-NNN-short-slug`

The `CWS-NNN` in the branch name triggers Linear's GitHub integration to auto-link the PR.

### PR body requirement

Every PR must include:

- `Closes CWS-NNN`
- summary
- why
- validation
- affected files
- affected URLs
- ADR reference if applicable

### Stacked PR strategy

#### Rule of thumb

- **Single PR** if the task touches one or two concern layers.
- **Stacked PRs** if the task crosses more than two concern layers.

#### Concern layers

Examples of layers:

- repo tooling / scripts
- CI / automation
- docs / ADR / prompts
- site templates / config
- editorial content / metadata / SEO

#### Examples

Single PR examples:

- add a front matter validator
- update one hook
- fix one editorial metadata issue
- add one vale rule

Stack examples:

- introduce a new workflow that requires scripts + CI + docs
- new editorial flow requiring prompts + validators + docs + templates
- repo reorganization requiring scripts + Makefile + docs + CI changes

#### Graphite free tier scope

On the Hobby (free) tier, Graphite provides:

- CLI for creating and managing stacked PRs (`gt create`, `gt submit`, `gt stack`)
- VS Code extension
- MCP integration
- PR inbox and notifications
- Limited AI reviews and chat

Not available on free tier:

- Slack notifications (requires Starter, $20/user/month)
- Merge queue (requires Team, $40/user/month)
- Automations (requires Team)
- GitHub Organization repo support (requires Starter)

Stack merge on free tier uses standard GitHub merge — Graphite CLI handles rebase ordering.

---

## Repo Structure Strategy

### Existing important directories

- `.codex/` for Codex config, prompts, docs, manifests, rollout evidence
- `.agents/skills/` for repo-local skills
- `.github/workflows/` for CI workflows
- `scripts/` for automation
- `_posts/` for published content
- `_drafts/` for draft content (**must be tracked by git**)

### Target organization improvements

#### Keep

- `.codex/` as the Codex control plane
- `.agents/skills/` as the repo-local skills directory (shared across platforms)
- `.agents/roles/` as the shared agent role definitions directory (created by CWS-23)

#### Add / improve

- **`_drafts/`** — remove from `.gitignore`, track in git. Jekyll ignores this folder in production builds by default.
- **`docs/tasks/`** — per-task execution briefs, named `CWS-NNN.md`, persisted as history after merge.
- **`docs/adr/`** — human-facing decision records
- **`tests/unit/`** and **`tests/integration/`**
- **`scripts/hooks/`**
- **`styles/Codewithshabib/`** — Vale rules
- **`.codex/docs/templates/`** — intake templates

---

## TDD Policy

### Core rule

No automation or validation code ships without tests.

#### Applies to

- hook scripts
- validation scripts
- SEO audit scripts
- fetch-linear-issue helper
- ADR scaffolding helper
- CI helper scripts
- any script added under `scripts/`

#### Test layout

- `tests/unit/` for isolated logic
- `tests/integration/` for multi-step flow tests

#### Required behaviour

- failing test first
- implementation second
- green test run before PR

#### Agent contract update

The developer agent instructions must explicitly say:

> Before writing any implementation, create a failing test that covers the acceptance criteria from the Linear issue. Do not open a PR without test coverage for every new or modified script.

---

## Local Hooks Strategy

### pre-commit

Purpose: catch fast editorial issues before a commit exists.

#### Run on staged `_posts/**` and `_drafts/**` files only

- front matter schema validation
- markdownlint
- cspell

#### pre-commit behavior

- if no editorial files are staged: exit 0
- fast-fail with clear file-level error messages

### pre-push

Purpose: catch expensive failures before remote CI.

#### Run before every push

- ruby tests
- `make check`
- vale
- SEO audit on changed posts

#### pre-push behavior

- block push on any failure
- show grouped error summary

### Installation

- `make setup` installs/symlinks both hooks
- no Husky / no Lefthook / no extra JS dependency

---

## CI Architecture

### Principles

- CI validates, not deploys
- CI is split by concern
- CI is path-filtered
- CI never runs Codex agents for task execution
- CI may use `openai/codex-action@v1` for lightweight PR review (requires `OPENAI_API_KEY` secret scoped to that workflow only)

### dev-pipeline.yml

Trigger paths:

- `scripts/**`
- `.codex/**`
- `.agents/**`
- `_config.yml`
- `_includes/**`
- `_layouts/**`
- `_sass/**`
- `assets/**`
- `.github/workflows/**`

#### dev-pipeline job order

1. `test`
2. `lint`
3. `security`
4. `governance`
5. `jekyll-build`

#### dev-pipeline notes

- no deploy
- ADR warning/check when architecture-level files change

### editorial-pipeline.yml

Trigger paths:

- `_posts/**`
- `_drafts/**`

#### editorial-pipeline job order

1. `test`
2. `spell-check`
3. `grammar-and-style`
4. `markdown-lint`
5. `seo-audit`

#### editorial-pipeline notes

- no Jekyll build required in baseline plan
- no deploy
- all checks should be readable as separate jobs in GitHub Actions UI

### Code security

Security scanning strategy:

Layer 1: Semgrep CE (local + CI)

- Run Semgrep Community Edition with `--config auto` for Ruby, JavaScript, HTML, YAML
- **Local:** Run in pre-push hook via `make security` (already exists as `run-security-checks.sh`, now covers Semgrep CE)
- **CI:** Add `semgrep.yml` workflow triggered on PRs. Uses the free `semgrep/semgrep` Docker image. No `SEMGREP_APP_TOKEN` needed for CE mode — just `semgrep scan --config auto`.
- **Cost:** Free. CE is fully open source. No account required for basic scanning.
- **Why Semgrep:** Fast (no build required), works on source code directly, good for Ruby/JS/HTML. Catches injection, XSS, insecure patterns.

Layer 2: CodeQL (CI only)

- GitHub's native SAST. Free for public repositories (shabib87.github.io is public).
- Add `codeql.yml` workflow triggered on PRs and push to `main`.
- Use `github/codeql-action/init@v3` + `github/codeql-action/analyze@v3`
- Languages: `ruby`, `javascript` (covers the Jekyll repo's stack)
- Results appear in the GitHub Security tab — no extra tooling needed.
- **Cost:** Free for public repos. Would require GitHub Advanced Security license ($49/seat/month) for private repos.
- **Why CodeQL:** Deeper interprocedural analysis, good complement to Semgrep. Native GitHub integration means findings show inline on PRs.

Layer 3: Dependabot (already available)

- GitHub Dependabot is already free and enabled by default on public repos.
- Security updates for gems and npm packages.
- No additional configuration needed beyond ensuring `Gemfile.lock` and `package-lock.json` are committed.

Security = first-class guardrail rule:

- Security checks are blocking on PRs — same as tests (TDD) and lint.
- No PR merges with critical/high Semgrep or CodeQL findings.
- Security checks run in CI (not just local) because they are non-negotiable.
- The editorial pipeline does NOT need CodeQL (content-only changes), but Semgrep still runs for front-matter/template injection.
- Add `make security` to the Definition of Done alongside `make check`.

### codex-dispatch.yml

Trigger: `workflow_dispatch` with inputs `issue_id` and `workflow_type`.

See Dispatch Workflow Design section for full spec.

### notify-merge.yml

A lightweight merge notification workflow posts to Slack when commits land on `main`.

### Optional: codex-pr-review.yml

Use `openai/codex-action@v1` for automated PR review comments. This is the **only** CI workflow that should use an OpenAI API key. Scoped to `pull_request` events only. Runs Codex in a sandboxed read-only mode to post review feedback, not execute tasks.

---

## Editorial Quality System

### Automated checks (deterministic, free, CI-friendly)

These are the baseline editorial tests:

1. **Front matter schema**
2. **Markdown lint**
3. **Spelling**
4. **Grammar**
5. **Storytelling structure**
6. **Tone and writing style**
7. **SEO audit**

#### Note

The original discussion grouped six automated checks, but storytelling, tone/style, and SEO were all important enough that the implemented system should treat them as distinct validation concerns even if some share the same Vale engine.

### Manual judgment checks (agent-assisted, human-triggered)

These are required before editorial merge:

1. **Audience alignment check**
2. **Fact check**
3. **Authority check**
4. **Final editorial sign-off**

#### Why manual?

Because these require judgment, not just rule matching. They should be run as manual Codex prompts and reviewed by Shabib before merge.

### Editorial draft workflow

New posts follow the Jekyll `_drafts/` convention:

1. Agent creates post in `_drafts/` (no date prefix required per Jekyll convention).
2. Automated and manual checks run against the draft.
3. When approved, agent moves the file to `_posts/` with the proper `YYYY-MM-DD-` date prefix.
4. PR is ready for final merge review.

---

## Editorial Standards to Encode

### Voice profile

A new file is required:

- `.codex/docs/editorial-voice-profile.md`

It should define:

- target audience
- tone
- sentence rhythm
- authority expectations
- banned filler language
- acceptable use of personal perspective
- how much explanation is too much for principal-level readers

### Authority rubric

A new file is required:

- `.codex/docs/editorial-voice-eval-rubric.md`

It should score:

1. **Non-obvious perspective** — does this say more than a search result summary?
2. **Concrete opinion** — does the piece take a position?
3. **Experience signal** — does it reflect real trade-offs, not abstract restatement?
4. **Principal-level depth** — does it go beyond mechanics into reasoning and consequences?

### Vale custom rules

Create a style pack in:

- `styles/Codewithshabib/`

Rules to include:

- `NoPassiveVoice` / `ActiveVoicePreference`
- `NoFillerOpeners`
- `NoPrincipalHedging`
- `StoryStructure`

---

## Multi-Agent Design

### Roles already present in the repo

The repo already has agent definitions for:

- team-lead
- researcher
- developer
- seo-expert
- writer
- editor
- fact-checker
- publisher-release
- historical-post-editor

### Agent Identity System

Each agent has a One Piece character identity that maps to their role. These identities are used in agent definitions (Codex `config.toml`, Claude Code dispatch prompts), skill descriptions, prompt headers, and Slack notifications for personality and quick identification.

| Agent Name            | One Piece Character | Role                     | Rationale                                                                    |
| --------------------- | ------------------- | ------------------------ | ---------------------------------------------------------------------------- |
| Luffy the Captain     | Monkey D. Luffy     | team-lead / orchestrator | Captain who sets direction and delegates to the crew                         |
| Zoro the Swordsman    | Roronoa Zoro        | developer                | First mate — cuts through problems with raw skill and discipline             |
| Nami the Navigator    | Nami                | researcher               | Charts the course — finds information, maps the territory                    |
| Sanji the Cook        | Sanji               | writer                   | Crafts something nourishing from raw ingredients — turns research into prose |
| Chopper the Doctor    | Tony Tony Chopper   | editor                   | Diagnoses problems and heals the content — fixes what's broken               |
| Robin the Scholar     | Nico Robin          | fact-checker             | Archaeologist who deciphers truth from history and sources                   |
| Franky the Shipwright | Franky              | publisher-release        | Builds and maintains the ship — packaging, deployment, CI                    |
| Brook the Musician    | Brook               | seo-expert               | Brings life and rhythm to content — SEO, discoverability, audience reach     |
| Jinbe the Helmsman    | Jinbe               | historical-post-editor   | Steady hand that steers legacy content through safe waters without capsizing |

Agent names follow the format `<Name> the <Role>`. These names are used in agent definitions (Codex `config.toml`, Claude Code dispatch prompts), skill descriptions, prompt headers, and Slack notifications for personality and quick identification.

The naming convention is extensible. New agents (including reasoning agents) follow the same pattern using One Piece characters whose traits match the role.

### Agent Safety Rules

#### Loop prevention

If an agent attempts the same action 3 times with the same inputs and gets the same result, it MUST stop immediately. The agent MUST:

1. Summarize what was attempted and what failed.
2. Post the summary as a comment on the Linear issue.
3. Set the issue status to `Blocked`.
4. Do NOT retry, do NOT attempt a workaround.

For scripts: All retry-capable scripts in `scripts/` MUST include a retry counter (max 2 retries). After exhausting retries, the script MUST exit with a non-zero code and a human-readable error message. Silent infinite retries are prohibited.

#### Stuck-agent escalation

If an agent cannot make progress for any reason (missing file, permission error, ambiguous requirement), it MUST:

1. Stop work immediately.
2. Write a comment on the Linear issue describing the blocker.
3. Post a notification to `#codex-runs` via Slack webhook.
4. Do NOT guess or improvise around the blocker.

#### Concurrency limits

**Codex:** Set explicit limits in `config.toml`:

```toml
[agents]
max_threads = 3
max_depth = 1
```

**Claude Code:** No native concurrency config. The orchestrator enforces the same limits through
prompt discipline — batch `Agent` tool calls to 3 or fewer per message, and agents do not spawn
sub-agents.

- **max_threads = 3**: Never more than 3 parallel agents. If a task needs more lanes, batch them across turns.
- **max_depth = 1**: Sub-agents MUST NOT spawn their own sub-agents. Only the orchestrator (Luffy) delegates.

The orchestrator skill MUST include:

```text
CONCURRENCY LIMIT: Never delegate more than 3 parallel agents.
If the plan has more than 3 parallel lanes, batch them:
- Turn 1: Launch lanes 1-3, wait for results.
- Turn 2: Launch remaining lanes.
- Final: Synthesize all results.
```

### Agent Configuration Structure

Each agent is defined by three layers, separating identity, behavior, and function. Role files
are shared across platforms; platform-specific config stays in the platform directory:

```text
.agents/roles/<agent-name>/       # Shared across platforms (created by CWS-23)
├── soul.md                       # Behavioral: identity, values, guardrails, personality
└── instructions.md               # Operational: what to do, how to do it, boundaries

.codex/agents/<agent-name>/       # Codex-specific
└── config.toml                   # Functional: tools, permissions, model assignment
```

**Claude Code dispatch:** Claude Code reads `soul.md` and `instructions.md` from
`.agents/roles/<name>/` and incorporates them into the `Agent` tool prompt at dispatch time.
No TOML config is needed — Claude Code's agent dispatch is prompt-based.

**`soul.md`** defines who the agent IS — personality, values, and behavioral guardrails. Inspired by DeerFlow's SOUL.md pattern. This is separate from functional instructions.

Example `soul.md` for Zoro the Swordsman (developer):

```markdown
# Zoro the Swordsman — Developer

You are Zoro the Swordsman — disciplined, direct, and relentless.

## Values

- Precision over speed. Measure twice, cut once.
- Tests come before code. Always.
- Your scope is your boundary. Stay in your lane.

## Guardrails

- You MUST NOT start coding until tests are written.
- You MUST NOT touch files outside your assigned scope.
- You MUST NOT merge or approve PRs — only create them.
- You MUST NOT modify editorial content (\_posts/, \_drafts/, \_pages/).
- If you're stuck, you report the obstacle — you MUST NOT hack around it.
```

**`instructions.md`** defines the operational boundaries using MUST NOT language:

```markdown
## Boundaries

- MUST NOT modify: \_posts/, \_drafts/, \_pages/, docs/editorial/
- MUST NOT run: make publish-draft, make qa-publish, make finalize-merge
- MUST NOT merge, approve, or close PRs
- MUST NOT modify AGENTS.md, config.toml, or other agent configs
- MUST report and STOP if a task requires changes outside these boundaries
```

Each agent role gets its own boundary set. See the full boundary matrix below.

#### Agent Boundary Matrix

| Agent                     | MUST NOT modify                                | MUST NOT run                        | Special restrictions                                |
| ------------------------- | ---------------------------------------------- | ----------------------------------- | --------------------------------------------------- |
| Zoro (developer)          | \_posts/, \_drafts/, \_pages/, docs/editorial/ | make publish-draft, make qa-publish | MUST NOT touch editorial content                    |
| Sanji (writer)            | scripts/, .github/, Makefile, config files     | make setup, make ci-setup           | MUST NOT touch infrastructure                       |
| Chopper (editor)          | scripts/, .github/, Makefile, config files     | make setup, make ci-setup           | MUST NOT touch infrastructure                       |
| Robin (fact-checker)      | ALL files (read-only)                          | Any write commands                  | MUST NOT modify any file — only report findings     |
| Nami (researcher)         | ALL files (read-only)                          | Any write commands                  | MUST NOT modify any file — only report findings     |
| Franky (publisher)        | \_posts/ content, \_drafts/ content            | N/A                                 | MUST NOT change post body prose — only packaging/CI |
| Brook (SEO)               | scripts/, .github/, Makefile                   | make setup                          | MUST NOT touch infrastructure                       |
| Jinbe (historical editor) | scripts/, .github/, Makefile, config files     | make setup, make ci-setup           | MUST NOT change original publish dates              |
| Luffy (orchestrator)      | Direct file modifications                      | Direct implementation commands      | MUST delegate, MUST NOT execute directly            |

### Required prompt set

#### Dev

- `.codex/prompts/dev-workflow.md`

#### Editorial new

- `.codex/prompts/editorial-new.md`

#### Editorial update

- `.codex/prompts/editorial-update.md`

#### Manual judgment prompts

Create:

- `.codex/prompts/editorial-checks/audience-check.md`
- `.codex/prompts/editorial-checks/fact-check.md`
- `.codex/prompts/editorial-checks/authority-check.md`
- `.codex/prompts/editorial-checks/final-sign-off.md`

### Orchestrator Design — Two-Phase Execution

The orchestrator skill (Luffy the Captain) separates planning from execution. This is inspired by DeerFlow's Coordinator/Planner/Executor separation.

#### Phase 1: Plan

1. Read the task file (`docs/tasks/CWS-NNN.md`).
2. Read `docs/agent-context.md` for project context.
3. Produce a numbered execution plan:
   - What agents are needed (by name)
   - What each agent will do (bounded scope)
   - Execution order: parallel vs sequential
   - Validation gates between steps
   - Expected deliverables
4. Post the plan as a **Linear issue comment** (permanent record).
5. Post a short notification to **`#codex-runs` via Slack webhook**: "Plan ready for CWS-NNN: [Linear link]".
6. **STOP and wait for Shabib's approval.**

This is the **Option C plan review gate**: Linear is the record, Slack is the notification. Shabib reviews the plan in Linear (any device), replies with approval or edits.

#### Phase 2: Execute

Once the plan is approved (Shabib re-invokes the agent with "Plan approved, proceed" or provides edits). In Claude Code, the same session can continue directly; in Codex, Shabib re-invokes with the approval:

1. Execute each step by delegating to the appropriate agent.
2. Track progress against the numbered plan.
3. If any step fails, STOP and report — do NOT improvise a workaround.
4. After all steps complete, run the self-audit checklist (see below).
5. Create the PR.

#### Prompt requirements

Every orchestrator prompt MUST:

- Read the brief from `docs/tasks/CWS-NNN.md` (path provided at Codex start)
- Read `docs/agent-context.md` for project state
- Define agent sequence with explicit role assignments
- Require test-first behavior where relevant
- Define output contract (what files change, what tests pass)
- Define completion signal
- Use MUST NOT language for out-of-scope prohibitions
- Include the self-audit checklist before PR creation

#### Clarification Protocol

Before starting work, the orchestrator MUST verify:

1. **SCOPE**: Is the task boundary clear? If not, ask: "Should this include X or is X out of scope?"
2. **APPROACH**: Is there more than one reasonable approach? If so, ask: "Option A vs Option B — which do you prefer?"
3. **RISK**: Does the change touch published content, CI config, or AGENTS.md? If so, ask: "This changes [X] which affects [Y]. Proceed?"
4. **MISSING**: Is any required input missing (file path, date, slug)? If so, ask for it.

Ask ONE question at a time. Wait for the answer before proceeding.
Do NOT ask clarifying questions for routine tasks fully covered by existing AGENTS.md rules.

#### Special constraint for editorial-new

New posts MUST be created in `_drafts/` first and only moved to `_posts/` after all automated checks pass.

#### Special constraint for editorial-update

The agent MUST NOT:

- Change body prose
- Change original publish date
- Use the workflow for substantive rewrites

### Self-Audit Checklist

Before creating the PR, the orchestrator MUST verify all of the following. If any item fails, the agent MUST fix it or report the failure — MUST NOT create the PR with known failures.

- [ ] All acceptance criteria from `docs/tasks/CWS-NNN.md` are met
- [ ] No files modified outside the declared scope (check `git diff --name-only`)
- [ ] Tests written and passing (`make check`)
- [ ] Security scan passing (`make security`)
- [ ] Lint passing (`make lint`)
- [ ] `docs/agent-context.md` updated if project state changed
- [ ] All commit messages reference `CWS-NNN`
- [ ] Branch name follows convention
- [ ] PR description includes Linear issue link
- [ ] Total diff is ≤ 500 lines changed (if larger, flag for decomposition review)

---

## Agent Context System

### Agent context purpose

Agent platforms have limited or no built-in cross-session memory (Codex has none; Claude Code has a file-based memory system). To provide project continuity, agents read and update a persistent context file.

### File: `docs/agent-context.md`

Format: **Markdown** (not JSON/JSONL). Rationale:

- Both Codex and Claude Code read markdown natively — consistent with AGENTS.md, SKILL.md, and task files.
- Human-readable and human-editable for periodic review.
- Clean git diffs for PR review.
- No parsing overhead — agents read it directly.

### Structure

```markdown
# Agent Context — CodeWithShabib

_Last updated: YYYY-MM-DD by [agent-name] during CWS-NNN_

## Current Focus

- [3-5 bullet points of active workstreams]

## Recent Decisions

- [ADR references, recent architectural choices with brief rationale]

## Known Constraints

- [Free tier limits, tooling quirks, unresolved issues, blockers]

## Editorial State

- Posts in draft: [list]
- Recently published: [list]
- Scheduled: [list]

## Open Questions

- [Anything unresolved that the next agent should be aware of]
```

### Rules

- Every agent MUST read `docs/agent-context.md` before starting work.
- Every agent MUST update the relevant section if project state changed during the task.
- Updates are committed as part of the task branch — reviewed in the PR like any other change.
- Shabib reviews the context file periodically and corrects any drift.
- Add to `AGENTS.md`:

  ```text
  Before starting any task, read docs/agent-context.md for project context.
  After completing a task, update the relevant section if anything changed.
  ```

---

## Reasoning Agent System

### Reasoning agent purpose

Reasoning agents apply structured mental models to improve decision quality across all workflows. They can be invoked:

- As **Codex skills** in the repo (via `$skill-name` in the Codex app/CLI)
- As **portable prompt templates** from Perplexity or ChatGPT (iOS, Android, Mac, web) for general thinking outside the repo
- **Automatically by the orchestrator** when the task context warrants specific reasoning patterns

### Mental Model Skills

| Skill Name              | Mental Model                   | When to Use                                                      | One Piece Name           |
| ----------------------- | ------------------------------ | ---------------------------------------------------------------- | ------------------------ |
| `$first-principles`     | First Principles Thinking      | Decompose a problem to its fundamental truths before building up | Vegapunk the Scientist   |
| `$second-order`         | Second-Order Thinking          | Evaluate consequences of consequences before committing          | Shanks the Strategist    |
| `$socratic`             | Socratic Questioning           | Challenge assumptions through systematic questioning             | Rayleigh the Mentor      |
| `$red-team`             | Red Teaming / Devil's Advocate | Actively find flaws, attack the plan, stress-test assumptions    | Mihawk the Rival         |
| `$inversion`            | Inversion                      | Work backward from failure — what would make this fail?          | Crocodile the Schemer    |
| `$pareto`               | 80/20 (Pareto Principle)       | Identify the 20% of effort that delivers 80% of value            | Doflamingo the Puppeteer |
| `$opportunity-cost`     | Opportunity Cost               | What are we giving up by choosing this path?                     | Garp the Veteran         |
| `$circle-of-competence` | Circle of Competence           | Stay within what we know; identify when we're outside it         | Whitebeard the Elder     |
| `$margin-of-safety`     | Margin of Safety               | Build buffers against what can go wrong                          | Kuma the Protector       |
| `$feedback-loop`        | Feedback Loops                 | Identify reinforcing and balancing loops in the system           | Katakuri the Predictor   |
| `$bayesian`             | Bayesian Updating              | Update beliefs based on new evidence; avoid anchoring            | Dragon the Revolutionary |

### Invocation modes

1. **Explicit by operator:** `$red-team` in Codex thread composer, or paste the portable prompt template into Perplexity/ChatGPT
2. **Explicit by operator — combo:** "Run $first-principles then $red-team on this architecture decision"
3. **Automatic by orchestrator:** The orchestrator skill can invoke reasoning skills based on task context:
   - Architecture decisions → `$first-principles` + `$second-order` + `$red-team`
   - Editorial content → `$socratic` + `$red-team` + `$circle-of-competence`
   - Priority/backlog grooming → `$pareto` + `$opportunity-cost`
   - Risk assessment → `$inversion` + `$margin-of-safety`
   - Post-incident / retrospective → `$feedback-loop` + `$bayesian`

### Skill file structure

Each reasoning skill lives at `.agents/skills/<skill-name>/SKILL.md` with:

- Clear trigger description (when Codex should auto-select)
- The mental model definition
- Step-by-step reasoning protocol
- Output format (structured findings)
- Integration point (how findings feed back into the calling workflow)

### Portable prompt templates

Each mental model also has a companion prompt template at `.codex/docs/reasoning-prompts/<model-name>.md` that can be copy-pasted into Perplexity or ChatGPT for use outside the repo.

### Files to create

Under `.agents/skills/`:

- `first-principles/SKILL.md`
- `second-order/SKILL.md`
- `socratic/SKILL.md`
- `red-team/SKILL.md`
- `inversion/SKILL.md`
- `pareto/SKILL.md`
- `opportunity-cost/SKILL.md`
- `circle-of-competence/SKILL.md`
- `margin-of-safety/SKILL.md`
- `feedback-loop/SKILL.md`
- `bayesian/SKILL.md`

Under `.codex/docs/reasoning-prompts/`:

- `first-principles.md`
- `second-order.md`
- `socratic.md`
- `red-team.md`
- `inversion.md`
- `pareto.md`
- `opportunity-cost.md`
- `circle-of-competence.md`
- `margin-of-safety.md`
- `feedback-loop.md`
- `bayesian.md`

---

## Dispatch Workflow Design

### Why dispatch exists

The dispatch workflow is a cheap prep step, not an execution engine. It automates everything between "Linear issue exists" and "Codex is ready to pick up the task."

### codex-dispatch.yml responsibilities

1. Accept `issue_id` (Linear issue identifier, e.g., `CWS-42`) and `workflow_type` (`dev`, `editorial-new`, `editorial-update`) as `workflow_dispatch` inputs.
2. Call `scripts/fetch-linear-issue.sh` to fetch issue content from Linear API.
3. Write `docs/tasks/CWS-NNN.md` with the structured task file template.
4. Create and push a prepared branch following the naming convention (`feature/CWS-NNN-slug`, `editorial/CWS-NNN-slug`, etc.).
5. Post a Slack notification to the appropriate channel (`#codex-runs`) that a task is ready.
6. Post a Linear comment on the issue with a link to the branch and instructions for Codex pickup.

### Triggering the dispatch

| Surface                          | Method                                                                                                                                        |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Perplexity (iOS/Android/Mac/web) | GitHub connector → trigger workflow_dispatch                                                                                                  |
| ChatGPT (iOS/Android/Mac/web)    | Not directly supported for workflow_dispatch; use Codex Cloud to create a task that calls `gh workflow run`, or ask Shabib to trigger via CLI |
| CLI (terminal)                   | `gh workflow run codex-dispatch.yml -f issue_id=CWS-42 -f workflow_type=dev`                                                                  |
| GitHub UI                        | Actions tab → codex-dispatch → Run workflow                                                                                                   |
| GitHub REST API                  | `POST /repos/{owner}/{repo}/actions/workflows/codex-dispatch.yml/dispatches`                                                                  |

> **March 2026 update:** The GitHub workflow_dispatch API now returns `run_id` in the response when `return_run_details=true` is passed, making it possible to track the dispatch run programmatically.

### scripts/fetch-linear-issue.sh responsibilities

- Read `LINEAR_API_KEY` from environment
- Query Linear GraphQL API at `https://api.linear.app/graphql`
- Fetch title, description, labels, assignee, state, sub-issues
- Write structured markdown to `docs/tasks/CWS-NNN.md`
- Fail cleanly on missing issue or missing secret

### Secret policy

Document required secrets in:

- `.codex/docs/secrets.md`

Required secrets:

- `LINEAR_API_KEY` — for fetching issue content in dispatch workflow
- `SLACK_WEBHOOK_URL` — for CI and dispatch Slack notifications
- `OPENAI_API_KEY` — only if using `openai/codex-action@v1` for PR review; scoped to that workflow

No OpenAI secrets are used for task execution in CI.

> **Why `LINEAR_API_KEY` is needed despite native integrations:** Linear's GitHub integration only syncs issues ↔ PRs via branch naming and magic words — it does NOT provide an API to fetch issue content from within a GitHub Actions workflow. Linear's Perplexity/ChatGPT connectors work in conversation context only and cannot be called from CI. The dispatch workflow (`codex-dispatch.yml`) runs in GitHub Actions and needs to fetch the Linear issue body to write `docs/tasks/CWS-NNN.md`. The only way to do this from CI is Linear's GraphQL API, which requires a `LINEAR_API_KEY`. The key is a **personal API key** (free, generated from Linear Settings → API → Personal API Keys). No paid plan required. The native integrations (GitHub ↔ Linear, Perplexity ↔ Linear, ChatGPT ↔ Linear) handle everything else.

---

## Developer Experience (DX) Setup

Three setup targets, all driven through the Makefile:

### `make setup` — New Mac bootstrap

Must handle:

- Verify Homebrew, Ruby, Bundler, Node (for markdownlint)
- `bundle install` for Jekyll + gems
- `gh` CLI auth check
- `gt` (Graphite CLI) auth check
- Codex CLI install/verify
- Git hooks installation (`make hooks-install`)
- `.env` scaffold with placeholder secrets (LINEAR_API_KEY, SLACK_WEBHOOK_URL)
- Verify directory structure (.codex/, .agents/, scripts/, docs/tasks/)
- Print status summary of what's ready and what needs manual steps (Codex login, Linear API key generation, Slack webhook creation)

### `make ci-setup` — GitHub Actions runner bootstrap

Runs in CI workflows as a first step. Must handle:

- Ruby + Bundler install (via setup-ruby action)
- Node install if needed (via setup-node action)
- `bundle install --jobs 4 --retry 3`
- Semgrep install (via Docker image or pip)
- No interactive prompts, no auth — secrets come from GitHub Secrets

### `make codex-setup` — Codex environment verification

Run at the start of a Codex session to verify the agent has what it needs:

- Verify `AGENTS.md` exists and is under 32 KiB
- Verify required skills are present
- Verify Makefile targets are accessible
- Verify branch is clean or correctly prepared
- Verify `docs/tasks/CWS-NNN.md` exists for the current branch (if on a task branch)
- Print a one-line status: "Ready for task CWS-42: [title]" or list what's missing

### `make claude-setup` — Claude Code environment verification

Run at the start of a Claude Code session to verify the agent has what it needs:

- Verify `CLAUDE.md` exists at repo root
- Verify `AGENTS.md` exists and is under 32 KiB
- Verify required skills are present in `.agents/skills/`
- Verify Makefile targets are accessible
- Verify branch is clean or correctly prepared
- Verify `docs/tasks/CWS-NNN.md` exists for the current branch (if on a task branch)
- Print a one-line status: "Ready for task CWS-42: [title]" or list what's missing

---

## Slack Strategy

### Free plan constraints (March 2026)

- **90-day message history** (older messages hidden, not deleted until 1 year)
- **Max 10 app integrations** (must budget carefully)
- **No custom retention policies**
- **No Slack Connect channels**
- **No group calls** (1:1 only)
- **5 GB total file storage**
- **Messages >1 year old are permanently deleted**

### Integration budget (10 slots)

| #    | Integration             | Purpose                                                                  |
| ---- | ----------------------- | ------------------------------------------------------------------------ |
| 1    | **Linear**              | Issue creation from Slack, status updates, bidirectional comment sync    |
| 2    | **GitHub**              | PR notifications, merge alerts, CI status                                |
| 3    | **Incoming Webhooks**   | Custom notifications from CI workflows (dispatch ready, merge, failures) |
| 4    | **Perplexity Computer** | AI agent tasks from Slack (already connected)                            |
| 5-10 | Reserved                | Future integrations as needed                                            |

> **Important:** Graphite → Slack integration requires the Starter tier ($20/user/month) and is **not available on the free plan**. All PR/stack notifications should go through GitHub Actions → Slack webhooks instead.

### Channel structure

- `#ci-dev` — dev pipeline success/failure, governance failures, security alerts
- `#ci-editorial` — editorial pipeline success/failure, content validation failures
- `#linear-updates` — issue created, status changed, issue linked to PR, project updates
- `#merges` — merge-to-main notifications
- `#codex-runs` — dispatch-ready notifications, manual log of Codex runs, start/stop/outcome notes

### Channel responsibilities

#### `#ci-dev`

- dev pipeline success/failure
- governance failures
- security alerts

#### `#ci-editorial`

- editorial pipeline success/failure
- content validation failures

#### `#linear-updates`

- issue created
- status changed
- issue linked to PR
- project updates

#### `#merges`

- merge-to-main notifications

#### `#codex-runs`

- dispatch workflow notifications ("Task CWS-42 is ready for Codex on branch `feature/CWS-42-slug`")
- manual log of Codex runs
- start / stop / outcome notes from Shabib

### Supporting docs

Add:

- `.codex/docs/tools.md`
- `.codex/docs/slack-setup.md`
- `.codex/docs/secrets.md`

---

## ADR Strategy

### Why ADRs matter here

This system is intentionally architectural: agent workflows, CI design, cost constraints, publishing process, branching model, and Linear conventions are all decisions that should be preserved.

### Directory

Create:

- `docs/adr/README.md`
- `docs/adr/template.md`
- `docs/adr/0001-use-jekyll-github-pages.md`

### Helper

Create:

- `scripts/new-adr.sh`

Expose via:

- `make new-adr TITLE="..."`

### ADR-triggering changes

If a PR touches:

- `.codex/**`
- `.agents/**`
- `.github/workflows/**`
- `_config.yml`
- major repo structure

then it should create or reference an ADR.

---

## Project Portfolio in Linear

Create these projects:

### 1. `[INFRA] Repo Process & Tooling`

Purpose:

- hooks
- CI split
- TDD system
- linting / vale / SEO tooling
- PR template
- ADR system
- Slack wiring
- branching conventions
- `_drafts/` git tracking fix

### 2. `[ORCHESTRATION] Agentic Workflow Design`

Purpose:

- Linear intake templates
- workflow dispatch
- per-task file system (`docs/tasks/CWS-NNN.md`)
- prompt rewrites
- decomposition rules
- issue-to-branch preparation
- agent contracts
- trigger surface documentation

### 3. `[EDITORIAL] Content Quality System`

Purpose:

- automated content checks
- judgment prompts
- voice profile
- authority rubric
- editorial gating system
- `_drafts/` → `_posts/` workflow

---

## Linear Task Breakdown Strategy

How to break the Master Plan into Linear work:

Epic structure (3 projects, each with epics):

Project: [INFRA] Repo Process & Tooling

- Epic: DX Setup & Bootstrap
- Epic: CI Pipeline Architecture
- Epic: Security Guardrails
- Epic: Git Hooks & Local Validation
- Epic: Slack Integration
- Epic: ADR System

Project: [ORCHESTRATION] Agentic Workflow Design

- Epic: AGENTS.md & Agent Platform Config
- Epic: Skill Authoring (agentskills.io compliant)
- Epic: Reasoning Agent Skills (mental models)
- Epic: Dispatch Workflow
- Epic: Multi-Surface Trigger Guide
- Epic: Definition of Ready & Done

Project: [EDITORIAL] Content Quality System

- Epic: Editorial QA Pipeline
- Epic: Publish-Draft Workflow
- Epic: Historical Post Updates
- Epic: Site Audit Automation

Breakdown rules:

1. Each epic maps to a section of this Master Plan.
2. Each task under an epic maps to ONE bounded deliverable (a script, a workflow file, a skill, a doc, a Makefile target).
3. Tasks are labeled `agent-task` or `human-task`.
4. Tasks have explicit acceptance criteria that reference `make` targets or test commands.
5. Dependencies between tasks are expressed via Linear's "blocked by" relation.
6. Execution order: INFRA → ORCHESTRATION → EDITORIAL (but some tasks can parallel).

**I (Computer/Perplexity) can create these Linear issues for you** once you approve the final scope. Each issue will have a high-quality description with the structured execution brief format.

---

## Backlog Summary

This section summarizes the implementation backlog at epic level.

### INFRA epics

1. Remove `_drafts/` from `.gitignore` and track in git
2. Create label taxonomy for the CWS team
3. Migrate branch naming to Linear-first convention
4. Implement local pre-commit and pre-push quality gates
5. Establish TDD as first-class across the repo
6. Configure markdownlint, vale, and cspell for Jekyll/editorial quality
7. Split CI into dev and editorial pipelines
8. Upgrade the PR template
9. Establish ADR infrastructure
10. Wire Slack notifications and workspace/channel setup (budget 10 integrations)
11. Create supporting docs for tools and secrets

- Epic: Agent Context System
  - Create docs/agent-context.md with initial structure
  - Add AGENTS.md rules for reading/updating context
  - Add context file to PR review checklist

### ORCHESTRATION epics

1. Design structured Linear intake templates for dev, editorial-new, editorial-update
2. Write the multi-surface trigger guide (Perplexity iOS/Android/Mac/web, ChatGPT iOS/Android/Mac/web, CLI, GitHub UI)
3. Rewrite all orchestrator prompts to reference per-task files
4. Build the `workflow_dispatch` branch-prep flow with per-task `docs/tasks/CWS-NNN.md`
5. Implement `fetch-linear-issue.sh`
6. Document Codex usage across all surfaces (CLI, Mac app, IDE extension, Cloud)
7. Define decomposition rules for single PR vs stacked PR
8. Update team-lead instructions with decomposition logic
9. Design and implement One Piece agent identity system in `config.toml` and prompts

- Epic: Agent Safety & Guardrails
  - Loop prevention rules in AGENTS.md
  - soul.md for each of the 9 agents
  - instructions.md with MUST NOT boundaries for each agent
  - Agent boundary matrix validation script
  - Concurrency limits in config.toml
  - Self-audit checklist in orchestrator skill
  - Two-phase orchestrator design (plan → approve → execute)
  - Clarification protocol in orchestrator skill
  - Plan review gate (Option C: Linear comment + Slack notification)

1. Build 11 mental model reasoning skills (`.agents/skills/`)
2. Write 11 portable reasoning prompt templates (`.codex/docs/reasoning-prompts/`)
3. Create reasoning agent orchestration rules (when to auto-invoke which models)

### EDITORIAL epics

1. Build automated editorial validation suite
2. Implement front matter validator (covering both `_posts/` and `_drafts/`)
3. Implement SEO audit
4. Implement custom Vale storytelling rule
5. Implement tone/style Vale rules
6. Wire all automated checks into editorial CI (trigger on `_posts/**` and `_drafts/**`)
7. Build manual judgment prompts
8. Create audience-check prompt
9. Create fact-check prompt
10. Create authority-check prompt
11. Create final-sign-off prompt
12. Write editorial voice profile
13. Write editorial evaluation rubric

---

## Files to Create or Update

### Modified files

- **`.gitignore`** — remove `_drafts/` entry so the folder is tracked by git

### New docs

- `.codex/docs/templates/dev-prd-template.md`
- `.codex/docs/templates/editorial-new-template.md`
- `.codex/docs/templates/editorial-update-template.md`
- `.codex/docs/trigger-surface-guide.md` (replaces `ios-intake-guide.md` — covers all surfaces)
- `.codex/docs/codex-usage.md` (covers CLI, Mac app, IDE extension, Cloud)
- `.codex/docs/decomposition-rules.md`
- `.codex/docs/editorial-voice-profile.md`
- `.codex/docs/editorial-voice-eval-rubric.md`
- `.codex/docs/tools.md`
- `.codex/docs/slack-setup.md`
- `.codex/docs/secrets.md`
- `docs/adr/README.md`
- `docs/adr/template.md`
- `docs/adr/0001-use-jekyll-github-pages.md`
- `docs/tasks/.gitkeep` (ensures the directory exists in git)
- `docs/agent-context.md` (persistent agent memory / project context)

### New agent config files

For each agent (zoro, sanji, chopper, robin, nami, franky, brook, jinbe, luffy):

- `.codex/agents/<agent-name>/config.toml`
- `.codex/agents/<agent-name>/soul.md`
- `.codex/agents/<agent-name>/instructions.md`

### New reasoning prompt templates

- `.codex/docs/reasoning-prompts/first-principles.md`
- `.codex/docs/reasoning-prompts/second-order.md`
- `.codex/docs/reasoning-prompts/socratic.md`
- `.codex/docs/reasoning-prompts/red-team.md`
- `.codex/docs/reasoning-prompts/inversion.md`
- `.codex/docs/reasoning-prompts/pareto.md`
- `.codex/docs/reasoning-prompts/opportunity-cost.md`
- `.codex/docs/reasoning-prompts/circle-of-competence.md`
- `.codex/docs/reasoning-prompts/margin-of-safety.md`
- `.codex/docs/reasoning-prompts/feedback-loop.md`
- `.codex/docs/reasoning-prompts/bayesian.md`

### New prompts

- `.codex/prompts/dev-workflow.md`
- `.codex/prompts/editorial-new.md`
- `.codex/prompts/editorial-update.md`
- `.codex/prompts/editorial-checks/audience-check.md`
- `.codex/prompts/editorial-checks/fact-check.md`
- `.codex/prompts/editorial-checks/authority-check.md`
- `.codex/prompts/editorial-checks/final-sign-off.md`

### New reasoning skills

- `.agents/skills/first-principles/SKILL.md`
- `.agents/skills/second-order/SKILL.md`
- `.agents/skills/socratic/SKILL.md`
- `.agents/skills/red-team/SKILL.md`
- `.agents/skills/inversion/SKILL.md`
- `.agents/skills/pareto/SKILL.md`
- `.agents/skills/opportunity-cost/SKILL.md`
- `.agents/skills/circle-of-competence/SKILL.md`
- `.agents/skills/margin-of-safety/SKILL.md`
- `.agents/skills/feedback-loop/SKILL.md`
- `.agents/skills/bayesian/SKILL.md`

### New scripts

- `scripts/hooks/pre-commit`
- `scripts/hooks/pre-push`
- `scripts/fetch-linear-issue.sh`
- `scripts/new-adr.sh`
- `scripts/validate-front-matter.rb`
- `scripts/audit-seo.rb` (new or refactored)

### New tests

- `tests/unit/test_pre_commit_hook.rb`
- `tests/unit/test_pre_push_hook.rb`
- `tests/unit/test_validate_front_matter.rb`
- `tests/unit/test_audit_seo.rb`
- `tests/unit/test_new_adr.rb`
- `tests/integration/test_fetch_linear_issue.rb`
- additional unit stubs for every uncovered script in `scripts/`

### New CI workflows

- `.github/workflows/dev-pipeline.yml`
- `.github/workflows/editorial-pipeline.yml`
- `.github/workflows/codex-dispatch.yml`
- `.github/workflows/notify-merge.yml`
- `.github/workflows/codex-pr-review.yml` (optional, uses `openai/codex-action@v1`)

### New config files

- `.markdownlint.yml`
- `.vale.ini`
- `cspell.json`
- `styles/Codewithshabib/*.yml`

---

## Human vs Agent Responsibility Matrix

| Area                              | Human  | Agent       | Notes                                     |
| --------------------------------- | ------ | ----------- | ----------------------------------------- |
| Linear project setup              | Yes    | No          | Workspace/admin task                      |
| Label taxonomy                    | Yes    | No          | Best created deliberately                 |
| Slack workspace creation          | Yes    | No          | Human account creation required           |
| Slack integration wiring docs     | Yes    | Yes         | Human does setup, agent can document      |
| `.gitignore` fix for `_drafts/`   | Review | Yes         | Agent-friendly, human verifies            |
| Prompt writing                    | Hybrid | Yes         | Human sets policy, agent drafts structure |
| Hook implementation               | Review | Yes         | Agent-friendly                            |
| Test writing                      | Review | Yes         | Must be test-first                        |
| Editorial voice policy            | Yes    | Assist only | Human source of truth                     |
| Authority rubric                  | Yes    | Assist only | Human judgment framework                  |
| ADR policy                        | Yes    | Assist only | Human-owned architecture decisions        |
| CI YAML implementation            | Review | Yes         | Agent-friendly                            |
| Dispatch workflow                 | Review | Yes         | Agent implements, human reviews           |
| Per-task file template            | Hybrid | Yes         | Human defines structure, agent implements |
| Trigger surface guide             | Yes    | Assist only | Human documents actual usage patterns     |
| Final editorial merge decision    | Yes    | No          | Human-only                                |
| Final architecture merge decision | Yes    | No          | Human-only                                |

---

## Immediate Execution Order

1. Remove `_drafts/` from `.gitignore` and commit.
2. Create `docs/tasks/.gitkeep` and commit.
3. Archive default onboarding issues in Linear.
4. Create label taxonomy in Linear.
5. Create the three projects in Linear.
6. Create the implementation backlog under those projects.
7. Implement branch naming and PR template updates.
8. Implement local hooks (pre-commit covers `_posts/**` and `_drafts/**`).
9. Implement TDD restructuring.
10. Implement markdownlint / vale / cspell.
11. Split CI (editorial pipeline triggers on `_posts/**` and `_drafts/**`).
12. Add ADR system.
13. Create Slack workspace and free integrations (budget 10 slots).
14. Create intake templates.
15. Write trigger surface guide (all Perplexity/ChatGPT/CLI/GitHub UI surfaces).
16. Rewrite orchestrator prompts (reference per-task `docs/tasks/CWS-NNN.md` files).
17. Implement dispatch workflow and `fetch-linear-issue.sh` (writes to `docs/tasks/`).
18. Implement editorial validators and manual judgment prompts.

---

## Definition of Done

This plan is complete when all of the following are true:

- `_drafts/` is tracked by git and agents can create/edit drafts in branches.
- Every meaningful change starts as a Linear issue.
- Every issue clearly indicates executor and bottleneck state.
- Every issue declares exactly one completion gate type: `PR_REQUIRED` or `EVIDENCE_REQUIRED`.
- `PR_REQUIRED` issues cannot move to `Done` until the linked PR is merged to `main`.
- `EVIDENCE_REQUIRED` issues cannot move to `Done` without explicit evidence artifacts and human sign-off.
- Branches use `CWS-*` identifiers.
- Per-task files exist at `docs/tasks/CWS-NNN.md` and persist after merge.
- Hooks catch most failures before push.
- CI is split and path-filtered (including `_drafts/**`).
- No CI workflow deploys the site.
- Secrets policy is documented and followed.
- Every automation script has tests.
- Editorial posts are validated by automated checks and manual judgment checks.
- Slack provides visibility without paid upgrades (within 10-integration limit).
- ADRs document architectural changes.
- Shabib can start from **any surface** (Perplexity iOS/Android/Mac/web, ChatGPT iOS/Android/Mac/web, CLI) and reliably reach a prepared branch with `docs/tasks/CWS-NNN.md` ready for agent pickup.
- Shabib can use **any agent surface** (Codex CLI/App/IDE/Cloud, Claude Code CLI/IDE) to execute the task.
- Reasoning skills are implemented and invocable via `$skill-name`.
- Portable reasoning prompts exist for Perplexity/ChatGPT use.
- All agents have One Piece identities in `config.toml`.
- `make security` passes alongside `make check` — security scanning is a first-class guardrail.
- Agent safety rules (loop prevention, stuck escalation) are in AGENTS.md.
- Each agent has `soul.md` and `instructions.md` with MUST NOT boundaries.
- `docs/agent-context.md` exists and agents read/update it.
- Orchestrator uses two-phase execution (plan → approve → execute).
- Plan review gate uses Option C (Linear comment + Slack notification).
- Self-audit checklist runs before every PR creation.
- Concurrency limits are set in `config.toml` (max_threads=3, max_depth=1).

---

## Appendix A: Tool Capabilities Matrix (March 2026)

| Tool                    | Surfaces                                     | Key Capabilities                                                          | Free Tier Limits                                      |
| ----------------------- | -------------------------------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------- |
| **Perplexity**          | iOS, Android, Mac, Web                       | Research, Linear connector, GitHub connector, Slack connector             | Pro Search limits on free; connectors require Pro/Max |
| **ChatGPT**             | iOS, Android, Mac, Web                       | Conversation, Codex Cloud sidebar, GitHub read-only app                   | Codex included with Plus+                             |
| **Codex CLI**           | macOS (user), Linux (CI-only)                | Local agent, multi-agent (experimental), MCP server, open-source          | Included with ChatGPT subscription                    |
| **Codex App**           | macOS                                        | Multi-agent management, worktrees, automations, skills                    | Included with ChatGPT subscription                    |
| **Codex IDE Extension** | VS Code, Cursor, Windsurf, JetBrains         | In-IDE agent, Cloud delegation                                            | Included with ChatGPT subscription                    |
| **Codex Cloud**         | Web (chatgpt.com/codex), ChatGPT iOS/Android | Remote sandboxed execution, PR creation                                   | Included with ChatGPT subscription                    |
| **Codex GitHub Action** | CI                                           | `openai/codex-action@v1`, PR review, patch application                    | Requires API key                                      |
| **Claude Code CLI**     | macOS, Linux                                 | Local agent, dynamic subagent dispatch, persistent memory, MCP, hooks     | Included with Anthropic subscription                  |
| **Claude Code IDE**     | VS Code                                      | In-IDE agent, same capabilities as CLI                                    | Included with Anthropic subscription                  |
| **Linear**              | Web, iOS, Android, Mac                       | GraphQL API, GitHub integration (free), Slack integration (free)          | Free plan: unlimited issues                           |
| **Graphite**            | CLI, VS Code, Web                            | Stacked PRs, PR inbox, limited AI reviews                                 | Hobby: personal repos, CLI, no Slack, no merge queue  |
| **GitHub Actions**      | CI                                           | `workflow_dispatch` (API returns `run_id` since Feb 2026), path filtering | Free for public repos; 2000 min/month private         |
| **Slack**               | iOS, Android, Mac, Web                       | Channels, webhooks, app integrations                                      | Free: 90-day history, 10 integrations, 5 GB storage   |
| **Jekyll**              | Build tool                                   | `_drafts/` ignored in prod by default, `--drafts` flag for local preview  | N/A                                                   |

---

## Appendix B: Change Log

| #   | Change                                                                   | Reason                                                                     |
| --- | ------------------------------------------------------------------------ | -------------------------------------------------------------------------- |
| 1   | `_drafts/` must be tracked by git                                        | Agents need to create/edit drafts in branches; currently gitignored        |
| 2   | All trigger surfaces expanded to iOS + Android + Mac + Web               | Perplexity and ChatGPT available on all four surfaces                      |
| 3   | Codex surfaces documented (CLI, Mac App, IDE Extension, Cloud)           | All surfaces are available as of March 2026                                |
| 4   | `CODEX_TASK.md` replaced with per-task `docs/tasks/CWS-NNN.md`           | Per-task files avoid conflicts, provide history, map to Linear issues      |
| 5   | Human-in-the-loop reduced to two touchpoints                             | Idea creation and final review; everything else automated                  |
| 6   | Codex start remains manual (no API)                                      | No programmatic trigger API exists as of March 2026                        |
| 7   | Slack 10-integration budget documented                                   | Free plan hard limit; integration slots must be planned                    |
| 8   | Graphite free tier constraints documented                                | Slack integration, merge queue, and org repos require paid tiers           |
| 9   | ChatGPT GitHub integration clarified as read-only                        | Cannot trigger workflow_dispatch; Codex or CLI needed for writes           |
| 10  | GitHub workflow_dispatch API `return_run_details` noted                  | Feb 2026 change enables tracking dispatch runs                             |
| 11  | Codex GitHub Action (`openai/codex-action@v1`) added as optional CI tool | Available for PR review without running full agent tasks                   |
| 12  | Editorial pipeline triggers expanded to include `_drafts/**`             | Drafts need the same validation as published posts                         |
| 13  | iOS-intake-guide replaced with multi-surface trigger guide               | Covers all surfaces, not just iOS                                          |
| 14  | Codex usage doc scoped to macOS surfaces (Linux = CI-only)               | CLI, Mac app, IDE extension, Cloud                                         |
| 15  | Tool capabilities matrix added as Appendix A                             | Quick reference for all tool constraints validated against March 2026 docs |
| 16  | Windows references removed                                               | User does not use Windows; reduces noise                                   |
| 17  | One Piece agent naming system added                                      | Agents get memorable identities matching their roles                       |
| 18  | Mental model reasoning agents added                                      | 11 structured thinking skills as Codex skills + portable prompts           |
| 19  | Master Plan storage location defined                                     | `docs/master-plan.md` in repo (authoritative) + Linear reference copy      |
| 20  | Reasoning agent auto-invocation rules added                              | Orchestrator can intelligently apply mental models based on task context   |
| 21  | Explicit device profile added (v3.1)                                     | Mac + iPhone + Android phone + Linux (CI-only). No Windows.                |
| 22  | Android added to all mobile surface references                           | Perplexity, ChatGPT, Linear, Slack, Codex Cloud sidebar                    |
| 23  | Codex CLI/IDE Linux clarified as CI-only                                 | User runs Codex CLI on macOS; Linux only appears in GitHub-hosted runners  |
| 24  | Trigger surfaces expanded to iOS + Android + Mac + Web                   | Both mobile OSes Shabib uses are now represented                           |
| 25  | Scripting language policy documented                                     | Bash default, Ruby for Jekyll/YAML; Makefile is single entry point         |
| 26  | One-shot DX setup targets defined                                        | `make setup`, `make ci-setup`, `make codex-setup`                          |
| 27  | Definition of Ready added                                                | 8-point checklist gating agent task pickup                                 |
| 28  | Linear API key necessity clarified                                       | Needed only for dispatch workflow CI; free personal API key                |
| 29  | Semgrep CE + CodeQL added as first-class security guardrails             | Free SAST tools, blocking on PRs                                           |
| 30  | Linear task breakdown strategy added                                     | Epic structure, breakdown rules, execution order                           |
| 31  | Known gaps and risks section added                                       | 9 blind spots documented with mitigations                                  |
| 32  | Definition of Done updated                                               | `make security` added alongside `make check`                               |
| 33  | DeerFlow-inspired agent safety rules added                               | Loop prevention, stuck-agent escalation, retry limits in scripts           |
| 34  | soul.md + instructions.md per agent                                      | Separates identity/personality from operational boundaries                 |
| 35  | MUST NOT language adopted for agent boundaries                           | Stronger than MAY NOT — unambiguous prohibition                            |
| 36  | Agent boundary matrix added                                              | Explicit per-role file and command restrictions                            |
| 37  | Persistent agent context file (docs/agent-context.md)                    | Markdown-based cross-session memory for agents                             |
| 38  | Two-phase orchestrator design                                            | Plan phase (post to Linear, notify Slack) → approval → execute phase       |
| 39  | Option C plan review gate                                                | Linear comment = permanent record, Slack notification = doorbell           |
| 40  | Structured clarification protocol                                        | SCOPE/APPROACH/RISK/MISSING taxonomy for agent questions                   |
| 41  | Self-audit checklist before PR creation                                  | 10-point verification before any PR is opened                              |
| 42  | Concurrency limits set (max_threads=3, max_depth=1)                      | Prevents coordination chaos in multi-agent execution                       |
| 43  | Agent context system added to backlog                                    | New epic under INFRA and ORCHESTRATION                                     |
| 44  | Dual-platform pivot (Codex + Claude Code)                                | Claude Code added as peer platform; shared roles, CLAUDE.md                |

---

## Known Gaps and Risks

Blind spots identified:

1. **No rollback strategy.** If a Codex agent produces a bad PR that gets merged, there's no documented rollback procedure. GitHub Pages auto-deploys on merge — a bad merge means a bad deploy. Add: "Revert PR template" and "rollback Makefile target" to backlog.

2. **No agent output size budget.** Codex agents could produce enormous PRs that are hard to review. Add: max diff size guideline per task (e.g., ≤ 500 lines changed). If larger, decompose.

3. **No monitoring for the live site.** After deploy, there's no health check. A bad Jekyll build could produce a broken site. Add: post-deploy smoke test (curl the homepage, check for 200 + expected content).

4. **Secrets rotation.** LINEAR_API_KEY and SLACK_WEBHOOK_URL have no rotation schedule documented.

5. **No cost monitoring for GitHub Actions.** Starting March 2026, self-hosted runners have a $0.002/min charge. Your public repo uses GitHub-hosted runners (free for public repos), but if the repo ever goes private, costs would start. Document this constraint.

6. **Skill versioning.** Skills are in the repo and versioned by git, but there's no semantic versioning or changelog per skill. When a skill changes behavior, agents using it won't know. Add: `metadata.version` in SKILL.md frontmatter + CHANGELOG.md per skill.

7. **No branch cleanup automation.** After merging, stale branches from completed tasks may accumulate. Add: branch auto-delete on merge (GitHub repo setting) + periodic cleanup of orphaned `docs/tasks/` files.

8. **Draft post collision.** If two agents work on drafts simultaneously (unlikely with current manual trigger, but possible with future automation), `_drafts/` could have conflicts. The multi-agent "one writer per file" rule covers this but isn't enforced by CI.

9. **No emergency bypass.** If CI or hooks break, there's no documented way to force-push an urgent fix. Add: emergency bypass procedure (admin merge with `[EMERGENCY]` label, post-incident ADR required).

10. **Dual-platform drift.** With both Codex and Claude Code as execution platforms, instructions and capabilities could diverge. Mitigation: single `AGENTS.md` as the authoritative contract, shared role location (`.agents/roles/`), platform-specific config clearly separated (`CLAUDE.md` vs `.codex/`), and periodic audit that both platforms produce equivalent results for the same task.

11. **Agent boundary enforcement is instruction-based only.** Codex has no programmatic way to restrict file access or command execution per agent. The MUST NOT rules in `instructions.md` rely on the LLM following instructions. A misbehaving agent could still modify restricted files. Mitigation: the self-audit checklist catches scope violations before PR creation, and PR review is mandatory. Consider adding a CI check that validates diff scope against the agent role specified in the task file.

---

## Final Notes

This system is intentionally designed as a solo-human / multi-agent operating model.

Shabib is not trying to automate away judgment. He is trying to automate away repetitive coordination, setup, validation, and mechanical execution so that his time is spent on:

- architectural judgment
- technical direction
- editorial standards
- approval and prioritization

That is the correct role split.

The two human touchpoints — idea creation and final review — are non-negotiable. Everything between them should require zero manual intervention except the current limitation of manually starting the agent platform (Codex or Claude Code). Either platform can handle any task — the choice is operational preference.
