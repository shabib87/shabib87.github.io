#!/usr/bin/env ruby
# frozen_string_literal: true

coverage_output = ENV["PUBLISH_DRAFT_COVERAGE"].to_s
unless coverage_output.empty?
  require "coverage"
  Coverage.start(lines: true)
  at_exit do
    begin
      File.binwrite(coverage_output, Marshal.dump(Coverage.result))
    rescue StandardError
      # Coverage emission should never mask command exit behavior.
    end
  end
end

require_relative "publish_draft_core"

PublishDraft.run(ARGV)
