#!/bin/bash

set -e  # Exit immediately if a command fails

# Test Case 03: Direct Push to aws-dev Branch (Allowed)

# Source common helper functions
source ./common_functions.sh

# Mock GitHub environment variables for a direct push to aws-dev
export GITHUB_REF=refs/heads/aws-dev
export GITHUB_EVENT_NAME=push
export GITHUB_BASE_REF=""  # Empty base ref for direct push

# Source the main workflow logic
source ../enforce-branch-sequence.yml 

# Run the workflow's logic and capture output
output=$(run)

# Define the expected success message for a direct push to aws-dev
expected_success="Success: The branch sequence is valid."

# Check if the output contains the expected success message
if echo "$output" | grep -q "$expected_success"; then
  echo "✅ PASS: Direct push to aws-dev correctly allowed."
else
  echo "❌ FAIL: Direct push to aws-dev was not allowed."
  echo "Unexpected output:"
  echo "$output"
  exit 1  # Indicate failure to GitHub Actions
fi
