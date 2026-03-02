# Codex Usage

## Supported Workflow Starters

This repo uses three supported workflow entry points:

- repo-local skills under `.agents/skills/`
- repo-scoped slash commands under `.codex/prompts/`
- deterministic `make` targets and shell scripts

Use them together, not as competing systems.

## Skills

Use repo-local skills when you want Codex to enter a repo-specific workflow directly.

- `$content-brainstormer`
- `$technical-post-drafter`
- `$fact-checker`
- `$jekyll-post-publisher`
- `$medium-porter`
- `$repo-flow`
- `$official-doc-verifier`
- `$site-quality-auditor`

In the Codex app, enabled skills also appear in the slash-command picker through
`agents/openai.yaml`.

## Repo Slash Commands

Official Codex docs support custom slash commands. This repo keeps committed workflow starters
under `.codex/prompts/`.

- `/editorial-workflow`
- `/site-quality`
- `/repo-workflow`
- `/official-docs`

Use these when you want a short entry point that expands into the repo's preferred skill and QA
flow.

## Make Commands

Use `make` for deterministic repo actions and validation.

- `make start-work TOPIC="..." TYPE=feat`
- `make validate-draft PATH=_drafts/post.md`
- `make qa-publish PATH=_drafts/post.md`
- `make publish-draft PATH=_drafts/post.md DATE=YYYY-MM-DD`
- `make site-audit AUDIT=seo TARGET=site`
- `make codex-check`
- `make check`
- `make qa-local`
- `make create-pr TYPE=feat`
- `make finalize-merge PR=123`

## Release Gate

Follow this order for repo-changing work:

1. Start from `main` with `make start-work`.
2. Implement the change.
3. Run `make qa-local`.
4. Preview locally with `bundle exec jekyll serve` if site-facing files changed.
5. Group clean Conventional Commits only after the full QA gate passes.
6. Re-run `make qa-local` on the committed tree.
7. Create the PR with `make create-pr`.
8. Integrate with `make finalize-merge`.

## Scope Rules

- This repo follows trunk-based development with rebase-only integration.
- Do not rely on multi-agent features for this repo.
- Prefer repo-local truth first, then Context7, then first-party docs.
