# Migration Checklist

- confirm whether the task is `faithful-port` or explicit site-native adaptation
- capture the original publish date, title, description, prose body, and media order
- preserve publish date and filename date in `faithful-port` mode
- preserve title, description, and prose body in `faithful-port` mode
- normalize front matter
- normalize tags and categories
- review links, embeds, and media order
- add cover image metadata
- prefer the exact source image when recoverable
- when the source image is from Unsplash, keep it as a remote Unsplash URL instead of downloading
  it into the repo unless the user explicitly requests a local fallback
- use a different but relevant image only when the original is blocked or unavailable
- preserve caption intent and convert detached image notes into `figure.post-figure` and
  `figcaption` where needed
- ensure editorial images follow the shared blog treatment: fixed responsive height, flexible
  width, and cropped `object-fit: cover` presentation
- do not use hero overlays by default
- verify time-sensitive claims without silently rewriting preserved source text
- preview the final article-media UX before publication
