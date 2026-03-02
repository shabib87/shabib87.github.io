#!/usr/bin/env bash

repo_tooling_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$script_dir/../.." && pwd
}

repo_pre_commit_bin() {
  local repo_root
  repo_root="$(repo_tooling_root)"
  printf '%s/.venv-tools/bin/pre-commit\n' "$repo_root"
}

repo_ruby_version() {
  local repo_root
  repo_root="$(repo_tooling_root)"
  tr -d '[:space:]' < "$repo_root/.ruby-version"
}

require_repo_ruby() {
  local expected actual
  expected="$(repo_ruby_version)"
  actual="$(ruby -e 'print RUBY_VERSION')"

  if [[ "$actual" != "$expected" ]]; then
    echo "error: ruby $expected is required, but found $actual" >&2
    return 1
  fi
}

require_repo_pre_commit() {
  local pre_commit_bin
  pre_commit_bin="$(repo_pre_commit_bin)"
  if [[ ! -x "$pre_commit_bin" ]]; then
    echo "error: repo-managed pre-commit is not installed. Run: make setup" >&2
    return 1
  fi

  printf '%s\n' "$pre_commit_bin"
}

repo_common_ancestor() {
  git merge-base main HEAD 2>/dev/null || true
}

repo_merge_base() {
  repo_common_ancestor
}

repo_changed_files() {
  local common_ancestor
  common_ancestor="$(repo_common_ancestor)"

  if [[ -n "$common_ancestor" ]]; then
    git diff --name-only --diff-filter=ACMR "$common_ancestor"...HEAD
  fi

  git ls-files --others --exclude-standard
}

repo_site_facing_changes() {
  repo_changed_files |
    awk 'NF' |
    grep -E '^(_config\.yml|_includes/|_layouts/|_pages/|_posts/|assets/|_sass/)' ||
    true
}
