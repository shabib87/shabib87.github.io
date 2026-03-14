---
name: historical-post-editor
description: "Use this skill when the user wants preservation-safe improvements to a tracked published post's styling, media, or SEO while keeping its historical text and dates intact by default. Apply it to existing repo posts that need maintenance or presentation fixes, not net-new drafting or broad rewrites."
---

# Historical Post Editor

Use this skill when editing an existing tracked post without changing its historical text or dates.

## Routing Boundaries

- Use it for tracked published posts that need safe presentation, metadata, or rendering fixes.
- Do not use it for writing new article bodies or broad rewrites. Route those to `technical-post-drafter`.
- Do not use it for general voice polish of existing prose. Route that to `sh-humanizer`.
- Do not use it for ordinary draft creation or publish packaging. Route that to `jekyll-post-publisher`.

## Workflow

1. Read `references/preservation-rules.md`.
2. Read `references/media-caption-style.md` when the post includes editorial images, credits, or
   subtitles.
3. Read `references/seo-safe-edits.md` when metadata, canonical tags, or social images are part of
   the task.
4. Snapshot the protected fields before editing.
5. Make only preservation-safe changes unless the user explicitly asks for text or date edits.
6. Use `scripts/assert-protected-post-fields.sh <before-path> <after-path>` before calling the
   work done.

## Available Scripts

- `scripts/assert-protected-post-fields.sh --help` shows supported flags and examples.
- `scripts/assert-protected-post-fields.sh <before-path> <after-path>` validates the protected
  title, description, publish date, filename date, and prose body text.
- `scripts/assert-protected-post-fields.sh --format jsonl <before-path> <after-path>` emits one
  structured result with the protected-field checks.

## Output Expectations

- protected fields preserved by default
- media blocks normalized to the repo's standard figure/caption pattern
- SEO and rendering fixes applied without historical drift

## Rules

- Protect the post title, description, publish date, filename date, and prose body by default.
- Use inline `figure.post-figure` and `figcaption` for editorial media.
- Keep editorial images aligned with the blog's shared fixed-height, flexible-width, cropped
  presentation without stretching.
- Keep captions smaller, italic, and visually subordinate to body text.
- Do not promote inline images into hero overlays unless the user explicitly asks for that change.
