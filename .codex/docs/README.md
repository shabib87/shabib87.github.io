# AI Workflow Docs

## Quick Start

1. Run `make setup`
   This bootstraps the repo-managed tooling environment and installs git hooks.
2. Start repo-changing work from `main` with `make start-work TOPIC="..." TYPE=feat`
3. Use a repo-local skill or a repo-scoped slash command from `.codex/prompts/`
4. Run editorial validation or `make site-audit` for site maintenance work
5. Run `make qa-local`
6. Create the PR with `make create-pr TYPE=feat`
7. Self-review and integrate with `make finalize-merge PR=...`

## Docs Index

- [AI Workflow](./ai-workflow.md)
- [Codex Usage](./codex-usage.md)
- [Editorial Policy](./editorial-policy.md)
- [Site Quality](./site-quality.md)
- [Tooling](./tooling.md)
- [Workflows](./workflows.md)
- [Prompt Recipes](./prompt-recipes.md)
- [Medium Migration Checklist](./medium-migration-checklist.md)

## Skills Index

- `jekyll-post-publisher`
- `content-brainstormer`
- `fact-checker`
- `medium-porter`
- `repo-flow`
- `official-doc-verifier`
- `site-quality-auditor`
