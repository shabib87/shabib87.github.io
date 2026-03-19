#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# shellcheck disable=SC1091
. "$repo_root/scripts/lib/tooling.sh"

profiles_raw="${CI_SETUP_PROFILE:-base}"
profiles="$(printf '%s' "$profiles_raw" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
profiles=",${profiles},"

has_profile() {
  local profile="$1"
  [[ "$profiles" == *",all,"* ]] || [[ "$profiles" == *",${profile},"* ]]
}

ensure_repo_pre_commit() {
  if ! command -v python3 >/dev/null 2>&1; then
    echo "error: python3 is required for ci-setup base profile" >&2
    exit 1
  fi

  python3 -m venv "$repo_root/.venv-tools"
  "$repo_root/.venv-tools/bin/pip" install --requirement "$repo_root/requirements-dev.txt"
}

ensure_ruby_bundle() {
  if ! command -v bundle >/dev/null 2>&1; then
    echo "error: bundler is required for ci-setup ruby profile" >&2
    echo "hint: run ruby/setup-ruby before make ci-setup" >&2
    exit 1
  fi

  activate_repo_ruby
  export BUNDLE_PATH="$repo_root/vendor/bundle"
  export BUNDLE_FROZEN="true"
  bundle install --jobs 4 --retry 3
}

ensure_semgrep() {
  if command -v semgrep >/dev/null 2>&1; then
    return 0
  fi

  "$repo_root/.venv-tools/bin/pip" install semgrep
}

ensure_node_docs() {
  if ! command -v node >/dev/null 2>&1; then
    echo "error: node is required for ci-setup node-docs profile" >&2
    echo "hint: run actions/setup-node before make ci-setup" >&2
    exit 1
  fi
}

if has_profile "base"; then
  ensure_repo_pre_commit
fi

if has_profile "ruby"; then
  ensure_ruby_bundle
fi

if has_profile "semgrep"; then
  ensure_repo_pre_commit
  ensure_semgrep
fi

if has_profile "node-docs"; then
  ensure_node_docs
fi

echo "ci setup complete (profiles: ${profiles_raw})"
