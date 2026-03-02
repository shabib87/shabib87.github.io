---
name: historical-post-editor
description: Safely improve styling, media, and SEO for an existing published post while preserving its title, description, publish date, filename date, and prose body by default.
---

# Historical Post Editor

Use this skill when editing an existing tracked post without changing its historical text or dates.

## Workflow

1. Read `references/preservation-rules.md`.
2. Read `references/media-caption-style.md` when the post includes editorial images, credits, or
   subtitles.
3. Read `references/seo-safe-edits.md` when metadata, canonical tags, or social images are part of
   the task.
4. Snapshot the protected fields before editing.
5. Make only preservation-safe changes unless the user explicitly asks for text or date edits.
6. Run `scripts/assert-protected-post-fields.sh` before calling the work done.

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
