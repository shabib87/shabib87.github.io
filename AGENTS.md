# Repository Guidelines

## Project Structure & Module Organization

- `_config.yml` holds the global site configuration, theme setup, and plugin toggles. Update this before changing layouts or metadata.
- `_pages/` contains standalone pages. Use front matter consistent with Minimal Mistakes defaults and keep permalinks aligned with existing slugs.
- `_posts/` stores published dated blog content in Markdown. Follow the `YYYY-MM-DD-title.md` naming pattern.
- `_drafts/` is a private local-only workspace for unpublished drafts. It is gitignored on purpose and should not be committed.
- `.agents/skills/` stores repo-local Codex skills in the official Codex location. Treat these as the source of truth for this repository's AI workflow.
- `.codex/prompts/` stores repo workflow prompt files for recurring Codex App and IDE starters.
- `.codex/docs/` stores repo-owned workflow, tooling, and editorial policy docs.
- `_includes/` and `_layouts/` (theme overrides) support shared partials. Favor `_includes` for reusable snippets and keep Liquid logic minimal.
- `_sass/` contains custom SCSS partials layered atop the Minimal Mistakes theme. Import new partials via `assets/css/main.scss`.

## Build, Test, and Development Commands

- `bundle install` ensures all Ruby gems match the versions pinned in `Gemfile.lock`.
- `bundle exec jekyll serve` builds the site locally, watches for changes, and serves on `http://localhost:4000`.
- `bundle exec jekyll build` produces the static site in `_site/`.
- `make setup` prepares the repo for day-to-day work and installs hooks.
- `make validate-draft PATH=_drafts/post.md` validates a private local draft.
- `make qa-publish PATH=_drafts/post.md` runs the full publish-readiness gate.
- `make publish-draft PATH=_drafts/post.md DATE=YYYY-MM-DD` promotes a private draft into `_posts/`.
- `make site-audit AUDIT=seo TARGET=site` runs repo-local site QA for SEO, quality, performance, or maintenance review.
- `make codex-check` validates repo-local skills, prompts, and Codex workflow docs.
- `make qa-local` runs the full release-grade local QA gate before commit, push, PR, or rebase integration.
- `make check` validates tracked post changes and runs the Jekyll build gate.
- `make create-pr TYPE=...` prepares a consistent PR title and description after local checks pass.
- `make finalize-merge PR=...` completes the solo self-review rebase-integration flow.

## Coding Style & Naming Conventions

- Author Markdown with fenced code blocks and title-case headings (`#`, `##`). Keep line width under ~100 characters to ease diffs.
- Liquid templates should prefer trimmed tag syntax (for example `{% raw %}{%- include nav -%}{% endraw %}`) to avoid stray whitespace.
- SCSS uses two-space indentation and the Minimal Mistakes variable palette. Name custom partials `_<feature>.scss` and import once.
- JavaScript snippets (rare) belong under `assets/js/` and should pass ESLint defaults (`eslint:recommended`) if expanded.
- Blog cover images should default to prompt-supplied Unsplash URLs. Use local `assets/images/posts/*` assets only when explicitly needed.

## Testing Guidelines

- Treat `make qa-local` as the full local release gate.
- Rely on Jekyll's build step as the baseline tracked-content regression check inside `make check`.
- Use `make validate-draft` for gitignored drafts and `make qa-publish` before any draft is promoted to `_posts/`.
- Run `make site-audit` when reviewing site metadata, archive pages, shared head includes, or website maintainability changes.
- If a change touches `_config.yml`, `_includes/`, `_layouts/`, `_pages/`, `_posts/`, `assets/`, or `_sass/`, preview locally with `bundle exec jekyll serve` before commit.

## Commit & Pull Request Guidelines

- Follow Conventional Commits (`feat:`, `fix:`, `style:`) as seen in recent history (`git log --oneline`). Keep messages in imperative mood.
- Group related changes per commit; avoid mixing content updates with workflow/tooling work.
- Do not commit until `make qa-local` passes.
- Re-run `make qa-local` on the committed tree before push and PR creation.
- Pull requests exist for packaging, review context, and clean history even though this is a solo-maintainer repo.
- Ensure local checks pass before opening a PR. CI is backup only, not the primary development loop.
- Branching model is trunk-based development: create short-lived branches off `main`, rebase if they drift, and integrate back with rebase only.

### Graphite And GitHub CLI Policy

- Use Graphite CLI (`gt`) for stack lifecycle operations: `gt create`, `gt modify`, `gt restack`, `gt sync`, and `gt submit --no-interactive`.
- Use GitHub CLI (`gh`) for GitHub object operations after submission: inspecting checks, viewing diffs, reading review state, commenting, and labeling.
- Keep branch/stack state authoritative in `gt`; use `gh` as the GitHub surface inspection and operations layer.
- If using `gt submit --no-interactive` for a stack, normalize each stack PR body with `gh pr edit --body-file <path>` before marking that PR ready.
- For stacked PR work, avoid mixing direct `git push`/`git commit` with Graphite stack steps unless explicitly required for recovery.
- Preflight branch naming before PR creation/submission. Accepted rollout patterns are `^codex/cws-\d+-[a-z0-9-]+$` and `^codex/phase-(\d+)-[a-z0-9-]+$`.
- For task branches (`codex/cws-<id>-...`), `docs/tasks/CWS-<id>.md` must exist before PR creation.
- Treat `docs/tasks/CWS-<id>.md` as a context snapshot. Any local `Status` field is informational only; Linear is the mutable execution-status source of truth.
- `docs/agent-context.md` must be fresh (not past `Stale After`) before PR creation.
- For task branches, PR titles must include the matching issue token for traceability (`CWS-<id>` or `cws-<id>`).
- For PR metadata updates, do not pass multiline markdown directly in shell flags. Use `gh pr create/edit --body-file <path>` to avoid shell substitution and corrupted PR bodies.
- If a PR head branch violates rollout naming policy, create a compliant replacement branch/PR and close the superseded PR with a replacement note.
- If `gh` is authenticated but SSH push fails (`Permission denied (publickey)`), recovery can use `gh api repos/<owner>/<repo>/git/refs` to create the remote branch ref to the intended commit.

### Execution Lifecycle Policy

- Start-of-work gate:
  - create or confirm the target Linear issue before implementation begins
  - for task branches (`codex/cws-<id>-...`), create `docs/tasks/CWS-<id>.md` before `make create-pr`
  - refresh `docs/agent-context.md` before PR submission when stale
- Review-closeout gate:
  - reply to every open PR review thread with explicit disposition and rationale (`accepted`, `partial`, or `declined`)
  - run `make qa-local` on the final reviewed branch tip before merge
  - ensure Linear issue and PR traceability/evidence links are current, and refresh `docs/agent-context.md` before final integration
  - for stacks, finalize in downstack order; stack membership may target `main` or another rollout branch

### Codex Instruction Hygiene

- `AGENTS.md` remains the execution policy for this repository. If any other document conflicts with `AGENTS.md`, follow `AGENTS.md` for execution and open a follow-up issue to reconcile docs.
- Keep `AGENTS.md` concise and stable. Put reusable task workflows in repo-local skills under `.agents/skills/` so guidance stays modular and loaded on demand.

## Review Guidelines

- For Codex GitHub reviews, prioritize high-impact findings first: regressions, correctness bugs, security risks, and workflow breakage.
- Review only the pull request diff and avoid unrelated repository commentary.
- Include concrete file references and the smallest actionable fix direction.
- Do not report style or preference nits unless they clearly reduce risk.
- Call out missing tests only when the change introduces meaningful behavioral risk.
- If no significant issues are found, explicitly state: `No high-impact findings.`

## Repo-Local Skills Policy

- Repo-local skills live in `.agents/skills/` and take precedence over user-global skills when both apply.
- Use repo-local skills first for private draft creation, technical draft development, post editing, brainstorming, fact checking, repo workflow automation, and official documentation verification.
- Prefer adapting external skills into repo-native workflows before vendoring them into `.agents/skills/`.
- Keep `SKILL.md` files concise. Put detailed policy in `references/` and deterministic logic in `scripts/`.

## Context7 And Official Docs Policy

- Use Context7 whenever official docs should be confirmed for Codex behavior, GitHub CLI usage, GitHub Actions syntax, Jekyll behavior, Minimal Mistakes behavior, `pre-commit`, Semgrep, or any version-sensitive tool/library behavior.
- Prefer primary documentation over memory for technical claims or workflow syntax.
- Summarize documentation-based conclusions when they materially affect implementation details, workflow policy, or published content.

## Editorial Workflow Policy

- This repo is the operating system for the site's editorial workflow, not just a static archive.
- Net-new posts start as private local drafts under `_drafts/`.
- Drafts are local-only and not backed up by git. Treat that as an intentional privacy tradeoff.
- A publish-ready post must include:
  - a strong title
  - a clear description
  - a cover image URL
  - `image_alt`
  - normalized categories and tags
  - `fact_check_status`
  - final publish QA
- Cover images are usually remote Unsplash URLs supplied in the prompt. Local image assets are the exception.
- Topic development should bias toward insight-led topics in mobile architecture, debugging,
  systems thinking, AI engineering, and mobile engineering leadership.

## Solo Integration Policy

- External reviewer approval is not required.
- Rebase-only integration requires local checks, a PR, and an explicit self-review confirmation step.
- If CI has reported failures, fix them before integration.

## Bash Security Policy

- Shell scripts must use `set -euo pipefail`.
- Do not use `eval`.
- Do not execute remote content with `curl | bash`-style patterns.
- Validate inputs early and fail closed on missing required state.
- Keep scripts compatible with `shellcheck` and targeted Semgrep checks.

## Repo-Local Skills

- `jekyll-post-publisher`: Create private drafts, validate them, run publish QA, and promote them into tracked posts.
- `content-brainstormer`: Generate experience-driven topic ideas, hooks, outlines, and backlog candidates.
- `technical-post-drafter`: Turn outlines, notes, and rough drafts into strong technical article bodies before fact checking and publish QA.
- `fact-checker`: Verify technical and time-sensitive claims with primary sources and official documentation.
- `repo-flow`: Standardize branch creation, local checks, PR authoring, and solo self-review rebase integration completion.
- `official-doc-verifier`: Decide when official docs are required and push the workflow toward Context7 or first-party sources.
- `site-quality-auditor`: Audit the site for source-level SEO, performance, quality, and maintainability issues.
