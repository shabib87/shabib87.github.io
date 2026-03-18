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
    assert_match(/gt track --parent "\$base_branch"/, script_body)
    assert_match(/gt submit --stack --no-interactive/, script_body)
  end

  def test_normalizes_pr_metadata_with_gh_after_submit
    assert_match(/gh pr edit "\$branch" --title "\$title" --body-file "\$body_file"/, script_body)
    assert_match(/gh pr ready "\$branch"/, script_body)
  end

  def test_falls_back_to_gh_pr_create_when_branch_has_no_pr
    assert_match(/if ! gh pr view "\$branch" >/i, script_body)
    assert_match(/gh pr create \\/, script_body)
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

  def test_hard_fails_when_agent_context_is_missing_or_stale
    assert_match(/missing docs\/agent-context\.md/, script_body)
    assert_match(/docs\/agent-context\.md is stale/, script_body)
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
end
