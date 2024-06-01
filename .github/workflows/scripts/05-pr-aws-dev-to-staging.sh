#!/bin/bash

set -e  # Exit immediately if a command fails

# Test Case 05: PR from aws-dev to staging (Allowed)

# Source common helper functions
source ./.github/workflows/scripts/common_functions.sh

# Mock GitHub environment variables
export GITHUB_REF=refs/heads/aws-dev
export GITHUB_BASE_REF=refs/heads/staging
export GITHUB_EVENT_NAME=pull_request

# Set PR creator 
export PR_CREATOR="4k4xs4pH1r3"  

# Set PR body to indicate it's an application change (adjust if testing infrastructure)
export PR_BODY="This PR is related to Applications changes."

# Source the main workflow logic
source ../enforce-branch-sequence.yml 

# Run the workflow's logic and capture output
output=$(run)

# Check for the expected success message
expected_output="Success: The branch sequence is valid."
if echo "$output" | grep -q "$expected_output"; then
  echo "✅ PASS: PR from aws-dev to staging allowed."

  # Fetch PR details to check reviewers 
  pr_number=$(echo "$output" | grep -oP 'Pull Request number: \K\d+')  
  reviewers=$(gh pr view $pr_number --json requestedReviewers | jq -r '.requestedReviewers[].login')

  # Determine the expected reviewer based on PR type
  if echo "$PR_BODY" | grep -q "Applications"; then
    expected_reviewer="GTCrais"
  else
    expected_reviewer="mbsimonovic"
  fi

  # Verify that the correct reviewer is assigned
  if echo "$reviewers" | grep -q "$expected_reviewer"; then
    echo "✅ PASS: Correct reviewer ($expected_reviewer) assigned to PR."
  else
    echo "❌ FAIL: Incorrect reviewers assigned to PR. Actual reviewers: $reviewers"
    exit 1
  fi
else
  echo "❌ FAIL: PR from aws-dev to staging was not allowed."
  echo "Unexpected output:"
  echo "$output"
  exit 1  # Indicate failure to GitHub Actions
fi
