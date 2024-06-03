#!/bin/bash
set -e  # Exit immediately if a command fails

# ------------------------------------------------------------------------------
# Test Suite for GitHub Actions Workflow: Enforce Branch Sequence
# ------------------------------------------------------------------------------
# This script is designed to test the logic within the GitHub Actions workflow
# file (.github/workflows/enforce-branch-sequence.yml) that enforces a specific
# branch sequence for pull requests in your repository.
#
# The script simulates different pull request scenarios by setting environment
# variables and then executes the workflow's core logic to verify its behavior.
# ------------------------------------------------------------------------------

# This function prints the project folder structure
print_folder_structure() {
  echo "Project Folder Structure:"
  tree .github
}

# Source common helper functions
source ./.github/workflows/scripts/common_functions.sh

# Function to run a test scenario
run_test() {
  local base_ref="$1"
  local head_ref="$2"
  local expected_output="$3"
  local pr_title="$4"

  export GITHUB_REF=refs/heads/$head_ref
  export GITHUB_BASE_REF=refs/heads/$base_ref
  export GITHUB_EVENT_NAME=pull_request

  create_pull_request "$base_ref" "$head_ref" "$pr_title"

  output=$(check_branch_sequence)

  if [[ "$output" == *"$expected_output"* ]]; then
    echo "✅ PASS: $base_ref -> $head_ref"
  else
    echo "❌ FAIL: $base_ref -> $head_ref. Expected '$expected_output', got '$output'"
    exit 1
  fi
}

# Print folder structure
print_folder_structure

# Test cases
run_test "master" "staging" "Success" "Test PR from staging to master"
run_test "master" "aws-dev"  "Error"
run_test "staging" "aws-dev" "Success" "Test PR from aws-dev to staging"
run_test "staging" "feature-branch" "Error"
run_test "aws-dev" "feature-branch"  "Success" "Test PR from any to aws-dev"
run_test "master" "feature-branch"  "Error"
run_test "master" "" "Error"
run_test "staging" "" "Error"
run_test "aws-dev" "" "Success"
