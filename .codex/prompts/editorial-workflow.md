# Editorial Workflow

Use this repository's full net-new post workflow from topic or outline to published post and PR.

- Use `$content-brainstormer` when the angle, hook, or outline is still fuzzy.
- Use `$technical-post-drafter` to turn notes or outlines into a strong draft body.
- Use `$fact-checker` for technical or time-sensitive claims before calling the post publish-ready.
- Use `$jekyll-post-publisher` for draft creation, front matter, validation, publish QA, and
  promotion into `_posts/`.
- Use `$repo-flow` once tracked files exist and the work needs branch, commit, and PR packaging.
- Start repo-changing work from `main` with `make start-work TOPIC="..." TYPE=feat`.
- Create or refine the private draft under `_drafts/`.
- Ensure the draft has publish-ready metadata before publication.
- Run:
  `make validate-draft PATH=_drafts/<draft>.md`
  `make qa-publish PATH=_drafts/<draft>.md`
  `make publish-draft PATH=_drafts/<draft>.md DATE=YYYY-MM-DD`
- After `_posts/` is updated, run `make qa-local`.
- Group clean Conventional Commits only after QA passes.
- Re-run `make qa-local` on the committed tree.
- Run `make create-pr TYPE=feat`.
- If the work is actually a Medium migration, use `.codex/prompts/medium-to-blog.md` instead.
- Finish only when the tracked post exists in `_posts/` and the PR is open.
