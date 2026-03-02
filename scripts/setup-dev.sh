#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# shellcheck disable=SC1091
. "$repo_root/scripts/lib/tooling.sh"

missing=0

ensure_bundler() {
  if command -v bundle >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v gem >/dev/null 2>&1; then
    return 1
  fi

  echo "info: installing bundler via gem"
  gem install bundler
}

ensure_brew_package() {
  local cmd="$1"
  local formula="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v brew >/dev/null 2>&1; then
    return 1
  fi

  echo "info: installing $formula with Homebrew"
  brew install "$formula"
}

install_repo_pre_commit() {
  local pre_commit_bin
  pre_commit_bin="$(repo_pre_commit_bin)"
  if [[ -x "$pre_commit_bin" ]]; then
    return 0
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    return 1
  fi

  echo "info: creating repo-managed tooling environment"
  python3 -m venv "$repo_root/.venv-tools"
  "$repo_root/.venv-tools/bin/pip" install --requirement "$repo_root/requirements-dev.txt"
}

require_cmd() {
  local cmd="$1"
  local hint="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing: $cmd" >&2
    echo "hint: $hint" >&2
    missing=1
  fi
}

require_cmd ruby "Install Ruby via your preferred package manager."
require_cmd git "Install Git from https://git-scm.com/downloads"

if [[ "$missing" -eq 0 ]]; then
  require_repo_ruby || exit 1
fi

if ! ensure_bundler; then
  require_cmd bundle "Install Bundler with: gem install bundler"
fi

if command -v brew >/dev/null 2>&1; then
  if [[ -f "$repo_root/Brewfile" ]]; then
    echo "info: installing repo CLI dependencies from Brewfile"
    brew bundle --file "$repo_root/Brewfile"
  fi
fi

if ! ensure_brew_package python3 python; then
  require_cmd python3 "Install Python 3, e.g. brew install python"
fi

if ! install_repo_pre_commit; then
  echo "error: unable to provision repo-managed pre-commit" >&2
  echo "hint: ensure python3 is available, then rerun make setup" >&2
  exit 1
fi

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

export BUNDLE_PATH="$repo_root/vendor/bundle"
export BUNDLE_FROZEN="true"

if ! bundle check >/dev/null 2>&1; then
  bundle install
fi

"$repo_root/scripts/setup-hooks.sh"

if command -v gh >/dev/null 2>&1 && ! gh auth status >/dev/null 2>&1; then
  echo "warning: GitHub CLI auth is not configured. Run: gh auth login -h github.com" >&2
fi

cat <<'EOF'
Local setup complete.

Next steps:
- make validate-draft PATH=_drafts/example.md
- make qa-local
EOF
