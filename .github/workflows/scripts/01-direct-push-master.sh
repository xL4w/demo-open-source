#!/bin/bash

# Test Case 01: Direct Push to Master Branch (Not Allowed)

# Set up mock environment variables (GitHub context)
export GITHUB_REF=refs/heads/master
export GITHUB_EVENT_NAME=push

# Source the workflow file to get the 'run' function
source ../enforce-branch-sequence.yml

# Execute the workflow's logic
output=$(run)

# Check for the expected error message
expected_error="Error: This PR violates the required branch sequence."
if [[ "$output" == *"$expected_error"* ]]; then
  echo "✅ PASS: Direct push to master correctly blocked."
else
  echo "❌ FAIL: Direct push to master was not blocked. Unexpected output: $output"
  exit 1  # Indicate failure to GitHub Actions
fi
