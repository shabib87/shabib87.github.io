---
name: jekyll-post-publisher
description: "Use this skill when the user needs repo-specific post packaging: front matter, draft creation, validation, publish QA, or promotion from _drafts to _posts. Apply it to metadata normalization and publication workflow after the body largely exists, not to ideation, full article drafting, source verification, or voice rewrites."
---

# Jekyll Post Publisher

Use this skill for repo-specific blog work.

## Routing Boundaries

- Use it for file creation, front matter normalization, validation, publish QA, and promotion into tracked posts.
- Do not use it for topic ideation or editorial backlog work. Route that to `content-brainstormer`.
- Do not use it for writing or restructuring the main article body. Route that to `technical-post-drafter`.
- Do not use it for claim verification or documentation lookup. Route that to `fact-checker`.
- Do not use it for voice rewrites of otherwise solid prose. Route that to `sh-humanizer`.

## When To Use

- opening a private local draft with site-ready front matter
- validating a private draft
- running publish QA
- promoting a draft into `_posts/`
- updating front matter
- validating categories, tags, permalink, and cover image metadata
- packaging a fact-checked draft into the repo's publish workflow

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
4. Determine the content mode:
   - `net-new`
   - `historical-preservation-edit`
5. If the content is still outline-only or the body needs major rewriting, hand it to
   `technical-post-drafter` before publish QA.
6. If technical claims still need verification, run `fact-checker` before calling a draft
   publish-ready.
7. Use `.agents/skills/jekyll-post-publisher/scripts/validate-post.sh <path>` before calling a post ready.
8. Use `make validate-draft`, `make qa-publish`, and `make publish-draft` as the repo-level
   workflow for drafts.

## Available Scripts

- `.agents/skills/jekyll-post-publisher/scripts/validate-post.sh --help` shows supported flags and examples.
- `.agents/skills/jekyll-post-publisher/scripts/validate-post.sh <path>` validates a draft or tracked post in text mode.
- `.agents/skills/jekyll-post-publisher/scripts/validate-post.sh --format jsonl <path>` emits one structured result per validated file.

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
- In `historical-preservation-edit` mode, do not rewrite title, description, publish date, or
  prose body without explicit approval.
- Visible media rendering and OG/Twitter/JSON-LD image behavior must both be checked when remote
  images are involved.
- Use inline `figure.post-figure` and `figcaption` for editorial media by default; hero overlays
  are opt-in only.
- Own file creation, metadata, validation, and publication; do not become the default body-drafting skill.
