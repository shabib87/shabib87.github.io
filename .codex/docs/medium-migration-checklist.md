# Medium Migration Checklist

Use this checklist when porting a Medium post into this repository.

## Content Integrity

- Preserve the original thesis and voice.
- Improve structure and readability without turning the piece into a new article.
- Rewrite or trim filler that only made sense in Medium's formatting environment.

## Metadata

- Add a site-native title if needed.
- Write a fresh description.
- Add normalized categories and tags.
- Add `last_modified_at`.
- Add a cover image URL and `image_alt`.
- Add `fact_check_status`.
- Confirm permalink shape is consistent with the site.

## Formatting

- Clean up headings.
- Fix code fences and language tags.
- Replace Medium-specific embeds with site-compatible content.
- Review links and update broken or stale ones.

## SEO And Social

- Decide whether canonical handling is needed.
- Ensure the post's image and description work with existing Open Graph and Twitter metadata.
- Make sure the final result reads like a native article on `codewithshabib.com`.

## Fact Checking

- Re-check time-sensitive technical claims.
- Verify official-tool behavior against primary sources.
- Use Context7 when official documentation precision matters.
