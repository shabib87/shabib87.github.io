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

# _gh_available — returns 0 if gh CLI is installed AND authenticated.
# Result is cached for the lifetime of the sourcing shell to avoid
# repeated network calls to gh auth status.
_GH_AVAILABLE=""
_gh_available() {
  if [[ -z "$_GH_AVAILABLE" ]]; then
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
      _GH_AVAILABLE="yes"
    else
      _GH_AVAILABLE="no"
    fi
  fi
  [[ "$_GH_AVAILABLE" == "yes" ]]
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
# method: POST, PATCH, PUT, DELETE
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
# Internal helpers
# ---------------------------------------------------------------------------

# _resolve_pr_number <ref> <token> <repo_slug>
# If ref is numeric, pass through. Otherwise, resolve branch name to PR number.
_resolve_pr_number() {
  local ref="$1" token="$2" repo_slug="$3"
  if [[ "$ref" =~ ^[0-9]+$ ]]; then
    printf '%s' "$ref"
    return 0
  fi
  curl -fsSL \
    -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${repo_slug}/pulls?head=${repo_slug%%/*}:${ref}&state=all" |
    ruby -rjson -e 'data=JSON.parse(STDIN.read); puts data.first["number"] rescue exit(1)'
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
  pr_number="$(_resolve_pr_number "$ref" "$token" "$repo_slug")"

  # Fetch PR data
  local pr_json head_sha checks_json
  pr_json="$(curl -fsSL \
    -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${repo_slug}/pulls/${pr_number}")"

  # Fetch check runs for the head commit to populate statusCheckRollup
  head_sha="$(printf '%s' "$pr_json" | ruby -rjson -e 'puts JSON.parse(STDIN.read).dig("head","sha")')"
  checks_json="$(curl -fsSL \
    -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${repo_slug}/commits/${head_sha}/check-runs" 2>/dev/null || echo '{"check_runs":[]}')"

  # Normalize REST API response to match gh --json field names
  # shellcheck disable=SC2016
  printf '%s\0%s' "$pr_json" "$checks_json" |
    ruby -rjson -e '
      parts = STDIN.read.split("\0", 2)
      pr = JSON.parse(parts[0])
      checks_data = JSON.parse(parts[1]) rescue {"check_runs" => []}
      check_runs = (checks_data["check_runs"] || []).map do |cr|
        {"name" => cr["name"], "conclusion" => (cr["conclusion"] || "").upcase}
      end
      normalized = {
        "number"            => pr["number"],
        "state"             => pr["state"],
        "url"               => pr["html_url"],
        "headRefName"       => pr.dig("head", "ref"),
        "baseRefName"       => pr.dig("base", "ref"),
        "isDraft"           => pr["draft"],
        "statusCheckRollup" => check_runs,
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

# gh_or_curl_pr_edit <ref> <title> <body_file>
# ref: branch name or PR number
gh_or_curl_pr_edit() {
  local ref="$1"
  local title="$2"
  local body_file="$3"

  if _gh_available; then
    gh pr edit "$ref" --title "$title" --body-file "$body_file" 2>/dev/null && return 0
  fi

  local token repo_slug pr_number body_content json_payload
  token="$(_github_resolve_token)"
  repo_slug="$(_github_resolve_repo)"
  pr_number="$(_resolve_pr_number "$ref" "$token" "$repo_slug")"
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
    "https://api.github.com/repos/${repo_slug}/pulls/${pr_number}"
}

# gh_or_curl_pr_merge <ref> <method>
# ref: branch name or PR number; method: rebase, squash, merge
gh_or_curl_pr_merge() {
  local ref="$1"
  local method="$2"

  if _gh_available; then
    local flag
    case "$method" in
      rebase) flag="--rebase" ;;
      squash) flag="--squash" ;;
      merge)  flag="--merge"  ;;
      *)      flag="--rebase" ;;
    esac
    gh pr merge "$ref" $flag --delete-branch 2>/dev/null && return 0
  fi

  local token repo_slug pr_number head_ref merge_method json_payload
  token="$(_github_resolve_token)"
  repo_slug="$(_github_resolve_repo)"

  # Resolve PR number and head ref for branch cleanup
  if [[ "$ref" =~ ^[0-9]+$ ]]; then
    pr_number="$ref"
    head_ref="$(curl -fsSL \
      -H "Authorization: token ${token}" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/${repo_slug}/pulls/${pr_number}" |
      ruby -rjson -e 'puts JSON.parse(STDIN.read).dig("head","ref")')"
  else
    head_ref="$ref"
    pr_number="$(_resolve_pr_number "$ref" "$token" "$repo_slug")"
  fi

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
    "https://api.github.com/repos/${repo_slug}/pulls/${pr_number}/merge"

  # Delete remote branch (best-effort, matches --delete-branch in gh path)
  curl -fsSL \
    -X DELETE \
    -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${repo_slug}/git/refs/heads/${head_ref}" 2>/dev/null || true
}
