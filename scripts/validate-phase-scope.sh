#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

phase="${PHASE:-}"
if [[ -z "$phase" ]]; then
  branch="$(git branch --show-current 2>/dev/null || true)"
  if [[ "$branch" =~ ^codex/phase-([0-9]+)(-|$) ]]; then
    phase="${BASH_REMATCH[1]}"
  fi
fi

if [[ -z "$phase" ]]; then
  echo "phase scope check skipped (no PHASE and non-phase branch)"
  exit 0
fi

if ! [[ "$phase" =~ ^[0-9]+$ ]]; then
  echo "error: invalid phase value '$phase'" >&2
  exit 1
fi

patterns=()
for i in $(seq 1 "$phase"); do
  manifest=".codex/rollout/phases/phase-${i}.txt"
  if [[ ! -f "$manifest" ]]; then
    echo "error: missing phase manifest $manifest" >&2
    exit 1
  fi

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    [[ "$line" =~ ^# ]] && continue
    patterns+=("$line")
  done < "$manifest"
done

if [[ "${#patterns[@]}" -eq 0 ]]; then
  echo "error: no phase patterns loaded for phases 1..$phase" >&2
  exit 1
fi

common_ancestor="$(git merge-base main HEAD 2>/dev/null || true)"
committed_changed=""
if [[ -n "$common_ancestor" ]]; then
  committed_changed="$(git diff --name-only --diff-filter=ACMRD "$common_ancestor"...HEAD || true)"
fi
working_changed="$(git diff --name-only --diff-filter=ACMRD || true)"
staged_changed="$(git diff --name-only --cached --diff-filter=ACMRD || true)"
untracked_changed="$(git ls-files --others --exclude-standard || true)"

changed_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  changed_files+=("$file")
done < <(printf '%s\n%s\n%s\n%s\n' "$committed_changed" "$working_changed" "$staged_changed" "$untracked_changed" | awk 'NF' | sort -u)

if [[ "${#changed_files[@]}" -eq 0 ]]; then
  echo "phase scope check passed (no changed files)"
  exit 0
fi

errors=()
for file in "${changed_files[@]}"; do
  allowed=false
  for pattern in "${patterns[@]}"; do
    # shellcheck disable=SC2254
    case "$file" in
      $pattern)
        allowed=true
        break
        ;;
    esac
  done
  if [[ "$allowed" != true ]]; then
    errors+=("$file")
  fi
done

if [[ "${#errors[@]}" -gt 0 ]]; then
  echo "error: files outside cumulative phase-1..phase-${phase} scope:" >&2
  for file in "${errors[@]}"; do
    echo "  - $file" >&2
  done
  exit 1
fi

echo "phase scope check passed for cumulative phase-1..phase-${phase}"
