---
name: jekyll-post-publisher
description: Create, validate, refine, and publish posts for this Jekyll blog. Use when drafting new posts, editing existing posts, adding prompt-supplied Unsplash cover images, normalizing front matter, or preparing content to move from _drafts to _posts.
---

# Jekyll Post Publisher

Use this skill for repo-specific blog work.

## When To Use

- creating a private local draft
- validating a private draft
- running publish QA
- promoting a draft into `_posts/`
- updating front matter
- validating categories, tags, permalink, and cover image metadata
- preparing a Medium port for publication on this site

## Required Inputs

- topic or title
- summary, outline, or source notes
- Unsplash cover image URL unless explicitly using a local asset
- `image_alt`
- categories and tags
- `fact_check_status`

## Workflow

1. Read `references/frontmatter.md` for the required metadata.
2. Read `references/content-checklist.md` for the publish bar.
3. If the post includes an Unsplash image, read `references/cover-images.md`.
4. If the post is a Medium migration, read `references/medium-migration.md`.
5. Use `scripts/validate-post.sh <path>` before calling a post ready.
6. Use `make validate-draft`, `make qa-publish`, and `make publish-draft` as the repo-level workflow.

## Output Expectations

- a private draft or a tracked published post
- complete front matter
- explicit validation status
- clear next step

## Done Criteria

- draft passes validation
- publish-ready draft passes QA
- tracked post passes `make check`

## Rules

- Net-new posts start in private local `_drafts/`.
- Default cover images to a prompt-supplied Unsplash URL.
- Require `image_alt` for any cover image.
- Require `fact_check_status` before publish.
- Prefer the controlled taxonomy in `references/taxonomy.md`.
- Keep the author's voice intact; improve clarity and structure without flattening it.
