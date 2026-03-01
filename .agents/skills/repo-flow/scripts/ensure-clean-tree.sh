#!/usr/bin/env bash
set -euo pipefail

if [[ -n "$(git status --short)" ]]; then
  echo "error: working tree is not clean" >&2
  git status --short
  exit 1
fi
