# Editorial Workflow

Use this repository's full net-new post workflow from topic or outline to published post and PR.

- Use `$content-brainstormer` when the angle, hook, or outline is still fuzzy.
- Use `$technical-post-drafter` to turn notes or outlines into a strong draft body.
- Use `$fact-checker` for technical or time-sensitive claims before calling the post publish-ready.
- Use `$jekyll-post-publisher` for draft creation, front matter, validation, publish QA, and
  promotion into `_posts/`.
- Use `$repo-flow` once tracked files exist and the work needs branch, commit, and PR packaging.
- If the work is a Medium migration, use `.codex/prompts/medium-to-blog.md` instead.
- If the work is an edit to an existing tracked post where the title, description, publish date,
  and prose must stay intact, use `.codex/prompts/preserve-existing-post.md` instead.
- Start repo-changing work from `main` with `make start-work TOPIC="..." TYPE=feat`.
- Create or refine the private draft under `_drafts/`.
- Ensure the draft has publish-ready metadata before publication.
- Use the repo's standard article-media pattern for any editorial image blocks:
  `figure.post-figure` with an attached `figcaption`.
- Editorial images should use the shared blog treatment: fixed responsive height, flexible width,
  and cropped `object-fit: cover` presentation without stretching.
- Run:
  `make validate-draft PATH=_drafts/<draft>.md`
  `make qa-publish PATH=_drafts/<draft>.md`
  `make publish-draft PATH=_drafts/<draft>.md DATE=YYYY-MM-DD`
- After `_posts/` is updated, run `make qa-local`.
- Group clean Conventional Commits only after QA passes.
- Re-run `make qa-local` on the committed tree.
- Run `make create-pr TYPE=feat`.
- Finish only when the tracked post exists in `_posts/` and the PR is open.
