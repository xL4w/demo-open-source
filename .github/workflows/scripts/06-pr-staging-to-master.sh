#!/bin/bash

# Test Case 06: PR from staging to master (Allowed)

# Mock environment variables (GitHub context)
export GITHUB_REF=refs/heads/staging  # Source branch
export GITHUB_BASE_REF=refs/heads/master  # Target branch
export GITHUB_EVENT_NAME=pull_request  # Trigger the pull request event
export PR_CREATOR="4k4xs4pH1r3" # your-github-username

# Source the workflow file
source ../enforce-branch-sequence.yml

# Execute the workflow's logic
output=$(run)

# Check for the expected success message
expected_output="Success: The branch sequence is valid."
if [[ "$output" == *"$expected_output"* ]]; then
  echo "✅ PASS: PR from staging to master allowed."

  # Additional reviewer checks (if your workflow has reviewer logic):
  # Fetch the pull request details using the GitHub API to verify reviewers.
  # ... (Add logic to check if @GTCrais and @CTLLaw are added as reviewers)
else
  echo "❌ FAIL: PR from staging to master was not allowed. Unexpected output: $output"
  exit 1  # Indicate failure to GitHub Actions
fi
