#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

repo_root = File.expand_path("..", __dir__)
errors = []

phase = ENV["PHASE"].to_s.strip
if phase.empty?
  branch = `git -C "#{repo_root}" branch --show-current 2>/dev/null`.strip
  if (match = branch.match(/^codex\/phase-(\d+)(-|$)/))
    phase = match[1]
  end
end

phase_num = phase.to_i

config_path = File.join(repo_root, ".codex", "config.toml")
unless File.file?(config_path)
  if phase_num >= 2
    warn "error: missing .codex/config.toml for phase #{phase_num}"
    exit 1
  end

  puts "multi-agent contract checks skipped (config not present yet)"
  exit 0
end

config = File.read(config_path)

required_defaults = {
  "max_threads" => "6",
  "max_depth" => "1",
  "job_max_runtime_seconds" => "1800"
}

required_defaults.each do |key, value|
  unless config.match?(/^#{Regexp.escape(key)}\s*=\s*#{Regexp.escape(value)}\s*$/)
    errors << "missing or invalid #{key} in .codex/config.toml (expected #{value})"
  end
end

roles = {
  "team-lead" => {
    ownership_text: /do not draft or rewrite blog body prose by default/i,
    sandbox_mode: "read-only"
  },
  "researcher" => {
    sandbox_mode: "read-only"
  },
  "developer" => {
    sandbox_mode: "workspace-write"
  },
  "seo-expert" => {
    sandbox_mode: "read-only"
  },
  "writer" => {
    ownership_text: /own drafting and restructuring of blog body prose/i,
    sandbox_mode: "workspace-write"
  },
  "editor" => {
    ownership_text: /own editorial refinement, structure, clarity, and voice polish/i,
    sandbox_mode: "workspace-write"
  },
  "fact-checker" => {
    sandbox_mode: "read-only"
  },
  "publisher-release" => {
    ownership_text: /do not write or rewrite article body prose/i,
    sandbox_mode: "workspace-write"
  },
  "historical-post-editor" => {
    sandbox_mode: "workspace-write"
  }
}

roles.each_key do |role|
  section = "[agents.#{role}]"
  expected_file = "config_file = \"agents/#{role}.toml\""

  errors << "missing #{section} in .codex/config.toml" unless config.include?(section)
  errors << "missing config_file for #{role} in .codex/config.toml" unless config.include?(expected_file)
end

roles.each do |role, rules|
  role_file = File.join(repo_root, ".codex", "agents", "#{role}.toml")
  unless File.file?(role_file)
    errors << "missing .codex/agents/#{role}.toml"
    next
  end

  content = File.read(role_file)
  unless content.match?(/^sandbox_mode\s*=\s*"#{Regexp.escape(rules[:sandbox_mode])}"\s*$/)
    errors << "invalid sandbox_mode for #{role}; expected #{rules[:sandbox_mode]}"
  end

  unless content.include?("developer_instructions")
    errors << "missing developer_instructions in .codex/agents/#{role}.toml"
  end

  if rules[:ownership_text] && !content.match?(rules[:ownership_text])
    errors << "missing ownership lock text in .codex/agents/#{role}.toml"
  end
end

if errors.empty?
  puts "multi-agent contract checks passed"
  puts "validated roles: #{roles.length}"
else
  errors.each { |error| warn "error: #{error}" }
  exit 1
end
