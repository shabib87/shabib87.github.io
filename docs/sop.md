# Agent Orchestration SOP

**Scope:** Personal operator playbook for using Codex and Claude Code to run reusable, bounded, multi-role workflows safely and consistently.

**Evidence standard:** This SOP is based on March 2026 official documentation for both Codex and Claude Code. Where a capability is documented only in the changelog or marked experimental, that status is called out explicitly.

---

## 1. What Codex officially supports today

### 1.1 Core customization layers

Codex documents a layered customization model built around:

- `AGENTS.md` for persistent project guidance
- Skills for reusable workflows, instructions, resources, and optional scripts
- MCP for external tools and systems
- Multi-agent for parallel delegation to specialized agents
- App commands and explicit skill invocation for interactive control
- Automations for scheduled recurring background tasks

This is the core architecture surface for orchestration as of March 2026.

### 1.2 Interactive invocation

The Codex app supports slash commands from the thread composer. It also supports explicit skill invocation by typing `$` in the composer. Enabled skills also appear in the slash command list.

**Available slash commands (March 2026):**

- `/feedback` — submit feedback and optionally include logs
- `/mcp` — view connected MCP servers
- `/plan-mode` — toggle multi-step planning mode
- `/review` — start code review mode for uncommitted changes or branch comparison
- `/status` — show thread ID, context usage, and rate limits

**Deeplinks:** The Codex app supports `codex://` URL scheme for direct navigation to settings, skills, automations, threads, and new thread creation with optional prompt parameters.

**Operational meaning:**

- Use slash commands for operator control and quick entry points.
- Use `$skill-name` when you want to invoke a specific skill intentionally.

### 1.3 Skills

Skills are Codex's reusable capability layer. Official docs describe them as bundles of instructions, references, and optional scripts, with progressive disclosure so Codex only loads the full skill content when needed.

**Skills follow the open Agent Skills standard** (agentskills.io). This is an open format originally developed by Anthropic and adopted across multiple platforms including Codex, Claude Code, Cursor, GitHub Copilot, Windsurf, Gemini CLI, and others. Authoring skills to the open standard ensures portability.

**Codex-specific extension:** Skills can optionally include `agents/openai.yaml` for Codex-specific UI metadata (`interface`), invocation policy (`policy.allow_implicit_invocation`), and tool dependencies (`dependencies.tools`). This file is ignored by non-Codex platforms.

**Operational meaning:**

- Put reusable workflow logic in skills.
- Do not rely on giant ad hoc prompts for repeatable work.
- Prefer multiple focused skills over one oversized skill.
- Author `SKILL.md` to the agentskills.io spec for portability.
- Add `agents/openai.yaml` only for Codex-specific enhancements (UI, policy, MCP dependencies).
- Keep `SKILL.md` body under 500 lines / ~5000 tokens. Move detail to `references/`.

### 1.4 AGENTS.md

`AGENTS.md` is the documented place for standing project instructions. Codex reads it before doing work.

**Discovery model:** Codex builds an instruction chain on startup by scanning from global (`~/.codex/`) through repo root to current directory. Later files override earlier ones. `AGENTS.override.md` takes precedence over `AGENTS.md` at the same level.

**Size limit:** `project_doc_max_bytes` defaults to 32 KiB. Beyond that, content is truncated.

**Operational meaning:**

- Put repo-wide policy, conventions, constraints, and definitions of done in `AGENTS.md`.
- Do not restate stable rules manually every time.
- Use `AGENTS.override.md` for temporary overrides without deleting base files.
- Keep within the 32 KiB default or raise the limit in `config.toml`.

### 1.5 Multi-agent and subagents

Subagents are officially documented and can run specialized agents in parallel, wait for results, and return a consolidated response.

Official docs recommend it for highly parallel work such as codebase exploration or multi-part review. They also warn about context pollution and coordination issues, especially for write-heavy tasks.

**Platform support (March 2026):**

- **CLI and Codex App:** Subagent activity is supported and visible
- **IDE Extension:** Visibility coming soon

**Configuration:** Custom agents are defined in TOML files under `.codex/agents/*.toml` (repo) or `~/.codex/agents/*.toml` (global), including `name`, `description`, and `developer_instructions`.

**Concurrency limits:** `agents.max_threads` defaults to 6; `agents.max_depth` defaults to 1 (prevents deep nesting). `agents.job_max_runtime_seconds` defaults to 1800s for CSV batch jobs.

**Operational meaning:**

- Use subagents for bounded parallel work.
- Prefer read-heavy or clearly separated lanes first.
- Keep write ownership explicit to avoid overlap.
- Spawn subagents only when explicitly requested by the operator.

### 1.6 Automations

Codex automations are officially documented as scheduled recurring background tasks in the Codex app. The app must be running and the selected project must be available on disk. In Git repos, automations can run either in the local project or in a dedicated worktree.

Automations can invoke skills by including `$skill-name` in the automation prompt.

**Sandbox modes:** Read-only, workspace-write, or full access. Admin-enforced requirements may restrict modes.

**Operational meaning:**

- Use automations for recurring checks, scans, or maintenance tasks.
- Prefer worktree mode when you want isolation from unfinished local work.
- Do not treat automations as a generic event-hook system.
- Test prompts manually first; review initial outputs in the Triage inbox.

### 1.7 Hooks status

Codex's official top-level docs for app orchestration center on scheduled automations, not general lifecycle hooks. The Codex changelog for CLI 0.114.0 mentions an experimental hooks engine with `SessionStart` and `Stop` events.

**Operational meaning:**

- Treat hooks as emerging and experimental in Codex as of March 2026.
- Do not build core production workflow assumptions on undocumented hook behavior.
- For deterministic downstream actions, prefer explicit outer orchestration such as repo scripts or CI.

### 1.8 Claude Code capabilities

Claude Code is an Anthropic CLI agent that runs locally (macOS, Linux) and in IDE extensions
(VS Code). It reads `CLAUDE.md` at session start for project-specific instructions and follows
`AGENTS.md` as the authoritative execution contract.

**Agent dispatch model:** Claude Code uses a dynamic, prompt-based `Agent` tool for subagent
dispatch — no persistent TOML config files. Role definitions are read from `.agents/roles/<name>/`
at dispatch time and incorporated into the agent prompt.

**Key capabilities (March 2026):**

- Subagent dispatch via `Agent` tool (dynamic prompt-based, not config-file-based)
- `CLAUDE.md` as session-start instruction surface (analogous to `AGENTS.md` for Codex)
- Persistent file-based memory system (`~/.claude/`) for cross-session continuity
- Hooks system (`SessionStart`, tool-use hooks) for automated behaviors
- Git worktree isolation for subagents (`isolation: "worktree"`)
- MCP support (same servers: Linear, Context7)
- Skills support (reads `.agents/skills/` SKILL.md files directly; agentskills.io compatible)

**What Claude Code does not have:**

- No persistent agent config files (roles are prompt-injected at dispatch)
- No built-in automation scheduler (use external orchestration or cron)
- No native concurrency limits config — manage via orchestrator discipline
- No app-level UI for multi-agent management (CLI and IDE only)

**Operational meaning:**

- Use Claude Code when the task benefits from dynamic subagent dispatch, persistent memory,
  or when Codex is unavailable.
- Follow the same `AGENTS.md` contract regardless of platform.
- Store Claude Code-specific instructions in `CLAUDE.md`, not in `AGENTS.md`.

### 1.9 Platform capability comparison

| Capability | Codex | Claude Code |
| --- | --- | --- |
| Instruction surface | `AGENTS.md` | `CLAUDE.md` + `AGENTS.md` |
| Agent config | `.codex/agents/*.toml` (static) | `Agent` tool (dynamic prompt) |
| Role definitions | `.codex/agents/<name>/` | `.agents/roles/<name>/` (shared) |
| Skills | `.agents/skills/` + `agents/openai.yaml` | `.agents/skills/` (ignores openai.yaml) |
| Subagent dispatch | Config-based, app-managed | Prompt-based, `Agent` tool |
| Concurrency limits | `config.toml` (`max_threads`, `max_depth`) | Orchestrator discipline |
| Cross-session memory | None (reads `docs/agent-context.md`) | File-based (`~/.claude/`) + `docs/agent-context.md` |
| Worktree isolation | App-native | `isolation: "worktree"` parameter |
| Automations | Built-in scheduler | External (cron, CI, scripts) |
| Hooks | Experimental (CLI 0.114.0) | Supported (`SessionStart`, tool-use) |
| MCP | Supported | Supported |
| Surfaces | CLI, Mac App, IDE, Cloud | CLI, IDE (VS Code) |

### 1.10 When to use which platform

Use **Codex** when:

- The task benefits from the app's multi-agent management UI
- You want scheduled automations with inbox triage
- You need Cloud execution from mobile (iOS/Android sidebar)
- The work is already configured with `.codex/agents/` TOML files

Use **Claude Code** when:

- The task benefits from dynamic subagent dispatch with custom prompts
- You want persistent cross-session memory for continuity
- You need worktree isolation for parallel subagent work
- You're working in VS Code and want integrated agent assistance

Either platform can handle any task. The choice is operational preference, not capability gating.

---

## 2. Skill authoring standard

### 2.1 Dual-compliance requirement

All skills in this repo must comply with both:

1. **The open Agent Skills standard** (agentskills.io/specification) — ensures portability to Claude Code, Cursor, Copilot, Windsurf, Gemini CLI, Perplexity Computer, and any future skills-compatible platform.
2. **Codex skill conventions** (developers.openai.com/codex/skills/) — ensures optimal behavior within the primary execution environment.

### 2.2 Portable skill structure (agentskills.io)

```text
skill-name/
├── SKILL.md              # Required: frontmatter + instructions
├── scripts/              # Optional: executable code
├── references/           # Optional: documentation
├── assets/               # Optional: templates, resources
└── agents/
    └── openai.yaml       # Optional: Codex-specific UI/policy/dependencies
```

### 2.3 SKILL.md frontmatter (agentskills.io spec)

| Field | Required | Constraints |
| --- | --- | --- |
| `name` | Yes | Max 64 chars. Lowercase letters, numbers, hyphens only. Must match parent directory name. No leading/trailing/consecutive hyphens. |
| `description` | Yes | Max 1024 chars. Describe what the skill does AND when to use it. Include keywords for auto-selection. |
| `license` | No | License name or reference to bundled file. |
| `compatibility` | No | Max 500 chars. Environment requirements if any. |
| `metadata` | No | Arbitrary key-value map (e.g., `author`, `version`). |
| `allowed-tools` | No | Space-delimited tool list. Experimental. |

**Example:**

```yaml
---
name: red-team
description: >
  Apply red teaming / devil's advocate reasoning to challenge assumptions,
  find flaws, and stress-test plans. Use when evaluating architecture decisions,
  editorial content, or any proposal that needs adversarial review.
license: MIT
metadata:
  author: codewithshabib
  version: "1.0"
  one-piece-name: "Mihawk the Rival"
---
```

### 2.4 Codex-specific extension (agents/openai.yaml)

Only add when needed. This file is ignored by non-Codex platforms.

```yaml
interface:
  display_name: "Red Team"
  short_description: "Devil's advocate reasoning"
  icon_small: "./assets/icon.svg"
  brand_color: "#DC2626"

policy:
  allow_implicit_invocation: true

dependencies:
  tools: []
```

### 2.5 Progressive disclosure budget

| Layer | Token budget | Loaded when |
| --- | --- | --- |
| Metadata (`name` + `description`) | ~100 tokens | Startup, all skills |
| Full `SKILL.md` body | < 5000 tokens (~500 lines) | Skill activated |
| `references/`, `scripts/`, `assets/` | As needed | Explicitly referenced |

### 2.6 Portability rules

- **Never** put platform-specific logic in `SKILL.md`. It must work on any skills-compatible agent.
- **Always** put Codex-specific enhancements in `agents/openai.yaml`.
- **Always** ensure the `name` field matches the parent directory name.
- **Always** use relative paths from skill root when referencing files.
- **Validate** skills with `skills-ref validate ./skill-name` before committing.
- **Test** on at least Codex CLI and one other platform (Claude Code or Cursor) before marking portable.

---

## 3. Architecture pattern to use

Use this layered model:

1. **`AGENTS.md`** holds standing project rules.
2. **Slash command or `$skill` invocation** starts the workflow.
3. **Top-level orchestration skill** defines the reusable workflow contract.
4. **Specialized skills** handle bounded expert work.
5. **Multi-agent** parallelizes only the lanes that truly benefit from parallelism.
6. **Deterministic validation gates** run before packaging or integration.
7. **Human review** remains the final judgment step.
8. **Automations** schedule recurring runs.
9. **External orchestration** handles downstream side effects when reliability matters.

**Key rule:**
Interactive invocation, reusable capability, parallel execution, validation, scheduling, and side effects should not all live in one prompt.

---

## 4. Decision framework

### Use `AGENTS.md` when

- the rule should always apply in the repo
- the workflow depends on stable conventions
- the instruction should not be retyped every session

Examples:

- branch conventions
- QA requirements
- allowed commands
- review expectations
- definition of done

### Use a skill when

- the work is repeatable
- the workflow needs structure
- the task benefits from instructions plus optional scripts or references
- you want consistent execution across sessions
- you want portability to other platforms

Examples:

- fact-check workflow
- release packaging workflow
- publish QA workflow
- developer audit workflow
- mental model reasoning (first principles, red team, etc.)

### Use slash commands or `$skill` when

- you need a fast human entry point
- the workflow starts interactively
- you want explicit operator control over what runs

Examples:

- start orchestration
- launch review mode
- invoke a specific workflow skill
- invoke a reasoning agent (`$red-team`, `$first-principles`)

### Use multi-agent when

- the work splits cleanly into bounded subproblems
- tasks are mostly read-heavy or separable
- a consolidated final answer is acceptable
- you explicitly want delegated/parallel agent execution

Examples:

- parallel review lanes
- fact-check plus technical audit plus packaging checks
- codebase exploration by concern

### Use automations when

- the task should run on a schedule
- the same skill or workflow needs recurring background execution
- findings can surface in the Codex inbox instead of requiring immediate hook chaining

Examples:

- weekly site audit
- recurring content validation
- scheduled maintenance checks

### Use external orchestration when

- the workflow must trigger deterministic downstream actions
- you need reliable PR creation, publish actions, notifications, or chained workflows
- the side effect must be independently observable and controllable

Examples:

- CI pipelines
- repo scripts
- GitHub Actions
- release automation

---

## 5. Personal operating procedure

### 5.1 Before starting

1. Start from a clean tree.
2. Rebase or update `main` first.
3. Confirm the task belongs to one bounded workflow.
4. Confirm `AGENTS.md` reflects current project rules.
5. Confirm the necessary skills exist and are still valid.
6. Decide whether the task is interactive, scheduled, or both.

### 5.2 Starting the workflow

Use one of these entry modes:

- **Interactive app/IDE path:** use slash commands or explicit `$skill` invocation.
- **Automation path:** create a scheduled automation and invoke the orchestration skill from the automation prompt.

**Rule:** the workflow should always have one clear entry point.

### 5.3 Orchestration

The top-level orchestration skill should do the following:

- define the goal
- define the lanes
- decide which lanes can run in parallel
- assign the right specialized skill to each lane
- define expected outputs from each lane
- define merge conditions
- define validation requirements
- define when to stop and hand back to the operator

**Rule:** the orchestration skill coordinates; it should not become a giant catch-all skill that owns everything.

### 5.4 Parallel work

Use multi-agent only when justified.

Preferred first use cases:

- read-heavy review lanes
- parallel fact-checking
- bounded exploration tasks
- non-overlapping audit tasks

Avoid or minimize parallelism when:

- many agents would write to the same files
- the work depends heavily on serial decisions
- the merge logic is unclear

### 5.5 Validation

Before packaging or integration, run deterministic checks.

Examples:

- local QA command
- build and validation scripts
- publish QA command
- link or metadata checks
- security and lint gates

**Rule:** "looks good" is not a gate.

### 5.6 Human review

Human review remains the final control point.

Check:

- boundaries were respected
- the right skill was used for each lane
- validation completed successfully
- changed files make sense
- final output matches the workflow goal

### 5.7 Recurring execution

When the workflow should run on a schedule:

1. Create a Codex automation.
2. Prefer worktree mode for Git repos when isolation matters.
3. Include the orchestration skill explicitly with `$skill-name`.
4. Review findings in the automation inbox.
5. Adjust model or reasoning settings only if needed.

### 5.8 Downstream actions

For publish, PR, notify, or chain-next-step behavior:

- prefer explicit external orchestration
- do not assume Codex automations are a general completion-hook engine
- keep side effects observable and independently debuggable

---

## 6. Recommended architecture for the blog workflow

### Workflow shape

- `AGENTS.md` stores standing repo rules.
- A top-level orchestration skill starts the workflow.
- Specialized skills handle:
  - writer/editor work
  - fact-checking
  - publisher/packaging
  - developer/site changes
  - historical post edits
  - reasoning/mental models (invoked by orchestrator or operator)
- Multi-agent is used only for bounded lanes.
- Deterministic repo checks run before final packaging.
- Human review stays mandatory.
- Scheduled maintenance or recurring audits run through automations.
- External tooling handles deterministic downstream side effects.

### Recommended trigger pattern

- Use slash commands or `$skill` to launch the orchestration interactively.
- Use automations only for recurring runs.
- Do not overload one giant prompt with rules, orchestration, execution, and side effects.

---

## 7. What not to do

- Do not treat one ad hoc thread as the whole system.
- Do not hide stable repo rules in temporary prompts.
- Do not create one giant skill that tries to do everything.
- Do not parallelize overlapping write-heavy work without clear ownership.
- Do not replace deterministic gates with subjective review.
- Do not assume scheduled automations are equivalent to general workflow hooks.
- Do not build production expectations around experimental hook support unless it is explicitly documented for your Codex surface.
- Do not put Codex-specific logic in `SKILL.md` — use `agents/openai.yaml` instead.
- Do not exceed 500 lines / 5000 tokens in `SKILL.md` body — move detail to `references/`.

---

## 8. Capability summary table

| Capability | Official status in March 2026 | Best use |
| --- | --- | --- |
| `AGENTS.md` | Documented, stable | Standing project rules |
| Skills (agentskills.io spec) | Documented, stable, open standard | Reusable portable workflows and capability bundles |
| `agents/openai.yaml` | Codex-specific extension | UI metadata, invocation policy, MCP dependencies |
| Slash commands | Documented in app | Interactive operator control |
| `$skill` invocation | Documented in app/CLI | Explicit skill launch |
| Subagents | Documented | Parallel bounded tasks |
| Automations | Documented in app | Scheduled recurring background runs |
| Worktree automations | Documented | Isolated recurring runs in Git repos |
| Hooks engine | Mentioned in CLI changelog, experimental | Emerging; do not rely on broadly |
| Deeplinks (`codex://`) | Documented in app | Direct navigation to app features |

---

## 9. Source list

- Agent Skills open standard: [https://agentskills.io/specification](https://agentskills.io/specification)
- Agent Skills GitHub: [https://github.com/agentskills/agentskills](https://github.com/agentskills/agentskills)
- Codex customization concepts: [https://developers.openai.com/codex/concepts/customization/](https://developers.openai.com/codex/concepts/customization/)
- Codex app commands: [https://developers.openai.com/codex/app/commands/](https://developers.openai.com/codex/app/commands/)
- Codex skills: [https://developers.openai.com/codex/skills/](https://developers.openai.com/codex/skills/)
- Codex AGENTS.md guide: [https://developers.openai.com/codex/guides/agents-md/](https://developers.openai.com/codex/guides/agents-md/)
- Codex subagents: [https://developers.openai.com/codex/subagents](https://developers.openai.com/codex/subagents)
- Codex automations: [https://developers.openai.com/codex/app/automations/](https://developers.openai.com/codex/app/automations/)
- Codex best practices: [https://developers.openai.com/codex/learn/best-practices/](https://developers.openai.com/codex/learn/best-practices/)
- Codex changelog: [https://developers.openai.com/codex/changelog/](https://developers.openai.com/codex/changelog/)

---

## Appendix: SOP change log

| Version | Date | Changes |
| --- | --- | --- |
| 1.0 | 2026-03-15 | Initial SOP |
| 2.0 | 2026-03-15 | Added Agent Skills open standard (agentskills.io) as dual-compliance requirement. Added Section 2 (Skill authoring standard) with portable structure, frontmatter spec, Codex extension, progressive disclosure budget, and portability rules. Added slash command reference list. Added deeplinks. Added AGENTS.md discovery model and size limit. Added multi-agent platform support status (CLI-only). Added concurrency limits. Added automation sandbox modes. Updated capability table with stable/experimental status clarification. Added portability anti-pattern to Section 7. |
| 2.1 | 2026-03-17 | Updated subagent/platform guidance: CLI and Codex App visibility, IDE extension visibility pending, custom-agent TOML location under `.codex/agents/*.toml`, explicit-operator delegation rule, and source link moved from multi-agent to subagents docs. |
| 3.0 | 2026-03-20 | Dual-platform pivot: renamed to Agent Orchestration SOP, added Claude Code capabilities (Section 1.8), platform capability comparison table (Section 1.9), platform selection guidance (Section 1.10). Scope broadened from Codex-only to Codex + Claude Code. |
