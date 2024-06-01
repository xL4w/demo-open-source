#!/bin/bash

# Test Case 07: PR Creation by @GTCrais (Reviewers Added)

# Set GitHub environment variables
export GH_TOKEN="${{ secrets.GH_TOKEN }}" # Use the repository's secret token for authentication
export GITHUB_REPOSITORY="${{ github.repository }}" # Get the repository name from GitHub context
export PR_CREATOR="GTCrais"                       # Set the PR creator as @GTCrais
export EXPECTED_REVIEWERS="GTCrais,CTLLaw" # The reviewers we expect to see

# Source the workflow file
source ../enforce-branch-sequence.yml


# Helper function to create a pull request via the GitHub API
create_pull_request() {
  local base_ref="$1"
  local head_ref="$2"

  pr_url=$(curl -s -X POST -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"title\":\"Test PR\",\"head\":\"$head_ref\",\"base\":\"$base_ref\"}" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls" | jq -r '.url')

  if [ -z "$pr_url" ]; then
    echo "❌ FAIL: Could not create pull request."
    exit 1
  fi

  echo "$pr_url"
}

# Helper function to get reviewers for a pull request
get_pull_request_reviewers() {
  local pr_url="$1"

  reviewers=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "$pr_url/requested_reviewers" | jq -r '.users[].login' | tr '\n' ',' | sed 's/,$//')
  
  echo "$reviewers"
}

# Create a pull request (choose appropriate branches based on your test)
pr_url=$(create_pull_request "aws-dev" "feature/new-feature-by-gtcrais")  # Modify base/head as needed
echo "Created PR: $pr_url"

# Get the reviewers assigned to the created pull request
assigned_reviewers=$(get_pull_request_reviewers "$pr_url")
echo "Assigned reviewers: $assigned_reviewers"

# Verify if the expected reviewers are present
if [[ "$assigned_reviewers" == "$EXPECTED_REVIEWERS" ]]; then
  echo "✅ PASS: Correct reviewers (@GTCrais and @CTLLaw) were added to the PR."
else
  echo "❌ FAIL: Incorrect reviewers were added. Expected: $EXPECTED_REVIEWERS, Actual: $assigned_reviewers"
  exit 1
fi
