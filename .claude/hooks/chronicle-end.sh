#!/usr/bin/env bash
# SessionEnd hook: append machine-generated summary if Claude forgot.
# Fire-and-forget — must complete quickly (<1.5s default timeout).
# Fail-closed: exit 2 on error, never fail-open.
set -euo pipefail
trap 'exit 2' ERR

# --- Derive path independently (CLAUDE_ENV_FILE not available in SessionEnd) ---
project_dir_name="${PWD//\//-}"
chronicle_dir="$HOME/.claude/projects/$project_dir_name/chronicle"

if [[ ! -d "$chronicle_dir" ]]; then
  exit 0
fi

today="$(date +%Y-%m-%d)"
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")"
branch_slug="$(echo "$branch" | tr '/' '-')"

# Find today's chronicle file for this branch (most recently modified)
# Match exact slug or slug-N suffix to avoid cross-branch collision
# (e.g., "cws-96" must not match "cws-96-session-chronicle")
chronicle_file=""
for f in "$chronicle_dir/${today}-${branch_slug}.md" "$chronicle_dir/${today}-${branch_slug}-"[0-9]*.md; do
  [[ -f "$f" ]] || continue
  if [[ -z "$chronicle_file" || "$f" -nt "$chronicle_file" ]]; then
    chronicle_file="$f"
  fi
done

if [[ -z "$chronicle_file" ]]; then
  exit 0
fi

# Check if there are any events worth summarizing
# Pattern matches both "- [TAG]" and "- HH:MM [TAG]" (timestamped events)
event_count="$(grep -c '^- .*\[' "$chronicle_file" 2>/dev/null || echo "0")"
if [[ "$event_count" -eq 0 ]]; then
  exit 0
fi

# Check if summary already has content (any non-blank line after ## Summary)
has_summary=false
in_summary=false
while IFS= read -r line; do
  if [[ "$line" == "## Summary" ]]; then
    in_summary=true
    continue
  fi
  if $in_summary && [[ ! "$line" =~ ^[[:space:]]*$ ]]; then
    has_summary=true
    break
  fi
done < "$chronicle_file"

if $has_summary; then
  exit 0
fi

# --- Count events by category ---
decisions="$(grep -c '^\- .*\[DECISION\]' "$chronicle_file" 2>/dev/null || echo "0")"
errors="$(grep -c '^\- .*\[ERROR\]' "$chronicle_file" 2>/dev/null || echo "0")"
pivots="$(grep -c '^\- .*\[PIVOT\]' "$chronicle_file" 2>/dev/null || echo "0")"
insights="$(grep -c '^\- .*\[INSIGHT\]' "$chronicle_file" 2>/dev/null || echo "0")"
mem_hits="$(grep -c '^\- .*\[MEMORY-HIT\]' "$chronicle_file" 2>/dev/null || echo "0")"
mem_misses="$(grep -c '^\- .*\[MEMORY-MISS\]' "$chronicle_file" 2>/dev/null || echo "0")"
corrections="$(grep -c '^\- .*\[USER-CORRECTION\]' "$chronicle_file" 2>/dev/null || echo "0")"
blocked="$(grep -c '^\- .*\[BLOCKED\]' "$chronicle_file" 2>/dev/null || echo "0")"

# --- Build summary ---
parts=()
[[ "$decisions" -gt 0 ]] && parts+=("${decisions} decision(s)")
[[ "$errors" -gt 0 ]] && parts+=("${errors} error(s)")
[[ "$pivots" -gt 0 ]] && parts+=("${pivots} pivot(s)")
[[ "$insights" -gt 0 ]] && parts+=("${insights} insight(s)")
[[ "$mem_hits" -gt 0 ]] && parts+=("${mem_hits} memory hit(s)")
[[ "$mem_misses" -gt 0 ]] && parts+=("${mem_misses} memory miss(es)")
[[ "$corrections" -gt 0 ]] && parts+=("${corrections} correction(s)")
[[ "$blocked" -gt 0 ]] && parts+=("${blocked} blocked")

summary_line="Auto-generated: ${event_count} events"
if [[ ${#parts[@]} -gt 0 ]]; then
  detail="${parts[0]}"
  for part in "${parts[@]:1}"; do
    detail="${detail}, ${part}"
  done
  summary_line="${summary_line} (${detail})"
fi

# Append to file (## Summary is the last section, so appending to file = appending to summary)
printf '\n%s\n' "$summary_line" >> "$chronicle_file"
