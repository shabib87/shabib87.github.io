# AI Workflow Docs

## Quick Start

1. Run `make setup`
   This bootstraps the repo-managed tooling environment and installs git hooks.
2. Create or edit a private draft in `_drafts/`
3. Run `make validate-draft PATH=_drafts/your-post.md`
4. Run `make qa-publish PATH=_drafts/your-post.md`
5. Run `make publish-draft PATH=_drafts/your-post.md DATE=YYYY-MM-DD`
6. Run `make check`
7. Create the PR with `make create-pr TYPE=feat`
8. Self-review and merge with `make finalize-merge PR=...`

## Docs Index

- [AI Workflow](./ai-workflow.md)
- [Editorial Policy](./editorial-policy.md)
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
