#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

ruby - "$repo_root" <<'RUBY'
require "date"
require "yaml"

repo_root = ARGV.fetch(0)
errors = []

skill_paths = Dir[File.join(repo_root, ".agents", "skills", "*")].select { |path| File.directory?(path) }.sort

if skill_paths.empty?
  errors << "no skill directories found under .agents/skills"
end

skill_paths.each do |skill_path|
  skill_md = File.join(skill_path, "SKILL.md")
  skill_label = skill_path.delete_prefix("#{repo_root}/")

  unless File.file?(skill_md)
    errors << "missing SKILL.md in #{skill_label}"
    next
  end

  content = File.read(skill_md)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  if match.nil?
    errors << "missing YAML front matter in #{skill_label}/SKILL.md"
  else
    data = YAML.safe_load(match[1], permitted_classes: [Time, Date], aliases: true) || {}
    errors << "missing name in #{skill_label}/SKILL.md" if data["name"].to_s.strip.empty?
    errors << "missing description in #{skill_label}/SKILL.md" if data["description"].to_s.strip.empty?
  end

  openai_yaml = File.join(skill_path, "agents", "openai.yaml")
  unless File.file?(openai_yaml)
    errors << "missing agents/openai.yaml in #{skill_label}"
    next
  end

  openai = YAML.safe_load(File.read(openai_yaml), permitted_classes: [Time, Date], aliases: true) || {}
  interface = openai["interface"]
  unless interface.is_a?(Hash)
    errors << "missing interface block in #{skill_label}/agents/openai.yaml"
    next
  end

  %w[display_name short_description default_prompt].each do |field|
    errors << "missing interface.#{field} in #{skill_label}/agents/openai.yaml" if interface[field].to_s.strip.empty?
  end
end

makefile = File.read(File.join(repo_root, "Makefile"))
%w[site-audit codex-check qa-local].each do |target|
  errors << "missing #{target} target in Makefile" unless makefile.match?(/^#{Regexp.escape(target)}:/)
end

docs_index = File.read(File.join(repo_root, ".codex", "docs", "README.md"))
{
  "[Codex Usage](./codex-usage.md)" => ".codex/docs/codex-usage.md",
  "[Site Quality](./site-quality.md)" => ".codex/docs/site-quality.md"
}.each do |needle, path|
  errors << "missing docs index entry for #{path}" unless docs_index.include?(needle)
end

prompt_dir = File.join(repo_root, ".codex", "prompts")
errors << "missing .codex/prompts directory" unless Dir.exist?(prompt_dir)

%w[editorial-workflow.md site-quality.md repo-workflow.md official-docs.md].each do |prompt|
  prompt_path = File.join(prompt_dir, prompt)
  errors << "missing #{prompt_path.delete_prefix("#{repo_root}/")}" unless File.file?(prompt_path)
end

if errors.empty?
  puts "codex workflow checks passed"
  puts "validated skills: #{skill_paths.length}"
else
  errors.each { |error| warn "error: #{error}" }
  exit 1
end
RUBY
