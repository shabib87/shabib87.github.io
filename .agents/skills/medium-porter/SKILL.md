---
name: medium-porter
description: "Use this skill when the user is bringing Medium-origin content into this Jekyll site and needs migration, normalization, or a controlled site-native adaptation. Apply it to imported Medium drafts or posts, not tracked-post maintenance, net-new article drafting, or ordinary publish packaging."
---

# Medium Porter

Use this skill when importing or cleaning up Medium-origin content.

## Routing Boundaries

- Use it for Medium-source migration, cleanup, metadata normalization, and controlled adaptation into the site.
- Do not use it for editing an already tracked historical post. Route that to `historical-post-editor`.
- Do not use it for net-new article drafting from notes or outlines. Route that to `technical-post-drafter`.
- Do not use it for pure voice polish on prose that is already site-native. Route that to `sh-humanizer`.
- Do not use it for ordinary draft packaging or publication once the migration body is ready. Route that to `jekyll-post-publisher`.

## Workflow

1. Read `references/migration-checklist.md`.
2. Read `references/canonical-seo.md`.
3. Default to `faithful-port` mode unless the user explicitly asks for a rewrite or site-native
   adaptation.
4. Reuse the site's standard front matter and taxonomy conventions.
5. If the user explicitly wants a site-native rewrite, hand the draft to `technical-post-drafter`
   before final fact checking and publication.

## Output Expectations

- a site-native draft or post
- normalized metadata
- preserved historical text and dates by default
- any follow-up fact-check or SEO notes

## Done Criteria

- the migrated article preserves protected fields when in `faithful-port` mode
- metadata and media handling are consistent with the rest of the site

## Rules

- Preserve the original publish date, title, description, prose body, and media order by default.
- Exact source media is preferred, but a different relevant image is allowed when the original is
  blocked or unavailable.
- Render article media inline with the standard `figure.post-figure` and `figcaption` pattern.
- Keep editorial images aligned with the blog's shared fixed-height, flexible-width, cropped
  presentation without stretching.
- Re-check time-sensitive technical claims, but treat the results as advisory unless the user
  explicitly approves content edits.
- Avoid large rewrites unless the user explicitly asks for one.
