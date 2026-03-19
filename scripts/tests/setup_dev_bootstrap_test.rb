#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"

class SetupDevBootstrapTest < Minitest::Test
  SCRIPT_PATH = File.expand_path("../setup-dev.sh", __dir__)
  BREWFILE_PATH = File.expand_path("../../Brewfile", __dir__)

  def script_body
    @script_body ||= File.read(SCRIPT_PATH)
  end

  def brewfile
    @brewfile ||= File.read(BREWFILE_PATH)
  end

  def test_setup_bootstraps_rbenv_and_ruby_build_when_brew_is_available
    assert_match(/ensure_brew_package rbenv rbenv/, script_body)
    assert_match(/ensure_brew_package ruby-build ruby-build/, script_body)
    assert_match(/ensure_repo_ruby_with_rbenv/, script_body)
    assert_match(/install -s "\$required"/, script_body)
  end

  def test_brewfile_includes_required_bootstrap_tooling
    %w[gh python rbenv ruby-build semgrep vale cspell].each do |formula|
      assert_includes(brewfile, %(brew "#{formula}"))
    end
  end
end
