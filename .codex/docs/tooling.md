# Tooling

## Philosophy

Local checks are the primary quality gate. CI is intentionally light and acts as a backup signal.
Do not commit until the full local QA gate passes.

## One-Shot Setup

Run:

```bash
make setup
```

This prepares gems, installs hooks, and verifies the local toolchain.
`make setup` assumes only Ruby `3.4.4`, Git, and Homebrew are present on the machine.
It then:

- enforces the repo Ruby version from `.ruby-version`
- bootstraps a repo-managed `pre-commit` in `.venv-tools/`
- installs pinned hook environments from `.pre-commit-config.yaml`
- installs gems into `vendor/bundle`
- treats `Gemfile.lock` as authoritative via frozen Bundler installs

## Hooks

Install or refresh hooks with:

```bash
make hooks-install
```

Hook stages:

- `pre-commit`: fast checks only
- `pre-push`: the full release-grade local QA gate

`make setup` installs both hook stages automatically.

## Linting

Run:

```bash
make lint
```

This covers changed markdown, YAML, shell scripts, and workflow files.
Shell static analysis is handled by the pinned `shellcheck` hook.

## Security

Run:

```bash
make security
```

This runs targeted Semgrep checks against shell scripts and workflow YAML.
Targets are discovered dynamically from `scripts/`, `.codex/`, and `.github/workflows/`,
plus the repo's `.semgrep.yml`.

## Codex Workflow Checks

Run:

```bash
make codex-check
```

This validates repo-local skills, repo workflow prompt files under `.codex/prompts/`, and
required Codex workflow docs.

## Site Audit

Run:

```bash
make site-audit AUDIT=seo TARGET=site
```

Use this for source-level SEO, quality, performance, and maintenance audits.

## Full Local QA

Run:

```bash
make qa-local
```

This is the required local release gate before commit, push, PR creation, or rebase integration.

## Tracked Repo QA

Run:

```bash
make check
```

This validates changed tracked posts and runs the Jekyll build.
Because the repo uses `remote_theme`, a clean environment may still need network access or a
cached theme for `make check` to succeed.
