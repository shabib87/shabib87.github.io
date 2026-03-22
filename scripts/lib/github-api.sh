#!/usr/bin/env bash
set -euo pipefail

# Shared gh/curl fallback library for GitHub API operations.
# Source this file from scripts that need GitHub API access.
# The gh CLI is preferred; curl is used as a fallback for CI environments
# where gh is not installed.

# ---------------------------------------------------------------------------
# Token and repo resolution
# ---------------------------------------------------------------------------

# _github_resolve_token — print the GitHub token to stdout; exit 1 on failure
_github_resolve_token() {
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    printf '%s\n' "$GITHUB_TOKEN"
    return 0
  fi

  if command -v gh >/dev/null 2>&1; then
    local token
    token="$(gh auth token 2>/dev/null || true)"
    if [[ -n "$token" ]]; then
      printf '%s\n' "$token"
      return 0
    fi
  fi

  echo "error: no GitHub token available. Set GITHUB_TOKEN or run: gh auth login" >&2
  return 1
}

# _github_resolve_repo — print OWNER/REPO from git remote origin
_github_resolve_repo() {
  local remote_url
  remote_url="$(git remote get-url origin 2>/dev/null || true)"

  if [[ -z "$remote_url" ]]; then
    echo "error: git remote 'origin' is not configured" >&2
    return 1
  fi

  local slug
  # SSH: git@github.com:owner/repo.git
  if [[ "$remote_url" =~ ^git@[^:]+:(.+/[^/]+)(\.git)?$ ]]; then
    slug="${BASH_REMATCH[1]}"
    slug="${slug%.git}"
  # SSH protocol: ssh://git@github.com/owner/repo.git or ssh://git@github.com:22/owner/repo.git
  elif [[ "$remote_url" =~ ^ssh://git@[^/]+(:[0-9]+)?/(.+/[^/]+)(\.git)?$ ]]; then
    slug="${BASH_REMATCH[2]}"
    slug="${slug%.git}"
  # HTTPS: https://github.com/owner/repo.git
  elif [[ "$remote_url" =~ ^https?://[^/]+/(.+/[^/]+)(\.git)?$ ]]; then
    slug="${BASH_REMATCH[1]}"
    slug="${slug%.git}"
  else
    echo "error: cannot parse git remote URL: $remote_url" >&2
    return 1
  fi

  printf '%s\n' "$slug"
}

# _gh_available — returns 0 if gh CLI is installed AND authenticated
_gh_available() {
  command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# Core API wrappers
# ---------------------------------------------------------------------------

# github_api_get <endpoint>
# Performs a GET request. endpoint must start with /repos/... or similar.
github_api_get() {
  local endpoint="$1"

  if _gh_available; then
    gh api "$endpoint" 2>/dev/null && return 0
  fi

  local token
  token="$(_github_resolve_token)"
  curl -fsSL \
    -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com${endpoint}"
}

# github_api_post <method> <endpoint> <json_body>
# method: POST, PATCH, PUT
github_api_post() {
  local method="$1"
  local endpoint="$2"
  local json_body="$3"

  if _gh_available; then
    gh api --method "$method" "$endpoint" --input - <<<"$json_body" 2>/dev/null && return 0
  fi

  local token
  token="$(_github_resolve_token)"
  curl -fsSL \
    -X "$method" \
    -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github+json" \
    -H "Content-Type: application/json" \
    -d "$json_body" \
    "https://api.github.com${endpoint}"
}

# ---------------------------------------------------------------------------
# PR-specific helpers
# ---------------------------------------------------------------------------

# gh_or_curl_pr_view <ref>
# ref: branch name or PR number
# Returns JSON with fields: number, state, url, headRefName, baseRefName,
# isDraft, statusCheckRollup, mergedAt (normalized from REST API if using curl)
gh_or_curl_pr_view() {
  local ref="$1"

  if _gh_available; then
    gh pr view "$ref" --json number,state,url,headRefName,baseRefName,isDraft,statusCheckRollup,mergedAt 2>/dev/null && return 0
  fi

  local token repo_slug pr_number
  token="$(_github_resolve_token)"
  repo_slug="$(_github_resolve_repo)"

  # If ref looks like a number, use it directly; otherwise search by head branch
  if [[ "$ref" =~ ^[0-9]+$ ]]; then
    pr_number="$ref"
  else
    pr_number="$(curl -fsSL \
      -H "Authorization: token ${token}" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/${repo_slug}/pulls?head=${repo_slug%%/*}:${ref}&state=open" |
      ruby -rjson -e 'data=JSON.parse(STDIN.read); puts data.first["number"] rescue exit(1)')"
  fi

  # Normalize REST API response to match gh --json field names
  curl -fsSL \
    -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${repo_slug}/pulls/${pr_number}" |
    ruby -rjson -e '
      pr = JSON.parse(STDIN.read)
      normalized = {
        "number"            => pr["number"],
        "state"             => pr["state"],
        "url"               => pr["html_url"],
        "headRefName"       => pr.dig("head", "ref"),
        "baseRefName"       => pr.dig("base", "ref"),
        "isDraft"           => pr["draft"],
        "statusCheckRollup" => [],
        "mergedAt"          => pr["merged_at"]
      }
      puts JSON.generate(normalized)
    '
}

# gh_or_curl_pr_create <base> <head> <title> <body_file>
gh_or_curl_pr_create() {
  local base="$1"
  local head="$2"
  local title="$3"
  local body_file="$4"

  if _gh_available; then
    gh pr create \
      --base "$base" \
      --head "$head" \
      --title "$title" \
      --body-file "$body_file" 2>/dev/null && return 0
  fi

  local token repo_slug body_content json_payload
  token="$(_github_resolve_token)"
  repo_slug="$(_github_resolve_repo)"
  body_content="$(cat "$body_file")"

  json_payload="$(ruby -rjson -e '
    payload = {
      "title" => ARGV[0],
      "head"  => ARGV[1],
      "base"  => ARGV[2],
      "body"  => ARGV[3]
    }
    puts JSON.generate(payload)
  ' "$title" "$head" "$base" "$body_content")"

  curl -fsSL \
    -X POST \
    -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github+json" \
    -H "Content-Type: application/json" \
    -d "$json_payload" \
    "https://api.github.com/repos/${repo_slug}/pulls"
}

# gh_or_curl_pr_edit <pr> <title> <body_file>
# pr: PR number
gh_or_curl_pr_edit() {
  local pr="$1"
  local title="$2"
  local body_file="$3"

  if _gh_available; then
    gh pr edit "$pr" --title "$title" --body-file "$body_file" 2>/dev/null && return 0
  fi

  local token repo_slug body_content json_payload
  token="$(_github_resolve_token)"
  repo_slug="$(_github_resolve_repo)"
  body_content="$(cat "$body_file")"

  json_payload="$(ruby -rjson -e '
    payload = {
      "title" => ARGV[0],
      "body"  => ARGV[1]
    }
    puts JSON.generate(payload)
  ' "$title" "$body_content")"

  curl -fsSL \
    -X PATCH \
    -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github+json" \
    -H "Content-Type: application/json" \
    -d "$json_payload" \
    "https://api.github.com/repos/${repo_slug}/pulls/${pr}"
}

# gh_or_curl_pr_merge <pr> <method>
# pr: PR number; method: rebase, squash, merge
gh_or_curl_pr_merge() {
  local pr="$1"
  local method="$2"

  if _gh_available; then
    local flag
    case "$method" in
      rebase) flag="--rebase" ;;
      squash) flag="--squash" ;;
      merge)  flag="--merge"  ;;
      *)      flag="--rebase" ;;
    esac
    gh pr merge "$pr" $flag --delete-branch 2>/dev/null && return 0
  fi

  local token repo_slug merge_method json_payload
  token="$(_github_resolve_token)"
  repo_slug="$(_github_resolve_repo)"

  case "$method" in
    rebase) merge_method="rebase" ;;
    squash) merge_method="squash" ;;
    merge)  merge_method="merge"  ;;
    *)      merge_method="rebase" ;;
  esac

  json_payload="$(ruby -rjson -e '
    puts JSON.generate({"merge_method" => ARGV[0]})
  ' "$merge_method")"

  curl -fsSL \
    -X PUT \
    -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github+json" \
    -H "Content-Type: application/json" \
    -d "$json_payload" \
    "https://api.github.com/repos/${repo_slug}/pulls/${pr}/merge"
}
