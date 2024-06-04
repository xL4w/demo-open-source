#!/bin/bash
set -e  # Exit immediately if a command fails

# ------------------------------------------------------------------------------
# Test Case 08: PR Creation by @CTLLaw 
#                (Reviewers should automatically be @CTLLaw (creator) and @GTCrais)
# ------------------------------------------------------------------------------

# Source common functions (Ensure this path is correct)
source ./.github/workflows/scripts/common_functions.sh   

# GitHub credentials
GH_TOKEN="${{ secrets.GH_TOKEN }}" 

# Repository information from GitHub context
GITHUB_REPOSITORY="${{ github.repository }}"

# --- Test Setup ---

# User creating the PR
PR_CREATOR="CTLLaw"
# Target branch for the PR
TARGET_BRANCH="aws-dev" 
# Expected reviewers (should be automatically assigned)
EXPECTED_REVIEWERS="CTLLaw,GTCrais"  

# Create a unique branch name for this test
TEST_BRANCH="test-pr-creation-ctllaw-$(date +%s)"

# ---  Execute Test ---

# Create a new branch locally, make changes, and push to remote
create_and_push_branch "$TEST_BRANCH"

# Create the PR 
pr_url=$(create_pull_request "$TARGET_BRANCH" "$TEST_BRANCH" "Test Case 08: PR by @CTLLaw")
echo "Created PR: $pr_url"

# Give GitHub a moment to assign reviewers automatically
sleep 5 

# Retrieve assigned reviewers 
assigned_reviewers=$(get_pull_request_reviewers "$pr_url")
echo "Assigned reviewers: $assigned_reviewers"

# --- Assertions ---

# Verify expected reviewers are assigned
if [[ "$assigned_reviewers" == "$EXPECTED_REVIEWERS" ]]; then
  echo "✅ PASS: Correct reviewers (@GTCrais and @CTLLaw) were automatically added."
else
  echo "❌ FAIL: Incorrect reviewers. Expected: '$EXPECTED_REVIEWERS', Actual: '$assigned_reviewers'"
  exit 1 
fi

# Optionally: Clean up the test branch after successful test
# delete_branch "$TEST_BRANCH" 
