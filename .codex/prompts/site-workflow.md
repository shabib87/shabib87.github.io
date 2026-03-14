# Site Workflow

Use this repository's full site-change workflow from request to PR.

Preferred starter: `.codex/prompts/orchestrator-site-workflow.md`

Compatibility note:
This prompt remains available for one cycle and routes to the orchestrator workflow.

- Use `$site-quality-auditor` for repo-specific site review and fixes.
- Use `$official-doc-verifier` when behavior is version-sensitive.
- Use `$repo-flow` for branch creation, QA, commit grouping, and PR packaging.
- Start from `main` with `make start-work TOPIC="..." TYPE=...`.
- Run relevant `make site-audit` modes and then `make qa-local`.
- If site-facing files changed, preview with `bundle exec jekyll serve` before commit.
- Re-run `make qa-local` on the committed tree before PR creation.
