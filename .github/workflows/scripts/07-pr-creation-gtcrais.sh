#!/bin/bash
set -e  # Exit immediately if a command fails

# ------------------------------------------------------------------------------
# Test Case 07: PR Creation by @GTCrais 
#                (Reviewers should be @GTCrais (creator) and @CTLLaw)
# ------------------------------------------------------------------------------

# Source common functions
source ./.github/workflows/scripts/common_functions.sh   

# GitHub credentials and repository info
GH_TOKEN="${{ secrets.GH_TOKEN }}" 
GITHUB_REPOSITORY="${{ github.repository }}"

# --- Test Configuration ---

# User creating the PR
PR_CREATOR="GTCrais"                       

# Expected reviewers (comma-separated for comparison)
EXPECTED_REVIEWERS="GTCrais,CTLLaw"

# PR details
TARGET_BRANCH="aws-dev" 
SOURCE_BRANCH="feature/new-feature-by-GTCrais"
PR_TITLE="Test PR by $PR_CREATOR"
PR_BODY="This PR is related to Applications changes."

# --- Test Execution ---

# Create the PR
pr_url=$(create_pull_request "$TARGET_BRANCH" "$SOURCE_BRANCH" "$PR_TITLE" "$PR_BODY") 
echo "Created PR: $pr_url"

# Get assigned reviewers (and wait for assignment to complete)
assigned_reviewers=$(get_pull_request_reviewers "$pr_url" 10) 
echo "Assigned reviewers: $assigned_reviewers"

# Verify the expected reviewers are present
if [[ "$assigned_reviewers" == *"$EXPECTED_REVIEWERS"* ]]; then 
  echo "✅ PASS: Correct reviewers (@GTCrais and @CTLLaw) were added to the PR."
else
  echo "❌ FAIL: Incorrect reviewers were added. Expected: $EXPECTED_REVIEWERS, Actual: $assigned_reviewers"
  exit 1  # Indicate failure to GitHub Actions
fi
