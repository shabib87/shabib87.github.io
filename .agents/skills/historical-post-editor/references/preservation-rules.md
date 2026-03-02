# Preservation Rules

For existing tracked posts in preservation mode:

- freeze `title`
- freeze `description`
- freeze front matter `date`
- freeze the `_posts/YYYY-MM-DD-...` filename date
- freeze prose body text

Allowed changes:

- `last_modified_at`
- categories and tags
- image blocks and image sources
- figure and figcaption markup
- caption styling
- SEO, schema, canonical, and social metadata
- shared CSS or include fixes needed to support the post

Before finishing:

- compare the before and after versions with `scripts/assert-protected-post-fields.sh`
- preview the affected post if rendering changed
