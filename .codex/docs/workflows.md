# Workflows

## Brainstorm A Post

Use `$content-brainstormer` to generate authority-first ideas, hooks, and outlines.

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

## Create And Merge A PR

Run:

```bash
make check
make create-pr TYPE=feat
make finalize-merge PR=<number>
```

The merge flow is solo self-review based. No external reviewer is required.
