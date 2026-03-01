#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

type="${TYPE:-${1:-chore}}"
branch="$(git branch --show-current)"

if [[ "$branch" == "main" ]]; then
  echo "error: create-pr must be run from a feature branch" >&2
  exit 1
fi

"$repo_root/.agents/skills/repo-flow/scripts/ensure-clean-tree.sh"

if ! gh auth status >/dev/null 2>&1; then
  echo "error: GitHub CLI authentication is invalid. Run: gh auth login -h github.com" >&2
  exit 1
fi

if gh pr view "$branch" >/dev/null 2>&1; then
  echo "error: a PR already exists for branch $branch" >&2
  exit 1
fi

"$repo_root/scripts/run-checks.sh"

title_line="$("$repo_root/.agents/skills/repo-flow/scripts/infer-pr-metadata.sh" "$type")"
title="${title_line#TITLE=}"

affected_files="$(git diff --name-only main...HEAD | awk 'NF' || true)"
if [[ -z "$affected_files" ]]; then
  affected_files="(none identified)"
fi

affected_urls="$(ruby -e '
require "yaml"
files = STDIN.read.split("\n")
urls = []
files.each do |file|
  next unless file.end_with?(".md")
  next unless File.file?(file)
  content = File.read(file)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  next unless match
  data = YAML.safe_load(match[1], permitted_classes: [Time], aliases: true) || {}
  permalink = data["permalink"].to_s.strip
  urls << permalink unless permalink.empty?
end
puts urls.uniq
' <<<"$affected_files")"
if [[ -z "$affected_urls" ]]; then
  affected_urls="(none identified)"
fi

body_file="$(mktemp)"
cat > "$body_file" <<EOF
## Summary

- ${title#"$type: "}

## Why

- Standardize the change behind the repo's branch and PR workflow.

## Validation

- \`make check\`

## Affected Files

\`\`\`text
$affected_files
\`\`\`

## Affected URLs

\`\`\`text
$affected_urls
\`\`\`

## Self-review Notes

- Local checks passed
- Diff reviewed
- No private drafts or secrets included
EOF

gh pr create \
  --base main \
  --head "$branch" \
  --title "$title" \
  --body-file "$body_file"

rm -f "$body_file"
