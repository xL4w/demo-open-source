#!/bin/bash

# Test Case 02: Direct Push to Staging Branch (Not Allowed)

# Set up mock environment variables (GitHub context)
export GITHUB_REF=refs/heads/staging
export GITHUB_EVENT_NAME=push

# Source the workflow file to get the 'run' function
source ../enforce-branch-sequence.yml

# Execute the workflow's logic
output=$(run)

# Check for the expected error message
expected_error="Error: This PR violates the required branch sequence."
if [[ "$output" == *"$expected_error"* ]]; then
  echo "✅ PASS: Direct push to staging correctly blocked."
else
  echo "❌ FAIL: Direct push to staging was not blocked. Unexpected output: $output"
  exit 1  # Indicate failure to GitHub Actions
fi
