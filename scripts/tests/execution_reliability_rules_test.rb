#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class ExecutionReliabilityRulesTest < Minitest::Test
  RULES_PATH = File.expand_path("../../.codex/rules/execution-reliability.rules", __dir__)
  REQUIREMENTS_PATH = File.expand_path("../../.codex/requirements.toml", __dir__)
  REPO_FLOW_REF_PATH = File.expand_path("../../.agents/skills/repo-flow/references/branch-pr-merge.md", __dir__)

  def rules_body
    @rules_body ||= File.read(RULES_PATH)
  end

  def repo_flow_ref_body
    @repo_flow_ref_body ||= File.read(REPO_FLOW_REF_PATH)
  end

  def test_rules_file_exists_with_git_and_gt_write_command_prefix_rules
    assert(File.file?(RULES_PATH), "expected rules file at #{RULES_PATH}")
    assert_match(/prefix_rule\(\s*pattern=\["git", "status"\],\s*decision="allow"/, rules_body)
    assert_match(/prefix_rule\(\s*pattern=\["git", "diff"\],\s*decision="allow"/, rules_body)
    assert_match(/prefix_rule\(\s*pattern=\["git", "log"\],\s*decision="allow"/, rules_body)
    assert_match(/prefix_rule\(\s*pattern=\["rg"\],\s*decision="allow"/, rules_body)
    assert_match(/prefix_rule\(\s*pattern=\["gh", "pr", "view"\],\s*decision="allow"/, rules_body)
    assert_match(/prefix_rule\(\s*pattern=\["git", "checkout"\],\s*decision="prompt"/, rules_body)
    assert_match(/prefix_rule\(\s*pattern=\["git", "rebase"\],\s*decision="prompt"/, rules_body)
    assert_match(/prefix_rule\(\s*pattern=\["git", "commit"\],\s*decision="prompt"/, rules_body)
    assert_match(/prefix_rule\(\s*pattern=\["gt", "create"\],\s*decision="prompt"/, rules_body)
    assert_match(/prefix_rule\(\s*pattern=\["gt", "modify"\],\s*decision="prompt"/, rules_body)
    assert_match(/prefix_rule\(\s*pattern=\["gt", "submit"\],\s*decision="prompt"/, rules_body)
  end

  def test_requirements_file_enforces_mcp_allowlist_for_configured_servers
    assert(File.file?(REQUIREMENTS_PATH), "expected requirements file at #{REQUIREMENTS_PATH}")
    body = File.read(REQUIREMENTS_PATH)

    assert_match(/\[mcp_servers\.context7\.identity\]/, body)
    assert_match(/command = "npx"/, body)

    assert_match(/\[mcp_servers\.linear\.identity\]/, body)
    assert_match(%r{url = "https://mcp\.linear\.app/mcp"}, body)

    assert_match(/\[mcp_servers\.graphite\.identity\]/, body)
    assert_match(%r{command = "/opt/homebrew/bin/gt"}, body)
  end

  def test_repo_flow_reference_documents_index_lock_escalation_fallback
    assert_match(/\.git\/index\.lock/, repo_flow_ref_body)
    assert_match(/escalat/i, repo_flow_ref_body)
    assert_match(/use `gt modify --commit`/, repo_flow_ref_body)
    assert_match(/do not run `gt create`/, repo_flow_ref_body)
  end
end
