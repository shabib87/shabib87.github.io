# Orchestrator Editorial Workflow

Use this workflow for net-new post creation from topic or outline through publish QA and PR.

- Team lead orchestrates role handoffs and decision checkpoints.
- Route ideation to `$content-brainstormer` when needed.
- Route body drafting to writer behavior using `$technical-post-drafter`.
- Route editing and voice polish to editor behavior, including `sh-humanizer` style expectations.
- Route claims to `$fact-checker` before publish-ready status.
- Route metadata, validation, and publication packaging to `$jekyll-post-publisher`.
- Run:
  `make validate-draft PATH=_drafts/<draft>.md`
  `make qa-publish PATH=_drafts/<draft>.md`
  `make publish-draft PATH=_drafts/<draft>.md DATE=YYYY-MM-DD`
  `make qa-local`
- Legacy import workflow is retired for this repository.
