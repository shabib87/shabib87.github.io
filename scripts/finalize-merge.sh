#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

pr="${PR:-${1:-}}"

"$repo_root/.agents/skills/repo-flow/scripts/ensure-clean-tree.sh"

if ! gh auth status >/dev/null 2>&1; then
  echo "error: GitHub CLI authentication is invalid. Run: gh auth login -h github.com" >&2
  exit 1
fi

if [[ -z "$pr" ]]; then
  branch="$(git branch --show-current)"
  pr="$branch"
fi

"$repo_root/scripts/run-checks.sh"

pr_state="$(gh pr view "$pr" --json statusCheckRollup,isDraft,url)"
is_draft="$(printf '%s' "$pr_state" | ruby -rjson -e 'data = JSON.parse(STDIN.read); print(data["isDraft"] ? "true" : "false")')"
pr_url="$(printf '%s' "$pr_state" | ruby -rjson -e 'data = JSON.parse(STDIN.read); print(data["url"] || "")')"
checks_summary="$(printf '%s' "$pr_state" | ruby -rjson -e '
data = JSON.parse(STDIN.read)
checks = data["statusCheckRollup"] || []
lines = []
bad = false
checks.each do |item|
  name = item["name"] || item["context"] || "unnamed-check"
  conclusion = item["conclusion"] || item["state"]
  lines << "#{name}: #{conclusion}"
  bad ||= !["SUCCESS", "SKIPPED", "SUCCESSFUL", nil].include?(conclusion)
end
puts({count: checks.length, bad: bad, lines: lines}.to_json)
')"
checks_count="$(printf '%s' "$checks_summary" | ruby -rjson -e 'data = JSON.parse(STDIN.read); print(data["count"])')"
checks_bad="$(printf '%s' "$checks_summary" | ruby -rjson -e 'data = JSON.parse(STDIN.read); print(data["bad"] ? "true" : "false")')"
checks_lines="$(printf '%s' "$checks_summary" | ruby -rjson -e 'data = JSON.parse(STDIN.read); puts((data["lines"] || []).join("\n"))')"

if [[ "$is_draft" == "true" ]]; then
  echo "error: PR is still a draft" >&2
  exit 1
fi

if [[ "$checks_bad" == "true" ]]; then
  echo "error: one or more reported CI status checks are failing" >&2
  printf '%s\n' "$checks_lines" >&2
  exit 1
fi

if [[ "$checks_count" -gt 0 ]]; then
  echo "reported CI checks:"
  printf '%s\n' "$checks_lines"
else
  echo "warning: no CI status checks reported for this PR; proceeding with local-first self-review."
fi

rebase_allowed="$(gh repo view --json rebaseMergeAllowed --jq '.rebaseMergeAllowed')"
if [[ "$rebase_allowed" != "true" ]]; then
  echo "error: repository is not configured for rebase merges; refusing to pick a different strategy silently" >&2
  exit 1
fi

cat <<EOF
Self-review checklist for $pr_url
- local checks passed
- diff reviewed
- no private drafts or secrets included
- PR title/body look correct
- changed files and URLs are expected
EOF
printf 'Merge this PR to main? [y/N] '
read -r confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "merge cancelled"
  exit 1
fi

gh pr merge "$pr" --rebase --delete-branch

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

git checkout main
git pull --ff-only "$main_remote" "$main_remote_branch"
