# Site Quality Workflow

Use this repository's site QA workflow.

- Start with `$site-quality-auditor`.
- Audit for one of: SEO, performance, quality, or maintenance.
- Ground the review in `_config.yml`, shared head includes, JSON-LD, and the affected pages.
- Use `make site-audit AUDIT=<mode> TARGET=<target>` when deterministic repo-local checks help.
- If the workflow or version-sensitive behavior is unclear, use `$official-doc-verifier`.
- If repo files are changed, require `make qa-local` before commit.
