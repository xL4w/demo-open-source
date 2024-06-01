#!/bin/bash

# Test Case 04: PR from Any Branch to aws-dev (Allowed)

# Mock environment variables (GitHub context)
export GITHUB_REF=refs/heads/feature/my-new-feature  # Example source branch
export GITHUB_BASE_REF=refs/heads/aws-dev  # Target branch
export GITHUB_EVENT_NAME=pull_request  # Trigger the pull request event
export PR_CREATOR="4k4xs4pH1r3" # your-github-username

# Source the workflow file
source ../enforce-branch-sequence.yml

# Execute the workflow's logic
output=$(run)

# Check for the expected success message
expected_output="Success: The branch sequence is valid."
if [[ "$output" == *"$expected_output"* ]]; then
  echo "✅ PASS: PR from feature/my-new-feature to aws-dev allowed."

  # Additional reviewer checks (if your workflow has reviewer logic):
  # Fetch the pull request details using
