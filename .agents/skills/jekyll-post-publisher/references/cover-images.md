# Cover Images

## Default Policy

- Expect the user to provide an Unsplash cover image URL in the prompt.
- Use remote Unsplash images by default.
- Do not download or commit the asset locally unless the user explicitly asks for a local fallback.
- Treat Unsplash media as third-party remote assets the repo does not own.

## Required Metadata

- `image`
- `image_alt`
- `image_source`

## Accepted Defaults

- `image_source: unsplash` for remote cover URLs
- local image paths are allowed only when the prompt explicitly requires a local asset

## Quality

- Alt text should describe the visible scene or graphic, not just repeat the post title.
- The chosen image should reinforce the tone of the piece without overwhelming it.
