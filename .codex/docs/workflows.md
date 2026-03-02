# Workflows

## Brainstorm A Post

Use `$content-brainstormer` to generate authority-first ideas, hooks, and outlines.

Slash command:

```text
/editorial-workflow
```

## Create A Private Draft

Create the draft locally under `_drafts/` and include:

- title
- description
- categories
- tags
- Unsplash image URL
- `image_alt`
- `fact_check_status`

## Validate A Draft

Run:

```bash
make validate-draft PATH=_drafts/your-post.md
```

This checks metadata, placeholders, image rules, and markdown lint for the private draft.

## Publish QA

Run:

```bash
make qa-publish PATH=_drafts/your-post.md
```

This is the final pre-publish gate.

## Publish A Draft

Run:

```bash
make publish-draft PATH=_drafts/your-post.md DATE=YYYY-MM-DD
```

This creates the tracked `_posts/YYYY-MM-DD-slug.md` file.

## Fact-Check A Draft

Use `$fact-checker` before publish when the draft contains technical or time-sensitive claims.

## Migrate A Medium Post

Use `$medium-porter`, then run the same local draft validation and publish flow.

## Audit Site Quality

Use `$site-quality-auditor` or run:

```bash
make site-audit AUDIT=seo TARGET=site
```

Use this workflow for source-level SEO, quality, performance, and maintenance review.

## Verify Official Docs

Use `$official-doc-verifier` when a workflow or implementation depends on current official docs.

## Create And Integrate A PR

Run:

```bash
make qa-local
make create-pr TYPE=feat
make finalize-merge PR=<number>
```

Do not commit until `make qa-local` passes. If site-facing files changed, preview with
`bundle exec jekyll serve` before commit.

The repo uses trunk-based development with rebase-only integration. No merge commits are part of
the workflow.
