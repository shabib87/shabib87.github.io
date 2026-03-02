# Site Quality Workflow

Use this prompt for focused site QA or a narrow site change, not for the full request-to-PR flow.

- Start with `$site-quality-auditor`.
- Audit for one of: SEO, performance, quality, or maintenance.
- Ground the review in `_config.yml`, shared head includes, JSON-LD, and the affected pages.
- Use `make site-audit AUDIT=<mode> TARGET=<target>` when deterministic repo-local checks help.
- If the workflow or version-sensitive behavior is unclear, use `$official-doc-verifier`.
- If the user wants the full site workflow through grouped commits and PR creation, use
  `.codex/prompts/site-workflow.md` in IDE contexts or the equivalent multi-skill prompt in the
  Codex app.
- If repo files are changed, require `make qa-local` before commit.
