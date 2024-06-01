#!/bin/bash

# Test Case 08: PR Creation by @CTLLaw (Reviewers Added)

# Set GitHub environment variables
export GH_TOKEN="${{ secrets.GH_TOKEN }}" # Use the repository's secret token for authentication
export GITHUB_REPOSITORY="${{ github.repository }}" # Get the repository name from GitHub context
export PR_CREATOR="CTLLaw"                       # Set the PR creator as @CTLLaw
export EXPECTED_REVIEWERS="GTCrais,CTLLaw" # The reviewers we expect to see

# Source the workflow file
source ../enforce-branch-sequence.yml


# Helper function to create a pull request via the GitHub API (Same as in 07-pr-creation-gtcrais.sh)
create_pull_request() {
  # ... (copy the function from 07-pr-creation-gtcrais.sh)
}

# Helper function to get reviewers for a pull request (Same as in 07-pr-creation-gtcrais.sh)
get_pull_request_reviewers() {
  # ... (copy the function from 07-pr-creation-gtcrais.sh)
}

# Create a pull request (choose appropriate branches based on your test)
pr_url=$(create_pull_request "aws-dev" "feature/new-feature-by-ctllaw")  # Modify base/head as needed
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
