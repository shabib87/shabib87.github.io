# Repository Guidelines

## Project Structure & Module Organization
- `_config.yml` holds the global site configuration, theme setup, and plugin toggles. Update this before changing layouts or metadata.
- `_pages/` contains standalone pages. Use front matter consistent with Minimal Mistakes defaults and keep permalinks aligned with existing slugs.
- `_posts/` stores dated blog content in Markdown. Follow the `YYYY-MM-DD-title.md` naming pattern; assets referenced in posts live under `assets/images/`.
- `_includes/` and `_layouts/` (theme overrides) support shared partials. Favor `_includes` for reusable snippets and keep Liquid logic minimal.
- `_sass/` contains custom SCSS partials layered atop the Minimal Mistakes theme. Import new partials via `assets/css/main.scss`.

## Build, Test, and Development Commands
- `bundle install` ensures all Ruby gems match the versions pinned in `Gemfile.lock`.
- `bundle exec jekyll serve --livereload` builds the site locally, watches for changes, and serves on `http://localhost:4000`.
- `bundle exec jekyll build` produces the static site in `_site/`. Run this before deploying to verify there are no Liquid or Markdown build errors.
- `bundle exec htmlproofer ./_site` (optional) checks generated HTML for broken links and accessibility warnings.

## Coding Style & Naming Conventions
- Author Markdown with fenced code blocks and title-case headings (`#`, `##`). Keep line width under ~100 characters to ease diffs.
- Liquid templates should prefer `{%- %}` trimmed tags to avoid stray whitespace. Keep logic declarative; move complex helpers into `_includes`.
- SCSS uses two-space indentation and the Minimal Mistakes variable palette. Name custom partials `_<feature>.scss` and import once.
- JavaScript snippets (rare) belong under `assets/js/` and should pass ESLint defaults (`eslint:recommended`) if expanded.

## Testing Guidelines
- Rely on Jekyll’s build step as the primary regression check. Treat a clean `bundle exec jekyll build` as the baseline gate.
- When modifying navigation, front matter, or permalinks, spot-check rendered pages at `http://localhost:4000` in multiple viewports.
- For posts with code samples, validate syntax highlighting by confirming the correct Rouge lexer class in generated HTML.

## Commit & Pull Request Guidelines
- Follow Conventional Commits (`feat:`, `fix:`, `style:`) as seen in recent history (`git log --oneline`). Keep messages in imperative mood.
- Group related changes per commit; avoid mixing content updates with theme tweaks.
- Pull requests should include: summary of changes, before/after screenshots for visual tweaks, affected URLs, and links to any tracking issue.
- Ensure CI (or local build) passes before requesting review. Note any non-default build steps or known limitations in the PR description.
