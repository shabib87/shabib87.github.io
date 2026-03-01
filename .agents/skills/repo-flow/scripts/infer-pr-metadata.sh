#!/usr/bin/env bash
set -euo pipefail

type="${1:-chore}"
branch="$(git branch --show-current)"
subject="${branch#codex/}"
subject="${subject#"${type}"-}"
subject="$(printf '%s' "$subject" | tr '-' ' ')"

printf 'TITLE=%s: %s\n' "$type" "$subject"
