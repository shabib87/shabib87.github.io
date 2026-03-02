#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

audit="${AUDIT:-${1:-}}"
target="${TARGET:-${2:-site}}"

if [[ -z "$audit" ]]; then
  echo "error: provide AUDIT=seo|performance|quality|maintenance or pass it as the first argument" >&2
  exit 1
fi

case "$audit" in
  seo|performance|quality|maintenance)
    ;;
  *)
    echo "error: AUDIT must be one of: seo, performance, quality, maintenance" >&2
    exit 1
    ;;
esac

ruby - "$repo_root" "$audit" "$target" <<'RUBY'
require "date"
require "yaml"

repo_root, audit, target = ARGV

Finding = Struct.new(:severity, :scope, :message, :path, keyword_init: true)
SEVERITY_ORDER = { "error" => 0, "warning" => 1, "note" => 2 }.freeze

def relative_path(repo_root, path)
  path.delete_prefix("#{repo_root}/")
end

def load_frontmatter(path)
  content = File.read(path)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  data =
    if match
      YAML.safe_load(match[1], permitted_classes: [Time, Date], aliases: true) || {}
    else
      nil
    end
  [content, data]
end

def markdown_candidates(repo_root)
  Dir[File.join(repo_root, "_pages", "**", "*.md")].sort +
    Dir[File.join(repo_root, "_posts", "**", "*.md")].sort
end

def resolve_target(repo_root, target)
  if target == "site"
    files = %w[
      _pages/about.md
      _pages/posts.md
      _pages/tag-archive.md
      _pages/category-archive.md
      _pages/year-archive.md
      _pages/404.md
    ].map { |path| File.join(repo_root, path) }.select { |path| File.file?(path) }
    return ["site", files]
  end

  candidate = File.expand_path(target, repo_root)
  return [target, [candidate]] if File.file?(candidate)
  return [target, Dir[File.join(candidate, "**", "*.md")].sort] if Dir.exist?(candidate)

  if target.start_with?("/")
    match = markdown_candidates(repo_root).find do |path|
      _, data = load_frontmatter(path)
      next false unless data

      data["permalink"].to_s.strip == target
    end
    raise "could not resolve URL path #{target}" unless match

    return [target, [match]]
  end

  raise "TARGET must be 'site', a repo path, or a URL path starting with /"
end

def add_finding(findings, severity, scope, message, path = nil)
  findings << Finding.new(severity: severity, scope: scope, message: message, path: path)
end

def inspect_front_matter(findings, repo_root, path, data)
  rel = relative_path(repo_root, path)
  if data.nil?
    add_finding(findings, "error", "frontmatter", "missing YAML front matter", rel)
    return
  end

  add_finding(findings, "error", "frontmatter", "missing title", rel) if data["title"].to_s.strip.empty?
  add_finding(findings, "warning", "frontmatter", "missing description", rel) if data["description"].to_s.strip.empty?

  robots = data["robots"].to_s
  sitemap = data["sitemap"]
  if robots.match?(/noindex/i) && sitemap == true
    add_finding(findings, "warning", "indexing", "noindex page is still marked for sitemap inclusion", rel)
  end
end

config_path = File.join(repo_root, "_config.yml")
head_path = File.join(repo_root, "_includes", "head", "custom.html")
json_ld_path = File.join(repo_root, "_includes", "json-ld.html")
makefile_path = File.join(repo_root, "Makefile")
run_checks_path = File.join(repo_root, "scripts", "run-checks.sh")

findings = []

unless File.file?(config_path)
  add_finding(findings, "error", "repo", "missing _config.yml", "_config.yml")
end
unless File.file?(head_path)
  add_finding(findings, "error", "repo", "missing _includes/head/custom.html", "_includes/head/custom.html")
end
unless File.file?(json_ld_path)
  add_finding(findings, "error", "repo", "missing _includes/json-ld.html", "_includes/json-ld.html")
end

label, target_files = resolve_target(repo_root, target)

config = File.file?(config_path) ? (YAML.load_file(config_path) || {}) : {}
plugins = Array(config["plugins"])
includes = Array(config["include"])
head = File.file?(head_path) ? File.read(head_path) : ""
json_ld = File.file?(json_ld_path) ? File.read(json_ld_path) : ""
makefile = File.file?(makefile_path) ? File.read(makefile_path) : ""
run_checks = File.file?(run_checks_path) ? File.read(run_checks_path) : ""

case audit
when "seo"
  add_finding(findings, "error", "seo", "jekyll-seo-tag plugin is not enabled", "_config.yml") unless plugins.include?("jekyll-seo-tag")
  add_finding(findings, "error", "seo", "jekyll-sitemap plugin is not enabled", "_config.yml") unless plugins.include?("jekyll-sitemap")
  add_finding(findings, "error", "seo", "site.url is missing", "_config.yml") if config["url"].to_s.strip.empty?
  add_finding(findings, "error", "seo", "custom head is missing `{% seo %}`", "_includes/head/custom.html") unless head.include?("{% seo %}")
  add_finding(findings, "warning", "seo", "custom head does not include json-ld partial", "_includes/head/custom.html") unless head.include?("{% include json-ld.html %}")
  add_finding(findings, "warning", "seo", "json-ld partial is missing schema.org context", "_includes/json-ld.html") unless json_ld.include?('"@context": "https://schema.org"')
  add_finding(findings, "warning", "seo", "json-ld partial is missing BlogPosting schema", "_includes/json-ld.html") unless json_ld.include?('"@type": "BlogPosting"')
  if head.include?("{% seo %}") && head.include?('<meta property="og:title"')
    add_finding(findings, "warning", "seo", "custom head duplicates Open Graph metadata on top of `{% seo %}`", "_includes/head/custom.html")
  end
  if head.include?("{% seo %}") && head.include?('<meta name="twitter:title"')
    add_finding(findings, "warning", "seo", "custom head duplicates Twitter card metadata on top of `{% seo %}`", "_includes/head/custom.html")
  end

  target_files.each do |path|
    _, data = load_frontmatter(path)
    inspect_front_matter(findings, repo_root, path, data)

    next unless data
    rel = relative_path(repo_root, path)
    if File.basename(path) == "404.md"
      add_finding(findings, "warning", "seo", "404 page should set sitemap: false", rel) unless data["sitemap"] == false
      add_finding(findings, "warning", "seo", "404 page should set robots to noindex", rel) unless data["robots"].to_s.match?(/noindex/i)
    end
  end
when "performance"
  if head.include?("mermaid.min.js")
    add_finding(findings, "warning", "performance", "Mermaid is loaded globally from a CDN on every page", "_includes/head/custom.html")
  end
  if head.include?("goatcounter")
    add_finding(findings, "note", "performance", "GoatCounter analytics script loads on every page", "_includes/head/custom.html")
  end
  if head.include?("cdn.jsdelivr.net")
    add_finding(findings, "warning", "performance", "A jsDelivr asset is loaded globally; review cache and critical path impact", "_includes/head/custom.html")
  end

  oversized_images = Dir[File.join(repo_root, "assets", "images", "**", "*")].select do |path|
    File.file?(path) && File.size(path) > 500_000
  end.sort_by { |path| -File.size(path) }

  oversized_images.first(5).each do |path|
    add_finding(
      findings,
      "warning",
      "performance",
      format("large local image asset (%<kb>.1f KB)", kb: File.size(path) / 1024.0),
      relative_path(repo_root, path)
    )
  end
when "quality"
  add_finding(findings, "error", "quality", "_pages is not included in the Jekyll build config", "_config.yml") unless includes.include?("_pages")
  add_finding(findings, "warning", "quality", "custom head does not include json-ld partial", "_includes/head/custom.html") unless head.include?("{% include json-ld.html %}")

  target_files.each do |path|
    _, data = load_frontmatter(path)
    inspect_front_matter(findings, repo_root, path, data)
    next unless data

    rel = relative_path(repo_root, path)
    add_finding(findings, "warning", "quality", "missing layout", rel) if data["layout"].to_s.strip.empty?
    if File.basename(path) == "404.md"
      add_finding(findings, "warning", "quality", "404 page should set sitemap: false", rel) unless data["sitemap"] == false
      add_finding(findings, "warning", "quality", "404 page should set robots to noindex", rel) unless data["robots"].to_s.match?(/noindex/i)
    end
  end
when "maintenance"
  if config["remote_theme"].to_s.strip != ""
    add_finding(
      findings,
      "warning",
      "maintenance",
      "remote_theme is enabled; clean builds depend on fetching the theme when it is not already cached",
      "_config.yml"
    )
  end

  if head.match?(%r{https://})
    add_finding(findings, "warning", "maintenance", "custom head includes third-party scripts or assets; review them during site maintenance", "_includes/head/custom.html")
  end

  if run_checks.include?("bundle exec jekyll build") && config["remote_theme"].to_s.strip != ""
    add_finding(findings, "note", "maintenance", "make check requires a successful Jekyll build and may need network access for the remote theme", "scripts/run-checks.sh")
  end

  %w[site-audit codex-check qa-local].each do |target_name|
    add_finding(findings, "error", "maintenance", "missing #{target_name} Make target", "Makefile") unless makefile.match?(/^#{Regexp.escape(target_name)}:/)
  end
end

ordered = findings.sort_by { |finding| [SEVERITY_ORDER.fetch(finding.severity), finding.scope, finding.path.to_s, finding.message] }
error_count = ordered.count { |finding| finding.severity == "error" }

puts "Audit: #{audit}"
puts "Target: #{label}"

if ordered.empty?
  puts "No findings."
else
  ordered.each do |finding|
    location = finding.path ? " (#{finding.path})" : ""
    puts "[#{finding.severity.upcase}] #{finding.scope}: #{finding.message}#{location}"
  end
end

puts "Summary: #{error_count} error(s), #{ordered.count { |finding| finding.severity == "warning" }} warning(s), #{ordered.count { |finding| finding.severity == "note" }} note(s)"
exit 1 if error_count.positive?
RUBY
