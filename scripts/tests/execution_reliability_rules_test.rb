#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class ExecutionReliabilityRulesTest < Minitest::Test
  RULES_PATH = File.expand_path("../../.codex/rules/execution-reliability.rules", __dir__)
  REPO_FLOW_REF_PATH = File.expand_path("../../.agents/skills/repo-flow/references/branch-pr-merge.md", __dir__)

  def rules_body
    @rules_body ||= File.read(RULES_PATH)
  end

  def repo_flow_ref_body
    @repo_flow_ref_body ||= File.read(REPO_FLOW_REF_PATH)
  end

  def test_rules_file_exists_with_git_and_gt_write_command_prefix_rules
    assert(File.file?(RULES_PATH), "expected rules file at #{RULES_PATH}")
    assert_match(/pattern = \["git", "checkout"\]/, rules_body)
    assert_match(/pattern = \["git", "rebase"\]/, rules_body)
    assert_match(/pattern = \["git", "commit"\]/, rules_body)
    assert_match(/pattern = \["gt", "create"\]/, rules_body)
    assert_match(/pattern = \["gt", "modify"\]/, rules_body)
    assert_match(/pattern = \["gt", "submit"\]/, rules_body)
    assert_match(/decision = "prompt"/, rules_body)
  end

  def test_repo_flow_reference_documents_index_lock_escalation_fallback
    assert_match(/\.git\/index\.lock/, repo_flow_ref_body)
    assert_match(/escalat/i, repo_flow_ref_body)
  end
end
