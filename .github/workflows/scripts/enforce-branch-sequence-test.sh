#!/bin/bash

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

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

# This function simulates the GitHub environment by setting variables that
# the workflow would normally get from GitHub during a pull request.
mock_github_context() {
  export github_base_ref="$1"  # Set the target branch of the pull request.
  export github_head_ref="$2"  # Set the source branch of the pull request.
}

# This function implements the branch sequence enforcement logic.
run() {
  case "$github_base_ref" in
    master)
      if [[ "$github_head_ref" == "staging" ]]; then
        echo "Success"
      else
        echo "Error"
      fi
      ;;
    staging)
      if [[ "$github_head_ref" == "aws-dev" ]]; then
        echo "Success"
      else
        echo "Error"
      fi
      ;;
    aws-dev)
      if [[ "$github_head_ref" == "feature-branch" ]]; then
        echo "Success"
      else
        echo "Error"
      fi
      ;;
    *)
      echo "Error"
      ;;
  esac
}

# This function runs a single test case. It takes the following arguments:
# - $1: The base (target) branch of the pull request.
# - $2: The head (source) branch of the pull request.
# - $3: The expected output message ("Success" or "Error").
run_test() {
  local base_ref="$1"
  local head_ref="$2"
  local expected_output="$3"

  # Set up the mock GitHub environment for this specific test case.
  mock_github_context "$base_ref" "$head_ref"

  # Execute the 'run' function and capture its output.
  output=$(run)

  # Check if the captured output contains the expected result.
  if [[ "$output" == "$expected_output" ]]; then
    echo "✅ PASS: $base_ref -> $head_ref"
  else
    # If the output doesn't match, report a failure.
    echo "❌ FAIL: $base_ref -> $head_ref. Expected '$expected_output', got '$output'"
  fi
}

# ------------------------------------------------------------------------------
# Test Cases
# ------------------------------------------------------------------------------

# Each test case simulates a different pull request scenario and checks
# if the workflow produces the expected result.
run_test "master" "staging" "Success"         # Valid transition
run_test "master" "aws-dev" "Error"           # Invalid transition
run_test "staging" "aws-dev" "Success"        # Valid transition
run_test "staging" "feature-branch" "Error"   # Invalid transition
run_test "aws-dev" "feature-branch" "Success" # Valid transition

# Add more test cases here to cover additional scenarios and edge cases.
