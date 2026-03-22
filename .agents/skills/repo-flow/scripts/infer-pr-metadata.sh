#!/usr/bin/env bash
set -euo pipefail

type="${1:-chore}"
branch="$(git branch --show-current)"
subject="${branch#cws/}"
if [[ "$subject" =~ ^([0-9]+)-(.*)$ ]]; then
  issue_id="${BASH_REMATCH[1]}"
  tail_subject="${BASH_REMATCH[2]}"
  tail_subject="$(printf '%s' "$tail_subject" | tr '-' ' ')"
  printf 'TITLE=%s(CWS-%s): %s\n' "$type" "$issue_id" "$tail_subject"
  exit 0
fi

subject="${subject#"${type}"-}"
subject="$(printf '%s' "$subject" | tr '-' ' ')"

printf 'TITLE=%s: %s\n' "$type" "$subject"
