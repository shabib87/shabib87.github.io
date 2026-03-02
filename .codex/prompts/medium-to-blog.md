# Medium To Blog

Use this repository's full Medium migration workflow from source URL to published post and PR.

- Use `$medium-porter` to convert the Medium article into a site-native draft while preserving
  voice and thesis.
- Use `$fact-checker` for technical or time-sensitive claims before publication.
- Use `$jekyll-post-publisher` for front matter, validation, publish QA, and promotion into
  `_posts/`.
- Use `$repo-flow` for branch creation, QA, commit grouping, and PR packaging.
- Start repo-changing work from `main` with `make start-work TOPIC="..." TYPE=feat`.
- Ingest the Medium URL and convert it into a private draft under `_drafts/`.
- Adapt metadata, taxonomy, structure, and formatting to this repo.
- Run:
  `make validate-draft PATH=_drafts/<draft>.md`
  `make qa-publish PATH=_drafts/<draft>.md`
  `make publish-draft PATH=_drafts/<draft>.md DATE=YYYY-MM-DD`
- After `_posts/` is updated, run `make qa-local`.
- Group clean Conventional Commits only after QA passes.
- Re-run `make qa-local` on the committed tree.
- Run `make create-pr TYPE=feat`.
- Finish only when the tracked post exists in `_posts/` and the PR is open.
