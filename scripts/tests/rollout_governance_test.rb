#!/usr/bin/env ruby
# frozen_string_literal: true
require "fileutils"
require "minitest/autorun"
require "tmpdir"
require "yaml"
class RolloutGovernanceTest < Minitest::Test
  VALIDATOR = File.expand_path("../validate-rollout-governance.rb", __dir__)
  def with_repo(branch: "cws/1-test")
    Dir.mktmpdir("rollout-governance-test") do |dir|
      Dir.chdir(dir) do
        system!("git", "init")
        system!("git", "config", "user.name", "Test User")
        system!("git", "config", "user.email", "test@example.com")
        FileUtils.mkdir_p(".codex/rollout")
        File.write("README.md", "baseline\n")
        system!("git", "add", "README.md")
        system!("git", "commit", "-m", "baseline")
        system!("git", "checkout", "-b", branch)
        yield dir
      end
    end
  end
  def write_active_plan(overrides = {})
    plan = {
      "version" => 1,
      "plan_id" => "governance-v3",
      "apply_to_all_prs" => true,
      "mode" => "sequential",
      "base_branch" => "main",
      "task_branch_pattern" => "^cws/\\d+-[a-z0-9-]+$",
      "limits" => {
        "max_changed_files_non_content" => 25,
        "max_changed_lines_non_content" => 1200,
        "ignore_paths_for_size_caps" => ["_posts/**", "_pages/**", "_drafts/**"]
      },
      "required_checks" => ["build", "semgrep", "rollout-governance"]
    }
    deep_merge!(plan, overrides)
    File.write(".codex/rollout/active-plan.yaml", plan.to_yaml)
  end
  def run_validator(branch: nil, env: {})
    rd_out, wr_out = IO.pipe
    rd_err, wr_err = IO.pipe
    argv = ["--repo-root", Dir.pwd]
    argv += ["--branch", branch] if branch
    pid = fork do
      $stdout.reopen(wr_out)
      $stderr.reopen(wr_err)
      wr_out.close
      wr_err.close
      rd_out.close
      rd_err.close
      env.each { |k, v| ENV[k] = v }
      ARGV.replace(argv)
      load VALIDATOR
    end
    wr_out.close
    wr_err.close
    _, status = Process.wait2(pid)
    [rd_out.read, rd_err.read, status]
  ensure
    [rd_out, wr_out, rd_err, wr_err].each { |io| io&.close unless io&.closed? }
  end
  def test_accepts_valid_cws_branch_without_phase_enforcement
    with_repo(branch: "cws/16-branch-policy") do
      write_active_plan
      stdout, stderr, status = run_validator
      assert status.success?, "expected success, got stderr: #{stderr}\nstdout: #{stdout}"
      assert_match(/branch_mode=task/, stdout)
    end
  end
  def test_rejects_invalid_non_matching_branch
    with_repo(branch: "feature/cws-16-branch-policy") do
      write_active_plan
      _stdout, stderr, status = run_validator
      refute status.success?
      assert_match(/does not match task pattern/i, stderr)
    end
  end

  def test_accepts_exempt_dependabot_branch
    with_repo(branch: "dependabot/npm_and_yarn/lodash-4.17.21") do
      write_active_plan("exempt_branch_patterns" => ["^dependabot/", "^renovate/", "^gh-pages$"])
      stdout, stderr, status = run_validator(branch: "dependabot/npm_and_yarn/lodash-4.17.21")
      assert status.success?, "expected success for exempt branch, got stderr: #{stderr}"
      assert_match(/exempt/, stdout)
    end
  end

  def test_accepts_exempt_gh_pages_branch
    with_repo(branch: "gh-pages") do
      write_active_plan("exempt_branch_patterns" => ["^dependabot/", "^renovate/", "^gh-pages$"])
      stdout, stderr, status = run_validator(branch: "gh-pages")
      assert status.success?, "expected success for exempt branch, got stderr: #{stderr}"
      assert_match(/exempt/, stdout)
    end
  end

  def test_rejects_non_exempt_non_matching_branch
    with_repo(branch: "feature/random") do
      write_active_plan("exempt_branch_patterns" => ["^dependabot/", "^renovate/", "^gh-pages$"])
      _stdout, stderr, status = run_validator(branch: "feature/random")
      refute status.success?
      assert_match(/does not match task pattern/i, stderr)
    end
  end

  private
  def deep_merge!(target, updates)
    updates.each_pair do |key, value|
      if target[key].is_a?(Hash) && value.is_a?(Hash)
        deep_merge!(target[key], value)
      else
        target[key] = value
      end
    end
  end
  def system!(*args)
    ok = system(*args)
    return if ok
    raise "command failed: #{args.join(' ')}"
  end
end
