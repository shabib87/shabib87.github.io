# Tooling

## Philosophy

Local checks are the primary quality gate. CI is intentionally light and acts as a backup signal.

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
- `pre-push`: heavier tracked-content and security checks

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

## Tracked Repo QA

Run:

```bash
make check
```

This validates changed tracked posts and runs the Jekyll build.
