# Site Workflow

Use this repository's full site-change workflow from request to PR.

- Use `$site-quality-auditor` for repo-specific site review and fixes.
- Use `$official-doc-verifier` when Jekyll, Minimal Mistakes, Codex, or another tool has
  version-sensitive behavior.
- Use `$repo-flow` for branch creation, QA, commit grouping, and PR packaging.
- Start repo-changing work from `main` with `make start-work TOPIC="..." TYPE=...`.
- Inspect the affected files before editing.
- Choose the relevant audit modes and run the matching commands:
  `make site-audit AUDIT=seo TARGET=...`
  `make site-audit AUDIT=quality TARGET=...`
  `make site-audit AUDIT=maintenance TARGET=...`
  `make site-audit AUDIT=performance TARGET=...` when performance review is relevant.
- Make the required repo changes.
- If site-facing files changed, require a local preview with `bundle exec jekyll serve` before
  commit.
- Run `make qa-local`.
- Group clean Conventional Commits only after QA passes.
- Re-run `make qa-local` on the committed tree.
- Run `make create-pr TYPE=...`.
- Finish only when the PR is open and ready for self-review.
