# Medium To Blog

Use this repository's preservation-first Medium migration workflow from source URL to published
post and PR.

- Use `$medium-porter` in `faithful-port` mode by default.
- Use `$fact-checker` for technical or time-sensitive claims, but treat the results as advisory
  unless the user explicitly asks to rewrite the post.
- Use `$jekyll-post-publisher` for front matter, validation, publish QA, and promotion into
  `_posts/`.
- Use `$repo-flow` for branch creation, grouped commits, QA, and PR packaging.
- Start repo-changing work from `main` with `make start-work TOPIC="..." TYPE=feat`.
- Capture and preserve the original:
  - publish date
  - title
  - description
  - prose body
  - media order
- Use a different but relevant image only when the exact original image cannot be recovered from
  Medium or its source.
- Render article media inline with the repo's standard `figure.post-figure` and `figcaption`
  pattern. Do not use hero overlays unless the user explicitly asks for that presentation.
- Do not rewrite body text, change publish dates, or change title/description unless the user
  explicitly asks for adaptation.
- Ingest the Medium URL and convert it into a private draft under `_drafts/`.
- Run:
  `make validate-draft PATH=_drafts/<draft>.md`
  `make qa-publish PATH=_drafts/<draft>.md`
  `make publish-draft PATH=_drafts/<draft>.md DATE=YYYY-MM-DD`
- After `_posts/` is updated, run `make qa-local`.
- Group the work into multiple relevant Conventional Commits only after QA passes.
- Re-run `make qa-local` on the committed tree.
- Run `make create-pr TYPE=feat`.
- Finish only when the tracked post exists in `_posts/`, the preserved fields still match the
  source, and the PR is open.
