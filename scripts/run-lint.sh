#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# shellcheck disable=SC1091
. "$repo_root/scripts/lib/tooling.sh"

pre_commit_bin="$(require_repo_pre_commit)"

common_ancestor="$(repo_common_ancestor)"
tracked_changed="$(if [[ -n "$common_ancestor" ]]; then git diff --name-only --diff-filter=ACMR "$common_ancestor"...HEAD; fi)"
untracked_changed="$(git ls-files --others --exclude-standard)"
changed_files="$(
  printf '%s\n%s\n' "$tracked_changed" "$untracked_changed" |
    awk 'NF' |
    grep -E '^(AGENTS\.md|README\.md|\.gitignore|\.pre-commit-config\.yaml|\.markdownlint-cli2\.yaml|\.shellcheckrc|\.semgrep\.yml|\.ruby-version|Brewfile|requirements-dev\.txt|Makefile|scripts/|\.agents/|\.codex/|\.github/)' ||
    true
)"
changed_files="$(printf '%s\n' "$changed_files" | awk 'NF' | sort -u)"

run_hook_for_pattern() {
  local hook_id="$1"
  local pattern="$2"
  local files=()
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    files+=("$file")
  done < <(printf '%s\n' "$changed_files" | grep -E "$pattern" || true)
  if [[ "${#files[@]}" -gt 0 ]]; then
    "$pre_commit_bin" run "$hook_id" --files "${files[@]}"
  fi
}

run_hook_for_pattern check-yaml '\.(yml|yaml)$'
run_hook_for_pattern markdownlint-cli2 '\.md$'
run_hook_for_pattern shellcheck '(^|/)[^/]+\.sh$'
run_hook_for_pattern actionlint '^\.github/workflows/.*\.ya?ml$'
