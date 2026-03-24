# Claude Code Project Instructions

This file is the Claude Code session-start instruction surface for this repository.

## Execution Contract

`AGENTS.md` is the authoritative execution contract. All rules in `AGENTS.md` apply equally to
Claude Code sessions. If anything in this file conflicts with `AGENTS.md`, follow `AGENTS.md`.

## Agent Role System

Nine execution agent roles are defined for this repository:

- `team-lead` (orchestrator) — plans, delegates, synthesizes
- `developer` — implements scoped changes
- `researcher` — read-only information gathering
- `writer` — content creation
- `editor` — content quality and fixes
- `fact-checker` — source verification
- `seo-expert` — discoverability and SEO
- `publisher-release` — packaging and release flow
- `historical-post-editor` — legacy content refresh

Role definitions live in `.agents/roles/<name>/soul.md` and `instructions.md` (shared across
platforms; created by CWS-23 — not yet present). Each role has a One Piece character identity
defined in `docs/master-plan.md`.

## Subagent Dispatch

When spawning a subagent via the `Agent` tool:

- Read the appropriate role's `soul.md` and `instructions.md` from `.agents/roles/<name>/` and
  incorporate into the agent prompt (once role files exist).
- Use `isolation: "worktree"` for read-heavy or risky work.
- Max depth: agents do not spawn sub-agents. Only the orchestrator delegates.
- For parallel work, batch multiple `Agent` tool calls in a single message.
- Concurrency guidance: prefer 3 or fewer parallel agents; batch if more lanes are needed.

## Context and Memory

- Read `docs/agent-context.md` at task start; update when meaningful context changes.
- Reference `docs/sop.md` for orchestration patterns and platform capabilities.
- Reference `docs/master-plan.md` for architecture and backlog context.
- Claude Code's file-based memory system (`~/.claude/`) is available for cross-session continuity.

## Skills

- Skills at `.agents/skills/` follow the agentskills.io open standard.
- Read `SKILL.md` files directly when a skill matches the task shape.
- Ignore `agents/openai.yaml` files within skills (Codex-specific extension).

## MCP

- Linear and Context7 MCP servers are available.
- Claude Code MCP configuration is managed in Claude Code's own settings.

## Task Pickup

- Same queue resolution as `AGENTS.md`: Linear first, local second.
- Same branch convention: `cws/<id>-<slug>`.
- Same task file requirement: `docs/tasks/CWS-<id>.md` before PR creation.

## Graphite

- Use `gt` CLI for stacked PR lifecycle (`create`, `modify`, `submit`, `stack`).
- Use `gh` CLI for GitHub object operations (checks, labels, comments, PR metadata).

## Bash Scripting

- Do not place heredocs inside `$()` command substitutions — bash 3.2 (macOS default) cannot
  reliably parse them and may lose quote state for the rest of the file. Instead, write the
  heredoc to a temp file and execute that:

  ```bash
  # WRONG — breaks bash 3.2:
  result="$(ruby - "$arg" <<'RUBY'
  ...
  RUBY
  )"

  # RIGHT — bash 3.2 safe:
  _tmp="$(mktemp)"
  cat > "$_tmp" <<'RUBY'
  ...
  RUBY
  result="$(ruby "$_tmp" "$arg")"
  rm -f "$_tmp"
  ```

## Validation

- `make qa-local` is the required local release gate.
- `make create-pr TYPE=...` standardizes PR metadata packaging.
- `make finalize-merge PR=...` standardizes rebase-only integration closeout.
