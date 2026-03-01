#!/usr/bin/env bash
set -euo pipefail

type="${1:-chore}"
topic="${2:-}"

if [[ -z "$topic" ]]; then
  echo "usage: $0 <type> <topic>" >&2
  exit 1
fi

slug="$(printf '%s' "$topic" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')"

if [[ -z "$slug" ]]; then
  echo "error: topic produced an empty branch slug" >&2
  exit 1
fi

printf 'codex/%s-%s\n' "$type" "$slug"
