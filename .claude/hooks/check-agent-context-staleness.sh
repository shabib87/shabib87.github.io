#!/usr/bin/env bash
# SessionStart hook: warn if docs/agent-context.md is stale.
# Registered in .claude/settings.json under hooks.SessionStart.
# Fail-closed: exit 2 on error (block execution), never fail-open.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
agent_context="$repo_root/docs/agent-context.md"

if [[ ! -f "$agent_context" ]]; then
  echo "error: docs/agent-context.md not found" >&2
  exit 2
fi

# Extract the stale-after timestamp from the "## Stale After" section.
# shellcheck disable=SC2016
stale_ts="$(ruby -e '
  content = File.read(ARGV[0])
  section = content.match(/^## Stale After\s*$\n+((?:- .*\n)+)/m)
  if section.nil?
    warn "error: cannot find Stale After section in agent-context.md"
    exit 2
  end
  ts_line = section[1].lines.find { |l| l.match?(/^\s*-\s*`[^`]+`\s*$/) }
  if ts_line.nil?
    warn "error: cannot find timestamp in Stale After section"
    exit 2
  end
  puts ts_line[/`([^`]+)`/, 1]
' "$agent_context" 2>&1)" || exit 2

if [[ -z "$stale_ts" ]]; then
  echo "error: empty stale timestamp in agent-context.md" >&2
  exit 2
fi

# Compare timestamps
# shellcheck disable=SC2016
is_stale="$(ruby -e '
  require "time"
  ts = Time.parse(ARGV[0]) rescue nil
  if ts.nil?
    warn "error: cannot parse timestamp: #{ARGV[0]}"
    exit 2
  end
  puts Time.now > ts ? "stale" : "fresh"
' "$stale_ts" 2>&1)" || exit 2

if [[ "$is_stale" == "stale" ]]; then
  cat <<EOF
WARNING: docs/agent-context.md is STALE (stale_after=$stale_ts).
Run a Linear sync before executing tasks. The cached context may not reflect
current issue states, priorities, or cycle assignments.
EOF
fi
