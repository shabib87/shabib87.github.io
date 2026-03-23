#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class CreatePrWorkflowTest < Minitest::Test
  SCRIPT_PATH = File.expand_path("../create-pr.sh", __dir__)

  def script_body
    @script_body ||= File.read(SCRIPT_PATH)
  end

  def test_prefers_graphite_submit_when_available
    assert_match(/if command -v gt >/i, script_body)
    assert_match(/gt submit --stack --no-interactive --publish/, script_body)
  end

  def test_recovers_when_gt_submit_reports_untracked_branch
    assert_match(/if grep -q "untracked branch" "\$gt_log_file"; then/, script_body)
    assert_match(/gt track --parent "\$base_branch" >>"\$gt_log_file" 2>&1/, script_body)
    assert_match(/gt submit --stack --no-interactive --publish >>"\$gt_log_file" 2>&1/, script_body)
  end

  def test_uses_graphite_publish_mode_for_non_interactive_submit
    assert_match(/gt submit --stack --no-interactive --publish/, script_body)
  end

  def test_normalizes_pr_metadata_after_submit
    assert_match(/gh_or_curl_pr_edit "\$branch" "\$title" "\$body_file"/, script_body)
    assert_match(/gh pr ready "\$branch"/, script_body)
  end

  def test_falls_back_to_pr_create_when_branch_has_no_pr
    assert_match(/if ! gh_or_curl_pr_view "\$branch" >/i, script_body)
    assert_match(/gh_or_curl_pr_create "\$base_branch" "\$branch" "\$title" "\$body_file"/, script_body)
  end

  def test_no_hard_failure_when_pr_already_exists
    refute_match(/error: a PR already exists for branch/, script_body)
  end

  def test_graphite_submit_failure_falls_back_to_gh_flow
    assert_match(/warning: gt submit failed; falling back to gh PR flow/, script_body)
    refute_match(/error: gt submit failed/, script_body)
  end

  def test_graphite_restack_failure_falls_back_to_gh_flow
    assert_match(/if ! gt restack >>"\$gt_log_file" 2>&1; then/, script_body)
    assert_match(/warning: gt restack failed; falling back to gh PR flow/, script_body)
  end

  def test_graphite_restack_failure_logs_context
    assert_match(/if ! gt restack >>"\$gt_log_file" 2>&1; then/, script_body)
    assert_match(/cat "\$gt_log_file" >&2/, script_body)
  end

  def test_hard_fails_when_agent_context_is_missing
    assert_match(/missing docs\/agent-context\.md/, script_body)
  end

  def test_warns_but_does_not_block_when_agent_context_is_stale
    assert_match(/WARNING:.*docs\/agent-context\.md is stale/, script_body)
    refute_match(/exit 1.*# stale/i, script_body)
  end

  def test_hard_fails_when_task_file_missing_for_task_branch
    assert_match(/missing required task file: docs\/tasks\/\$\{issue_id\}\.md/, script_body)
  end

  def test_task_file_status_text_is_not_a_gate
    refute_match(/task file status/i, script_body)
    refute_match(/Completion Evidence/, script_body)
  end

  def test_hard_fails_when_inferred_title_missing_issue_id
    assert_match(/inferred PR title must include \$\{issue_id\} for traceability/, script_body)
  end

  def test_pr_body_includes_linear_traceability_link
    assert_match(/## Linear Traceability/, script_body)
    assert_match(/linear_issue_link/, script_body)
  end

  def test_sources_github_api_library
    assert_match(%r{scripts/lib/github-api\.sh}, script_body)
  end

  def test_uses_fallback_auth_check
    assert_match(/_gh_available/, script_body)
    assert_match(/_github_resolve_token/, script_body)
  end
end
