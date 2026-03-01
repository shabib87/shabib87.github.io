#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

draft_path="${DRAFT_PATH:-${1:-}}"

if [[ -z "$draft_path" ]]; then
  echo "error: provide PATH=_drafts/your-post.md or pass the path as the first argument" >&2
  exit 1
fi

"$repo_root/scripts/validate-draft.sh" "$draft_path"

ruby - "$draft_path" <<'RUBY'
require "yaml"

path = ARGV.fetch(0)
content = File.read(path)
match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
abort("error: missing YAML front matter in #{path}") unless match

data = YAML.safe_load(match[1], permitted_classes: [Time], aliases: true) || {}
body = content.sub(match[0], "")
allowed_categories = %w[blog ios swift react-native ai architecture testing debugging leadership developer-tools]

title = data["title"].to_s.strip
description = data["description"].to_s.strip
fact_check_status = data["fact_check_status"].to_s.strip
categories = data["categories"] || []

abort("error: title is too short for publish QA in #{path}") if title.length < 12
abort("error: description is too short for publish QA in #{path}") if description.length < 20
unless %w[complete not-needed].include?(fact_check_status)
  abort("error: fact_check_status must be 'complete' or 'not-needed' in #{path}")
end

unknown_categories = categories - allowed_categories
abort("error: unknown categories in #{path}: #{unknown_categories.join(', ')}") unless unknown_categories.empty?
abort("error: publish-ready posts must include at least one H2 section in #{path}") unless body.match?(/^##\s+\S+/)

lines = body.lines
heading_indexes = lines.each_index.select { |idx| lines[idx].match?(/^##\s+\S+/) }
heading_indexes.each_with_index do |start_idx, pos|
  end_idx = heading_indexes[pos + 1] || lines.length
  section_lines = lines[(start_idx + 1)...end_idx]
  meaningful = section_lines.any? { |line| !line.strip.empty? }
  abort("error: empty section detected in #{path}") unless meaningful
end

puts "publish QA checks passed: #{path}"
RUBY

cat <<EOF
Publish QA complete for: $draft_path

Manual spot-check reminder:
- preview locally if the image or layout matters
- confirm the Unsplash image still fits the post
- confirm fact_check_status is accurate
EOF

printf 'Mark this draft publish-ready? [y/N] '
read -r confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "publish QA cancelled"
  exit 1
fi

echo "publish-ready: $draft_path"
