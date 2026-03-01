# Editorial Policy

## Positioning

This site is an authority-building publication for:

- mobile architecture
- debugging and failure analysis
- systems thinking
- AI engineering
- principal mobile engineering leadership

The writing should strengthen that positioning rather than chase generic traffic.

## Drafting Model

- Net-new posts start in `_drafts/`.
- `_drafts/` is private and gitignored.
- Published posts live in `_posts/`.
- Drafts should be shaped far enough that metadata, structure, and sourcing can be reviewed
  before promotion to `_posts/`.

## Cover Images

- Default to a prompt-supplied Unsplash URL.
- Every publish-ready post must include:
  - `image`
  - `image_alt`
  - `image_source`
- `image_source` should default to `unsplash` for remote cover images.
- Local `assets/images/posts/*` files are fallback-only.

## Metadata Quality Bar

Every publish-ready post needs:

- a clear title
- a concise description
- a stable permalink
- normalized categories
- normalized tags
- `last_modified_at`
- `fact_check_status`
- a cover image and alt text

## Fact Checking

- Technical or time-sensitive claims should be checked against primary sources.
- Use official docs when possible.
- Use Context7 when the official docs are available there and the precise behavior matters.
- Rewrite or remove claims that cannot be supported cleanly.

## Authority-First Topic Selection

Prioritize ideas that:

- demonstrate original experience
- reveal systems thinking
- show principal judgment in architecture, platform strategy, or cross-team technical direction
- connect real engineering tradeoffs to practical lessons
- compound reputation in the site's core domains

## Publish QA

A post is not ready until it:

- reads like a native site article
- includes complete metadata
- uses a valid cover image
- fits the controlled taxonomy
- passes draft validation and publish QA
- passes the Jekyll build gate
