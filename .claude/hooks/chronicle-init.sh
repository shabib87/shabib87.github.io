#!/usr/bin/env bash
# SessionStart hook: initialize session chronicle file.
# Registered in .claude/settings.json under hooks.SessionStart.
# Matcher: startup|resume|compact|clear
# Fail-closed: exit 2 on error (block execution), never fail-open.
set -euo pipefail
trap 'exit 2' ERR

# --- Read input from stdin ---
input="$(cat)"
session_id="$(echo "$input" | jq -r '.session_id // empty')"
source_event="$(echo "$input" | jq -r '.source // empty')"

if [[ -z "$session_id" ]]; then
  echo "error: no session_id in SessionStart input" >&2
  exit 2
fi

# --- Derive chronicle file path ---
project_dir_name="${PWD//\//-}"
chronicle_dir="$HOME/.claude/projects/$project_dir_name/chronicle"
mkdir -p "$chronicle_dir"

today="$(date +%Y-%m-%d)"
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")"
branch_slug="$(echo "$branch" | tr '/' '-')"
base_name="${today}-${branch_slug}"
chronicle_file="$chronicle_dir/${base_name}.md"

# --- Determine reuse vs create ---
if [[ -f "$chronicle_file" ]]; then
  if [[ "$source_event" == "resume" || "$source_event" == "compact" ]]; then
    # Always reuse on resume/compact — same session continuing
    :
  else
    # startup or clear — compare session_id to detect new session
    existing_id="$(sed -n 's/^session_id: *//p' "$chronicle_file" | head -1)"
    if [[ "$existing_id" != "$session_id" ]]; then
      # Different session same day same branch — suffix the filename
      suffix=2
      while [[ -f "$chronicle_dir/${base_name}-${suffix}.md" ]]; do
        suffix=$((suffix + 1))
      done
      chronicle_file="$chronicle_dir/${base_name}-${suffix}.md"
    fi
  fi
fi

# --- Create new chronicle file if needed ---
if [[ ! -f "$chronicle_file" ]]; then
  task=""
  if [[ "$branch" =~ cws/([0-9]+) ]]; then
    task="CWS-${BASH_REMATCH[1]}"
  fi

  cat > "$chronicle_file" <<FRONTMATTER
---
session_id: ${session_id}
date: ${today}
branch: ${branch}
task: ${task}
started: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---

## Events

## Summary
FRONTMATTER
fi

# --- Export path for Claude's in-session use ---
if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
  echo "CHRONICLE_PATH=$chronicle_file" >> "$CLAUDE_ENV_FILE"
fi

# --- Output context injection ---
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Session chronicle active at ${chronicle_file}.\nLog notable events: [DECISION], [ERROR], [PIVOT], [INSIGHT], [MEMORY-HIT], [MEMORY-MISS], [USER-CORRECTION], [BLOCKED].\nWrite a ## Summary before ending substantive sessions.\nDo NOT log routine actions — only decisions, failures, surprises, and corrections."
  }
}
EOF
