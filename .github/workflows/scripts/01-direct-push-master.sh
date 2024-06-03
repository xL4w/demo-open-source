#!/bin/bash

set -e  # Exit immediately if a command fails

# Test Case 01: Direct Push to Master Branch (Not Allowed)

# Source common helper functions
source ./.github/workflows/scripts/common_functions.sh

# Mock GitHub environment variables for a direct push to master
export GITHUB_REF=refs/heads/master
export GITHUB_EVENT_NAME=push
export GITHUB_BASE_REF=""  # Empty base ref for direct push

# Source the main workflow logic
source ../enforce-branch-sequence.yml

# Run the workflow's logic and capture output
output=$(run)

# Define the expected error messages for a direct push to master
expected_errors=("Error: This PR violates the required branch sequence." "Error: Direct pushes to master are not allowed.")

# Check if the output contains any of the expected error messages
error_found=false
for expected_error in "${expected_errors[@]}"; do
    if echo "$output" | grep -q "$expected_error"; then
        error_found=true
        break  # Exit the loop if an error is found
    fi
done

if [ "$error_found" = true ]; then
  echo "✅ PASS: Direct push to master correctly blocked."
else
  echo "❌ FAIL: Direct push to master was not blocked."
  echo "Unexpected output:"
  echo "$output"
  exit 1  # Indicate failure to GitHub Actions
fi
