#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class CiSetupWorkflowTest < Minitest::Test
  MAKEFILE_PATH = File.expand_path("../../Makefile", __dir__)
  JEKYLL_WORKFLOW_PATH = File.expand_path("../../.github/workflows/jekyll-build.yml", __dir__)
  SEMGREP_WORKFLOW_PATH = File.expand_path("../../.github/workflows/semgrep.yml", __dir__)
  ROLLOUT_WORKFLOW_PATH = File.expand_path("../../.github/workflows/rollout-governance.yml", __dir__)

  def makefile
    @makefile ||= File.read(MAKEFILE_PATH)
  end

  def workflow(path)
    File.read(path)
  end

  def test_makefile_exposes_ci_setup_target
    assert_match(/^ci-setup:\s*$/m, makefile)
    assert_match(/@\.\/scripts\/setup-ci\.sh/, makefile)
  end

  def test_makefile_phony_list_includes_ci_setup
    phony_line = makefile.lines.find { |line| line.start_with?(".PHONY:") }
    refute_nil(phony_line)
    assert_includes(phony_line, "ci-setup")
  end

  def test_jekyll_build_workflow_calls_make_ci_setup
    assert_match(/make ci-setup/, workflow(JEKYLL_WORKFLOW_PATH))
  end

  def test_semgrep_workflow_calls_make_ci_setup
    assert_match(/make ci-setup/, workflow(SEMGREP_WORKFLOW_PATH))
  end

  def test_rollout_governance_workflow_calls_make_ci_setup
    assert_match(/make ci-setup/, workflow(ROLLOUT_WORKFLOW_PATH))
  end
end
