# Front Matter

## Required Fields For Publish-Ready Posts

- `title`
- `description`
- `date`
- `permalink`
- `categories`
- `tags`
- `last_modified_at`
- `image`
- `image_alt`
- `image_source`
- `fact_check_status`

## Defaults

- `image_source` should be `unsplash` for prompt-supplied remote cover images.
- `fact_check_status` should be `complete` or `not-needed` before publish.
- `permalink` should be stable, lowercase, slash-delimited, and end with a trailing slash.
- `categories` and `tags` should be arrays, not comma-delimited strings.

## Draft Guidance

- Net-new drafts live in private local `_drafts/`.
- Drafts should still carry the intended publish metadata early so QA can happen before promotion.
