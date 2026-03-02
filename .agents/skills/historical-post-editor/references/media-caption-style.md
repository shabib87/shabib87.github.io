# Media Caption Style

Use this standard article-media pattern for preserved posts:

```html
<figure class="post-figure">
  <img src="..." alt="...">
  <figcaption>Caption or credit text.</figcaption>
</figure>
```

Rules:

- keep the image inline in article flow
- keep the caption attached directly below the image
- use `figcaption` for photo credit, image subtitle, or AI-generated-image note
- do not leave caption text as a standalone paragraph
- do not convert the image into a hero overlay unless explicitly requested

Design requirements:

- caption is smaller than body text
- caption is italic
- caption color is slightly muted
- caption links inherit the caption tone
