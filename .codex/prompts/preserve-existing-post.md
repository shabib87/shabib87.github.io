# Preserve Existing Post

Use this repository's preservation-first workflow for improving an existing tracked post without
changing its historical text or dates.

- Use `$historical-post-editor` to make safe media, styling, and SEO improvements while freezing:
  - title
  - description
  - publish date
  - `_posts` filename date
  - prose body text
- Use `$site-quality-auditor` for SEO, quality, and maintenance checks when shared site files or
  metadata behavior changes.
- Use `$repo-flow` for branch creation, grouped commits, QA, and PR packaging.
- Start repo-changing work from `main` with `make start-work TOPIC="..." TYPE=fix`.
- Before editing, snapshot the protected post fields and verify they still match after the changes.
- Allowed changes by default:
  - add or replace a relevant inline image
  - add or replace a relevant header image when explicitly requested
  - convert image credit or subtitle text into `figure.post-figure` and `figcaption`
  - apply the standard smaller italic caption styling
  - fix OG, Twitter, JSON-LD, canonical, and related metadata behavior
  - normalize media rendering bugs
  - update categories, tags, and `last_modified_at` when appropriate
- Do not rewrite title, description, publish date, or prose body unless the user explicitly asks.
- Run `scripts/assert-protected-post-fields.sh` against the before and after versions when the
  task is in preservation mode.
- After the changes are complete, run `make qa-local`.
- Group the work into multiple relevant Conventional Commits only after QA passes.
- Re-run `make qa-local` on the committed tree.
- Run `make create-pr TYPE=fix`.
- Finish only when the protected fields are still intact and the PR is open.
