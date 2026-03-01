#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <post-or-draft-path> [more-paths...]" >&2
  exit 1
fi

ruby - "$repo_root" "$@" <<'RUBY'
require "date"
require "yaml"

repo_root = ARGV.shift

ARGV.each do |path|
  abort("error: file not found: #{path}") unless File.file?(path)

  content = File.read(path)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  abort("error: missing YAML front matter in #{path}") unless match

  data = YAML.safe_load(match[1], permitted_classes: [Time, Date], aliases: true) || {}
  required = %w[title description permalink categories tags last_modified_at]
  strict_required = %w[image image_alt image_source fact_check_status]
  required.concat(strict_required) if ENV.fetch("STRICT_POST_METADATA", "0") == "1"
  missing = required.reject do |key|
    value = data[key]
    !(value.nil? || (value.respond_to?(:empty?) && value.empty?))
  end

  abort("error: missing required fields in #{path}: #{missing.join(', ')}") unless missing.empty?

  unless data["categories"].is_a?(Array) && !data["categories"].empty?
    abort("error: categories must be a non-empty array in #{path}")
  end

  unless data["tags"].is_a?(Array) && !data["tags"].empty?
    abort("error: tags must be a non-empty array in #{path}")
  end

  permalink = data["permalink"].to_s
  unless permalink.start_with?("/") && permalink.end_with?("/")
    abort("error: permalink must start and end with '/' in #{path}")
  end

  has_image_metadata = strict_required.any? { |key| data.key?(key) && !data[key].to_s.empty? }

  if has_image_metadata
    image = data["image"].to_s
    image_source = data["image_source"].to_s

    case image_source
    when "unsplash"
      unless image.match?(%r{\Ahttps?://(?:images\.)?unsplash\.com/}) || image.match?(%r{\Ahttps?://unsplash\.com/})
        abort("error: image_source is unsplash but image is not an Unsplash URL in #{path}")
      end
    when "local"
      unless image.start_with?("/assets/images/posts/")
        abort("error: local images must live under /assets/images/posts/ in #{path}")
      end
      local_path = File.join(repo_root, image.sub(%r{\A/}, ""))
      abort("error: local image file does not exist: #{image}") unless File.file?(local_path)
    else
      abort("error: image_source must be 'unsplash' or 'local' in #{path}")
    end
  end

  if data.key?("fact_check_status") && !%w[complete not-needed].include?(data["fact_check_status"].to_s)
    abort("error: fact_check_status must be 'complete' or 'not-needed' in #{path}")
  end

  if path.include?("/_posts/")
    basename = File.basename(path)
    unless basename.match?(/\A\d{4}-\d{2}-\d{2}-.+\.md\z/)
      abort("error: published posts must use YYYY-MM-DD-title.md naming in #{path}")
    end
    abort("error: published posts must include date in #{path}") if data["date"].nil?
  end

  puts "validated: #{path}"
end
RUBY
