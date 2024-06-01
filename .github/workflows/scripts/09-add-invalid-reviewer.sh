#!/bin/bash

source ./common_functions.sh

set -e  # Exit immediately if a command fails

# ------------------------------------------------------------------------------
# Test Case 09: Adding Invalid Reviewer (Not Allowed)
# ------------------------------------------------------------------------------

# 1. Environment Setup
# --------------------
source ./common_functions.sh   # Source common functions

# GitHub credentials
GH_TOKEN="${{ secrets.GH_TOKEN }}" 

# Repository information from GitHub context
GITHUB_REPOSITORY="${{ github.repository }}"

# Invalid GitHub username for testing (replace with an actual invalid username)
INVALID_REVIEWER="invalid-user123"  


# 3. Test Execution
# -----------------

# Create a new PR from a feature branch to aws-dev
pr_url=$(create_pull_request "aws-dev" "feature/new-feature-for-review")
echo "Created PR: $pr_url"

# Attempt to add an invalid reviewer to the PR
add_reviewer_status_code=$(add_reviewer "$pr_url" "$INVALID_REVIEWER")

# Verify if the request to add the invalid reviewer was not successful (HTTP 422)
if [[ "$add_reviewer_status_code" == "422" ]]; then
  echo "✅ PASS: Adding invalid reviewer ($INVALID_REVIEWER) correctly failed."
else
  echo "❌ FAIL: Adding invalid reviewer ($INVALID_REVIEWER) was allowed. (Status code: $add_reviewer_status_code)"
  exit 1  # Indicate failure to GitHub Actions
fi
