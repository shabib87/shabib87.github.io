#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

topic="${TOPIC:-${1:-}}"
type="${TYPE:-${2:-chore}}"

if [[ -z "$topic" ]]; then
  echo "error: provide TOPIC or pass it as the first argument" >&2
  exit 1
fi

current_branch="$(git branch --show-current)"
if [[ "$current_branch" != "main" ]]; then
  echo "error: start-work must be run from main; current branch is $current_branch" >&2
  exit 1
fi

"$repo_root/.agents/skills/repo-flow/scripts/ensure-clean-tree.sh"
branch_name="$("$repo_root/.agents/skills/repo-flow/scripts/infer-branch-name.sh" "$type" "$topic")"

main_remote="origin"
main_remote_branch="main"
if upstream_ref="$(git rev-parse --abbrev-ref --symbolic-full-name 'main@{upstream}' 2>/dev/null)"; then
  main_remote="${upstream_ref%%/*}"
  main_remote_branch="${upstream_ref#*/}"
fi

if ! git remote get-url "$main_remote" >/dev/null 2>&1; then
  echo "error: remote $main_remote is not configured for local main" >&2
  exit 1
fi

if ! git fetch "$main_remote" "$main_remote_branch" --quiet; then
  echo "error: failed to fetch $main_remote/$main_remote_branch before creating a branch" >&2
  exit 1
fi

git rebase "$main_remote/$main_remote_branch" >/dev/null
git checkout -b "$branch_name"

echo "created branch: $branch_name"
echo "next: implement the change, then run make qa-local"
