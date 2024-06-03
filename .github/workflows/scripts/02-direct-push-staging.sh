#!/bin/bash
set -e  # Exit immediately if a command fails

# Test Case 02: Direct Push to Staging Branch (Not Allowed)

# Source common helper functions
source ./.github/workflows/scripts/common_functions.sh

# Mock GitHub environment variables for a direct push to staging
export GITHUB_REF=refs/heads/staging
export GITHUB_EVENT_NAME=push
export GITHUB_BASE_REF=""  # Empty base ref for direct push

# Source the main workflow logic
source ../enforce-branch-sequence.yml 

# Run the workflow's logic and capture output
output=$(run)

# Define the expected error messages for a direct push to staging
expected_errors=("Error: This PR violates the required branch sequence." "Error: Direct pushes to staging are not allowed.")

# Check if the output contains any of the expected error messages
error_found=false
for expected_error in "${expected_errors[@]}"; do
    if echo "$output" | grep -q "$expected_error"; then
        error_found=true
        break
    fi
done

if [ "$error_found" = true ]; then
  echo "✅ PASS: Direct push to staging correctly blocked."
else
  echo "❌ FAIL: Direct push to staging was not blocked."
  echo "Unexpected output:"
  echo "$output"
  exit 1  # Indicate failure to GitHub Actions
fi
