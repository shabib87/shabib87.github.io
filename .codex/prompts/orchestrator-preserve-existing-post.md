# Orchestrator Preserve Existing Post Workflow

Use this workflow for preservation-safe updates to existing tracked posts.

- Team lead orchestrates scope and guardrails.
- Route edits to `$historical-post-editor` behavior.
- Route site-level metadata and quality checks to `$site-quality-auditor`.
- Preserve title, description, publish date, filename date, and prose body unless user explicitly requests changes.
- Validate protected fields with `scripts/assert-protected-post-fields.sh`.
- Run `make qa-local` before commit and PR packaging.
