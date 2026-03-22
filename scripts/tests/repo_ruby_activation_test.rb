#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class RepoRubyActivationTest < Minitest::Test
  TOOLING_PATH = File.expand_path("../lib/tooling.sh", __dir__)
  WORKFLOW_CHECK_PATH = File.expand_path("../run-workflow-checks.sh", __dir__)
  CHECK_PATH = File.expand_path("../run-checks.sh", __dir__)

  def tooling_body
    @tooling_body ||= File.read(TOOLING_PATH)
  end

  def workflow_check_body
    @workflow_check_body ||= File.read(WORKFLOW_CHECK_PATH)
  end

  def check_body
    @check_body ||= File.read(CHECK_PATH)
  end

  def test_tooling_exposes_repo_ruby_activation_helper
    assert_match(/activate_repo_ruby\(\)/, tooling_body)
    assert_match(/export PATH="\$RBENV_ROOT\/shims:\$RBENV_ROOT\/bin:\$PATH"/, tooling_body)
    assert_match(/export RBENV_VERSION="\$required"/, tooling_body)
  end

  def test_workflow_checks_activates_and_requires_repo_ruby
    assert_match(/activate_repo_ruby/, workflow_check_body)
    assert_match(/require_repo_ruby \|\| exit 1/, workflow_check_body)
  end

  def test_run_checks_activates_and_requires_repo_ruby
    assert_match(/activate_repo_ruby/, check_body)
    assert_match(/require_repo_ruby \|\| exit 1/, check_body)
  end
end
