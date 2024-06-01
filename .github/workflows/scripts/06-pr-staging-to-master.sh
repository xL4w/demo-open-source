#!/bin/bash
set -e  # Exit immediately if a command fails

# Test Case 06: PR from staging to master (Allowed)

# Source common helper functions
source ./common_functions.sh

# Mock GitHub environment variables
export GITHUB_REF=refs/heads/staging
export GITHUB_BASE_REF=refs/heads/master
export GITHUB_EVENT_NAME=pull_request

# Adjust PR creator and expected reviewers based on the type of PR 
# Set to the appropriate user
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
  echo "✅ PASS: PR from staging to master allowed."

  # Fetch PR details to check reviewers 
  pr_number=$(echo "$output" | grep -oP 'Pull Request number: \K\d+')  
  reviewers=$(gh pr view $pr_number --json requestedReviewers | jq -r '.requestedReviewers[].login')

  # Determine the expected reviewers based on PR type
  if echo "$PR_BODY" | grep -q "Applications"; then
    expected_reviewers="GTCrais,CTLLaw" 
  else
    expected_reviewers="mbsimonovic,CTLLaw"
  fi

  # Verify that the correct reviewers are assigned
  if echo "$reviewers" | grep -q "$expected_reviewers"; then
    echo "✅ PASS: Correct reviewer(s) ($expected_reviewers) assigned to PR."
  else
    echo "❌ FAIL: Incorrect reviewers assigned to PR. Actual reviewers: $reviewers"
    exit 1
  fi


  # Add Approvals for the PR (Replace placeholders with actual user logins)
  # (Replace with actual API calls or GitHub CLI commands to add approvals)
  gh pr review $pr_number --approve --body "Approved" --as "GTCrais" 
  gh pr review $pr_number --approve --body "Approved" --as "CTLLaw" 

  # Attempt to merge the PR and capture the exit code (0 for success, 1 for failure)
  set +e # Temporarily disable exit on error to capture the merge result
  merge_output=$(gh pr merge $pr_number --auto --squash)  # Or your preferred merge method
  merge_status=$?
  set -e # Re-enable exit on error

  if [ $merge_status -eq 0 ]; then
      echo "✅ PASS: PR successfully merged after approvals."
  else
      echo "❌ FAIL: PR could not be merged even after approvals."
      echo "Merge output: $merge_output"
      exit 1
  fi

else
  echo "❌ FAIL: PR from staging to master was not allowed."
  echo "Unexpected output:"
  echo "$output"
  exit 1  # Indicate failure to GitHub Actions
fi
