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

git fetch origin main --quiet || true
git checkout -b "$branch_name"

echo "created branch: $branch_name"
echo "next: make check"
