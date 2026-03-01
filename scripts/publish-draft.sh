#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

draft_path="${DRAFT_PATH:-${1:-}}"
publish_date="${DATE:-${2:-}}"
slug_override="${SLUG:-${3:-}}"

if [[ -z "$draft_path" || -z "$publish_date" ]]; then
  echo "usage: make publish-draft PATH=_drafts/post.md DATE=YYYY-MM-DD" >&2
  exit 1
fi

if [[ ! "$publish_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "error: DATE must be in YYYY-MM-DD format" >&2
  exit 1
fi

case "$draft_path" in
  _drafts/*|./_drafts/*|"${repo_root}/_drafts/"*)
    ;;
  *)
    echo "error: publish-draft only supports files under _drafts/" >&2
    exit 1
    ;;
esac

"$repo_root/scripts/qa-publish.sh" "$draft_path"

target_path="$(ruby - "$draft_path" "$publish_date" "$slug_override" <<'RUBY'
require "yaml"

path = ARGV.fetch(0)
publish_date = ARGV.fetch(1)
slug_override = ARGV.fetch(2)
content = File.read(path)
match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
abort("error: missing YAML front matter in #{path}") unless match

data = YAML.safe_load(match[1], permitted_classes: [Time], aliases: true) || {}
body = content.sub(match[0], "")
slug = if !slug_override.nil? && !slug_override.empty?
  slug_override
else
  data.fetch("title").to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "").gsub(/-+/, "-")
end
abort("error: could not derive a slug from #{path}") if slug.empty?

data["date"] = publish_date
yaml = YAML.dump(data).sub(/\A---\s*\n/, "").sub(/\n\.\.\.\s*\z/, "")
target_path = File.expand_path(File.join(File.dirname(path), "..", "_posts", "#{publish_date}-#{slug}.md"))
abort("error: target post already exists: #{target_path}") if File.exist?(target_path)

File.write(target_path, "---\n#{yaml}---\n\n#{body}")
puts target_path
RUBY
)"

"$repo_root/.agents/skills/jekyll-post-publisher/scripts/validate-post.sh" "$target_path"

echo "published draft to: $target_path"
echo "next: make check"
