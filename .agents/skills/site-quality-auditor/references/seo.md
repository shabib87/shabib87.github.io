# SEO Audit Notes

- Check `_config.yml` for `jekyll-seo-tag`, `jekyll-sitemap`, `url`, and site metadata.
- Check `_includes/head/custom.html` for `{% seo %}`, canonical metadata surface, Open Graph tags, Twitter tags, and JSON-LD inclusion.
- Check `_includes/json-ld.html` for `schema.org` context and the current article schema shape.
- Check target pages for `title`, `description`, `permalink`, and any `robots` or `sitemap` overrides.
- Treat duplicate metadata in custom head overrides as a finding worth surfacing.
