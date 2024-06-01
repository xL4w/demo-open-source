#!/bin/bash

# ==============================================================================
# Common Helper Functions for GitHub Actions Workflow Testing
# ==============================================================================

# Function to create a pull request via the GitHub API
create_pull_request() {
  local base_ref="$1"
  local head_ref="$2"
  local title="$3"  # Added title parameter

  pr_url=$(curl -s -X POST -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"title\":\"$title\",\"head\":\"$head_ref\",\"base\":\"$base_ref\"}" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls" | jq -r '.url')

  if [ -z "$pr_url" ]; then
    echo "❌ FAIL: Could not create pull request."
    exit 1
  fi

  echo "$pr_url"
}

# Function to get reviewers for a pull request
get_pull_request_reviewers() {
  local pr_url="$1"

  reviewers=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "$pr_url/requested_reviewers" | jq -r '.users[].login' | tr '\n' ',' | sed 's/,$//')
  
  echo "$reviewers"
}

# Function to add a reviewer to a pull request
add_reviewer() {
  local pr_url="$1"
  local reviewer="$2"

  response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"reviewers\":[\"$reviewer\"]}" \
    "$pr_url/requested_reviewers")

  echo "$response"
}
