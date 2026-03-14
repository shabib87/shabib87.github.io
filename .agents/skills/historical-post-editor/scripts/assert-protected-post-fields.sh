#!/usr/bin/env bash
set -euo pipefail

format="text"

usage() {
  cat <<'EOF'
Usage: assert-protected-post-fields.sh [--help] [--format text|jsonl] <before-path> <after-path>

Validate preservation-safe edits for tracked published posts.

Checks:
  - front matter title is unchanged
  - front matter description is unchanged
  - front matter date is unchanged
  - _posts/YYYY-MM-DD filename date is unchanged when present
  - prose body text is unchanged after normalizing image and figure markup

Options:
  --help                Show this help and exit.
  --format FORMAT       Output format: text (default) or jsonl.

Examples:
  scripts/assert-protected-post-fields.sh before.md after.md
  scripts/assert-protected-post-fields.sh --format jsonl _before/post.md _after/post.md
EOF
}

paths=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    --format)
      shift
      if [[ $# -eq 0 ]]; then
        echo "error: --format requires a value" >&2
        exit 1
      fi
      format="$1"
      case "$format" in
        text|jsonl) ;;
        *)
          echo "error: --format must be 'text' or 'jsonl'" >&2
          exit 1
          ;;
      esac
      ;;
    --*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      paths+=("$1")
      ;;
  esac
  shift
done

if [[ ${#paths[@]} -ne 2 ]]; then
  usage >&2
  exit 1
fi

ruby - "$format" "${paths[0]}" "${paths[1]}" <<'RUBY'
require "date"
require "json"
require "yaml"

format = ARGV.shift
before_path = ARGV.shift
after_path = ARGV.shift

def parse_post(path)
  abort("error: file not found: #{path}") unless File.file?(path)

  content = File.read(path)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  abort("error: missing YAML front matter in #{path}") unless match

  front_matter = YAML.safe_load(match[1], permitted_classes: [Time, Date], aliases: true) || {}
  body = content[match[0].length..] || ""

  {
    path: path,
    basename: File.basename(path),
    title: front_matter["title"].to_s,
    description: front_matter["description"].to_s,
    date: front_matter["date"].to_s,
    filename_date: File.basename(path)[/\A\d{4}-\d{2}-\d{2}/].to_s,
    prose_fingerprint: normalize_prose(body)
  }
end

def normalize_prose(body)
  normalized = body.dup
  normalized.gsub!(%r{<figure\b.*?</figure>}m, "\n")
  normalized.gsub!(%r{!\[[^\]]*\]\([^)]+\)}, "")
  normalized.gsub!(%r{^\s*<img\b[^>]*>\s*$}i, "")
  normalized.gsub!(%r{^\s*<figcaption\b.*?</figcaption>\s*$}im, "")
  normalized.gsub!(/[ \t]+/, " ")
  normalized.gsub!(/\n{3,}/, "\n\n")
  normalized.lines.map(&:rstrip).join("\n").strip
end

before = parse_post(before_path)
after = parse_post(after_path)

checks = [
  {
    name: "title",
    expected: before[:title],
    actual: after[:title],
    passed: before[:title] == after[:title]
  },
  {
    name: "description",
    expected: before[:description],
    actual: after[:description],
    passed: before[:description] == after[:description]
  },
  {
    name: "date",
    expected: before[:date],
    actual: after[:date],
    passed: before[:date] == after[:date]
  },
  {
    name: "filename_date",
    expected: before[:filename_date],
    actual: after[:filename_date],
    passed: before[:filename_date] == after[:filename_date]
  },
  {
    name: "prose_body",
    expected: before[:prose_fingerprint],
    actual: after[:prose_fingerprint],
    passed: before[:prose_fingerprint] == after[:prose_fingerprint]
  }
]

failed = checks.reject { |check| check[:passed] }

if format == "jsonl"
  puts JSON.generate(
    before_path: before_path,
    after_path: after_path,
    status: failed.empty? ? "validated" : "failed",
    checks: checks
  )
else
  if failed.empty?
    puts "validated: #{after_path}"
  else
    failed.each do |check|
      warn(
        "error: protected field changed for #{check[:name]} in #{after_path}\n" \
        "expected: #{check[:expected].inspect}\n" \
        "actual: #{check[:actual].inspect}"
      )
    end
    exit 1
  end
end

exit 1 unless failed.empty?
RUBY
