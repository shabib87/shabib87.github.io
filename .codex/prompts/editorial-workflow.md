# Editorial Workflow

Use this repository's full net-new post workflow from topic or outline to published post and PR.

Preferred starter: `.codex/prompts/orchestrator-editorial-workflow.md`

Compatibility note:
This prompt remains available for one cycle and routes to the orchestrator workflow.

- `writer` owns drafting/restructuring using `$technical-post-drafter`.
- `editor` owns refinement and voice polish.
- `team-lead` orchestrates and does not draft by default.
- Use `$fact-checker` for technical or time-sensitive claims.
- Use `$jekyll-post-publisher` for metadata, validation, publish QA, and promotion into `_posts/`.
- Use `$repo-flow` once tracked files need branch, commit, and PR packaging.
- Legacy import workflow is retired for this repository.
- Run:
  `make validate-draft PATH=_drafts/<draft>.md`
  `make qa-publish PATH=_drafts/<draft>.md`
  `make publish-draft PATH=_drafts/<draft>.md DATE=YYYY-MM-DD`
  `make qa-local`
