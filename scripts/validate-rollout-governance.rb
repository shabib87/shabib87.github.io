#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "open3"
require "optparse"
require "yaml"

options = {
  repo_root: File.expand_path("..", __dir__)
}

OptionParser.new do |parser|
  parser.on("--repo-root PATH", "Repository root path") do |value|
    options[:repo_root] = File.expand_path(value)
  end
  parser.on("--branch NAME", "Branch name override") do |value|
    options[:branch] = value
  end
end.parse!(ARGV)

repo_root = options[:repo_root]
errors = []

active_plan_path = File.join(repo_root, ".codex", "rollout", "active-plan.yaml")
unless File.file?(active_plan_path)
  warn "error: missing active rollout plan #{active_plan_path.delete_prefix("#{repo_root}/")}"
  exit 1
end

plan = YAML.safe_load(File.read(active_plan_path), permitted_classes: [Date, Time], aliases: false) || {}

plan_id = plan["plan_id"].to_s.strip
apply_to_all_prs = plan["apply_to_all_prs"] == true
mode = plan["mode"].to_s.strip
base_branch = plan["base_branch"].to_s.strip
task_branch_pattern = plan["task_branch_pattern"].to_s.strip
exempt_branch_patterns = plan["exempt_branch_patterns"].is_a?(Array) ? plan["exempt_branch_patterns"] : []
limits = plan["limits"].is_a?(Hash) ? plan["limits"] : {}
max_changed_files_non_content = limits["max_changed_files_non_content"]
max_changed_lines_non_content = limits["max_changed_lines_non_content"]
ignore_paths_for_size_caps = limits["ignore_paths_for_size_caps"].is_a?(Array) ? limits["ignore_paths_for_size_caps"] : []

errors << "active-plan.yaml missing plan_id" if plan_id.empty?
errors << "active-plan.yaml must set apply_to_all_prs=true" unless apply_to_all_prs
errors << "active-plan.yaml mode must be sequential" unless mode == "sequential"
errors << "active-plan.yaml missing base_branch" if base_branch.empty?
errors << "active-plan.yaml missing task_branch_pattern" if task_branch_pattern.empty?
errors << "active-plan.yaml limits.max_changed_files_non_content must be a positive integer" unless max_changed_files_non_content.is_a?(Integer) && max_changed_files_non_content.positive?
errors << "active-plan.yaml limits.max_changed_lines_non_content must be a positive integer" unless max_changed_lines_non_content.is_a?(Integer) && max_changed_lines_non_content.positive?
errors << "active-plan.yaml limits.ignore_paths_for_size_caps must be a non-empty list" if ignore_paths_for_size_caps.empty?

branch = options[:branch] || ENV["ROLLOUT_BRANCH"]
if branch.to_s.strip.empty?
  branch_output, status = Open3.capture2("git", "-C", repo_root, "branch", "--show-current")
  branch = status.success? ? branch_output.strip : ""
end
if branch.to_s.strip.empty?
  branch = ENV["GITHUB_HEAD_REF"] || ENV["GITHUB_REF_NAME"] || ""
end

if branch == base_branch
  puts "rollout governance check skipped for base branch #{base_branch}"
  exit 0 if errors.empty?
elsif branch.empty?
  errors << "unable to detect current branch"
else
  exempt = exempt_branch_patterns.any? { |pattern| Regexp.new(pattern).match?(branch) rescue false }
  if exempt
    puts "rollout governance check passed for plan=#{plan_id} branch=#{branch} (exempt)"
    exit 0 if errors.empty?
  else
    task_match = Regexp.new(task_branch_pattern).match(branch) rescue nil
    if task_match.nil? && apply_to_all_prs
      errors << "branch #{branch.inspect} does not match task pattern #{task_branch_pattern.inspect}"
    end
  end
end

if errors.any?
  errors.each { |error| warn "error: #{error}" }
  exit 1
end

puts "rollout governance check passed for plan=#{plan_id} branch_mode=task"
