# Codex Usage

## What Codex Officially Documents

For this repo, relevant Codex surfaces are:

- built-in slash commands for controls (`/local`, `/cloud`, `/review`, `/status`)
- explicit skill invocation with `$skill-name`
- repo prompt files referenced as `@file` in IDE contexts
- multi-agent role configuration through `.codex/config.toml`

## Repo Workflow Model

This repository uses orchestrated multi-agent execution with strict ownership boundaries.

- `team-lead`: orchestrates, delegates, and communicates decisions
- `writer`: drafts and restructures body prose
- `editor`: refines structure, clarity, and voice
- `publisher-release`: handles metadata, publish QA, and repo packaging

The main branch policy remains trunk-based with rebase-only integration.

## Preferred Starters (VS Code / Cursor)

- `@.codex/prompts/orchestrator-site-workflow.md`
- `@.codex/prompts/orchestrator-editorial-workflow.md`
- `@.codex/prompts/orchestrator-preserve-existing-post.md`

Legacy starters remain temporarily for compatibility:

- `@.codex/prompts/site-workflow.md`
- `@.codex/prompts/editorial-workflow.md`
- `@.codex/prompts/preserve-existing-post.md`

## Codex App Starter Pattern

Use role-oriented prompts and keep ownership explicit:

```text
$site-quality-auditor $official-doc-verifier $repo-flow
```

```text
$content-brainstormer $technical-post-drafter $fact-checker $jekyll-post-publisher $repo-flow
```

```text
$historical-post-editor $site-quality-auditor $repo-flow
```

## Scope Rules

- Multi-agent orchestration is first-class for this repo.
- Keep write ownership narrow and avoid parallel writes on overlapping files.
- Ask the user only on blocking or high-impact decisions.
- Prefer repo truth first, then Context7, then first-party docs.
- If delegation fails, continue in single-agent fallback mode and report degraded execution.
