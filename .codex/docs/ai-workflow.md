# AI Workflow

## Purpose

This repository stores its AI workflow in version control. `AGENTS.md`, repo-local skills,
workflow prompts, and helper scripts are the source of truth.

## Workflow Starters

- Prefer orchestrator prompts in `.codex/prompts/`.
- In Codex app usage, keep role ownership explicit.
- Use `make` commands for deterministic validation and release mechanics.

## Standard Flow

1. `make start-work TOPIC="..." TYPE=feat`
2. Run the relevant orchestrator workflow prompt.
3. Execute role handoffs by ownership (writer -> editor -> fact-checker -> publisher-release).
4. Run deterministic checks.
5. Package changes with repo-flow.

## Ownership Lock

- `writer` drafts body prose.
- `editor` performs editorial and voice polish.
- `team-lead` orchestrates and should not draft by default.
- `publisher-release` performs packaging and should not write body prose.

## Repo-Local Skills

- `jekyll-post-publisher`
- `content-brainstormer`
- `technical-post-drafter`
- `fact-checker`
- `historical-post-editor`
- `repo-flow`
- `official-doc-verifier`
- `site-quality-auditor`
