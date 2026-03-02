# Medium Migration

When migrating a Medium post:

- default to preserving the original publish date, title, description, prose body, and media order
- improve markup, metadata, and rendering without changing historically protected text
- exact source images are preferred, but relevant fallback images are allowed when the original is
  blocked or unavailable
- use inline `figure.post-figure` and `figcaption` as the default rendering fix for imported media
- do not use hero or header image treatments unless explicitly requested
- re-check technical claims that may have drifted, but treat the findings as advisory unless the
  user explicitly asks for body edits
