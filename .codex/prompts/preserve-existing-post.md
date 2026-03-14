# Preserve Existing Post

Use this repository's preservation-first workflow for improving an existing tracked post without
changing its historical text or dates.

Preferred starter: `.codex/prompts/orchestrator-preserve-existing-post.md`

Compatibility note:
This prompt remains available for one cycle and routes to the orchestrator workflow.

- Use `$historical-post-editor` for safe media, styling, and SEO improvements.
- Use `$site-quality-auditor` when shared metadata behavior changes.
- Use `$repo-flow` for branch creation, grouped commits, QA, and PR packaging.
- Snapshot and validate protected fields before and after edits.
- Run `scripts/assert-protected-post-fields.sh` for preservation mode.
- Run `make qa-local` before commit and PR creation.
