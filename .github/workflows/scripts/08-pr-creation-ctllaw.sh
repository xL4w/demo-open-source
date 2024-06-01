#!/bin/bash
set -e  # Exit immediately if a command fails

# ------------------------------------------------------------------------------
# Test Case 08: PR Creation by @CTLLaw 
#                (Reviewers should be @CTLLaw (creator) and @GTCrais)
# ------------------------------------------------------------------------------

# 1. Environment Setup
# --------------------
source ./.github/workflows/scripts/common_functions.sh   # Source common functions

# GitHub credentials
GH_TOKEN="${{ secrets.GH_TOKEN }}" 

# Repository information from GitHub context
GITHUB_REPOSITORY="${{ github.repository }}"

# User who is creating the PR
PR_CREATOR="CTLLaw"

# Set PR body to indicate it's an application change (adjust for infrastructure if needed)
export PR_BODY="This PR is related to Applications changes."                       

# List of expected reviewers for this type of PR
EXPECTED_REVIEWERS="CTLLaw,GTCrais"  # Adjusted for creator and required reviewer 


# 3. Test Execution
# -----------------

# Create a new PR from a feature branch to aws-dev
pr_url=$(create_pull_request "aws-dev" "feature/new-feature-by-ctllaw" "Test PR by $PR_CREATOR")
echo "Created PR: $pr_url"

# Retrieve the reviewers for the new PR
assigned_reviewers=$(get_pull_request_reviewers "$pr_url")
echo "Assigned reviewers: $assigned_reviewers"

# Verify that the expected reviewers are assigned
if [[ "$assigned_reviewers" == "$EXPECTED_REVIEWERS" ]]; then
  echo "✅ PASS: Correct reviewers (@GTCrais and @CTLLaw) were added to the PR."
else
  echo "❌ FAIL: Incorrect reviewers were added. Expected: $EXPECTED_REVIEWERS, Actual: $assigned_reviewers"
  exit 1  # Indicate failure to GitHub Actions
fi
