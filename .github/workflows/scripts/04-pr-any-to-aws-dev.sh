#!/bin/bash

set -e  # Exit immediately if a command fails

# Test Case 04: PR from Any Branch to aws-dev (Allowed)

# Source common helper functions
source ./.github/workflows/scripts/common_functions.sh

# Mock GitHub environment variables for a PR from a feature branch to aws-dev
export GITHUB_REF=refs/heads/feature/my-new-feature
export GITHUB_BASE_REF=refs/heads/aws-dev
export GITHUB_EVENT_NAME=pull_request

# Adjust PR creator and expected reviewers based on the type of PR (Application or Infrastructure)
export PR_CREATOR="4k4xs4pH1r3"  
# Set PR body to indicate it's an application change (adjust for infrastructure if needed)
export PR_BODY="This PR is related to Applications changes."

# Source the main workflow logic
source ../enforce-branch-sequence.yml 

# Run the workflow's logic and capture output
output=$(run)

# Check for the expected success message
expected_output="Success: The branch sequence is valid."
if echo "$output" | grep -q "$expected_output"; then
  echo "✅ PASS: PR from feature/my-new-feature to aws-dev allowed."

  # Fetch PR details to check reviewers
  pr_number=$(echo "$output" | grep -oP 'Pull Request number: \K\d+')  
  reviewers=$(gh pr view $pr_number --json requestedReviewers | jq -r '.requestedReviewers[].login')

  # Determine the expected reviewers based on PR type
  if echo "$PR_BODY" | grep -q "Applications"; then
    expected_reviewers="GTCrais"
  else
    expected_reviewers="mbsimonovic"
  fi

  # Verify that the correct reviewers are assigned
  if echo "$reviewers" | grep -q "$expected_reviewers"; then
    echo "✅ PASS: Correct reviewer(s) ($expected_reviewers) assigned to PR."
  else
    echo "❌ FAIL: Incorrect reviewers assigned to PR. Actual reviewers: $reviewers"
    exit 1
  fi
else
  echo "❌ FAIL: PR from feature/my-new-feature to aws-dev was not allowed."
  echo "Unexpected output:"
  echo "$output"
  exit 1  
fi
