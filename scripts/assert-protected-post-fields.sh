#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

before_path="${1:-}"
after_path="${2:-}"

if [[ -z "$before_path" || -z "$after_path" ]]; then
  echo "usage: $0 <before-post-path> <after-post-path>" >&2
  exit 1
fi

ruby - "$before_path" "$after_path" <<'RUBY'
require "date"
require "yaml"

def load_post(path)
  abort("error: file not found: #{path}") unless File.file?(path)

  content = File.read(path)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  abort("error: missing YAML front matter in #{path}") unless match

  data = YAML.safe_load(match[1], permitted_classes: [Time, Date], aliases: true) || {}
  body = content.sub(match[0], "")

  {
    path: path,
    basename_date: File.basename(path)[/\A(\d{4}-\d{2}-\d{2})-/, 1],
    title: data["title"].to_s,
    description: data["description"].to_s,
    date: data["date"].to_s,
    body: normalize_body(body)
  }
end

def normalize_body(body)
  normalized = body.dup
  normalized.gsub!(/<figure\b[^>]*>(.*?)<\/figure>/m) do
    figure_html = Regexp.last_match(1)
    figure_html.scan(/<figcaption\b[^>]*>(.*?)<\/figcaption>/m).flatten
      .map { |caption| caption.gsub(/<[^>]+>/, " ") }
      .join(" ")
  end
  normalized.gsub!(/!\[[^\]]*\]\([^)]+\)/, " ")
  normalized.gsub!(/<img\b[^>]*>/m, " ")
  normalized.gsub!(/\[([^\]]+)\]\([^)]+\)/, '\1')
  normalized.gsub!(/\s+/, " ")
  normalized.strip
end

before = load_post(ARGV.fetch(0))
after = load_post(ARGV.fetch(1))

checks = {
  "front matter date" => [before[:date], after[:date]],
  "title" => [before[:title], after[:title]],
  "description" => [before[:description], after[:description]],
  "normalized prose body" => [before[:body], after[:body]]
}

if before[:basename_date] && after[:basename_date]
  checks["filename date"] = [before[:basename_date], after[:basename_date]]
end

failures = checks.each_with_object([]) do |(label, values), acc|
  acc << label unless values[0] == values[1]
end

unless failures.empty?
  warn "error: protected post fields changed unexpectedly: #{failures.join(', ')}"
  failures.each do |label|
    before_value, after_value = checks.fetch(label)
    warn "--- #{label} (before)"
    warn before_value
    warn "--- #{label} (after)"
    warn after_value
  end
  exit 1
end

puts "protected post fields preserved: #{before[:path]} -> #{after[:path]}"
RUBY
