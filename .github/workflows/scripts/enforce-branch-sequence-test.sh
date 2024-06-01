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

# This function simulates the GitHub environment by setting variables that
# the workflow would normally get from GitHub during a pull request.

# 0. Print Folder Structure
echo "Project Folder Structure:"
tree .github

# 1. Environment Setup
# --------------------
source ./.github/workflows/scripts/common_functions.sh   # Source common helper functions

# 2. Helper Function to Mock GitHub Context
# ------------------------------------------
mock_github_context() {
  export GITHUB_REF=refs/heads/$2    # Set the head (source) branch
  export GITHUB_BASE_REF=refs/heads/$1  # Set the base (target) branch
  export GITHUB_EVENT_NAME=pull_request
}

# 3. Workflow Logic Function
# --------------------------

# Function to check if a branch sequence is valid
check_branch_sequence() {
  # Allowed sequences for pull requests
  allowed_sequences=(
    "Any branch --> aws-dev" 
    "aws-dev --> staging"     
    "staging --> master"      
  )

  # Get base and head ref from environment variables
  base_ref="$GITHUB_BASE_REF"
  head_ref="$GITHUB_REF"

  # Check if pull request follows allowed sequences
  valid_sequence=false
  for seq in "${allowed_sequences[@]}"; do
    IFS='-->' read -r allowed_base allowed_head <<< "$seq"
    allowed_base=$(echo "$allowed_base" | xargs)
    allowed_head=$(echo "$allowed_head" | xargs)

    if [[ ("$allowed_base" == "Any branch" || "$base_ref" == "$allowed_base") && "$head_ref" == "$allowed_head" ]]; then
      valid_sequence=true
      break
    fi
  done

  if [ "$valid_sequence" = true ]; then
    echo "Success: The branch sequence is valid."
  else
    echo "Error: This PR violates the required branch sequence."
    echo "Allowed sequences are:"
    for seq in "${allowed_sequences[@]}"; do
      echo "- $seq"
    done
  fi
}


# 4. Test Cases
# -------------

run_test() {
  local base_ref="$1"
  local head_ref="$2"
  local expected_output="$3"
  local pr_title="$4"

  mock_github_context "$base_ref" "$head_ref"

  # Create a pull request to set the PR_BODY variable
  create_pull_request "$base_ref" "$head_ref" "$pr_title"

  # Execute the check_branch_sequence function and capture its output
  output=$(check_branch_sequence)

  # Check if the captured output contains the expected result.
  if [[ "$output" == *"$expected_output"* ]]; then # Partial match to handle additional output in the function
    echo "✅ PASS: $base_ref -> $head_ref"
  else
    # If the output doesn't match, report a failure.
    echo "❌ FAIL: $base_ref -> $head_ref. Expected '$expected_output', got '$output'"
    exit 1
  fi
}
# These test scenarios align with the original requirements:
#   - Direct pushes to master, staging, and aws-dev should be disallowed.
#   - PRs are only allowed in the sequence: any branch -> aws-dev -> staging -> master.
run_test "master" "staging" "Success" "Test PR from staging to master"            # Valid transition
run_test "master" "aws-dev"  "Error"  # Invalid transition
run_test "staging" "aws-dev" "Success" "Test PR from aws-dev to staging"           # Valid transition
run_test "staging" "feature-branch" "Error"   # Invalid transition
run_test "aws-dev" "feature-branch"  "Success" "Test PR from any to aws-dev"          # Valid transition
run_test "master" "feature-branch"  "Error"   # Invalid transition
run_test "master" "" "Error"           # Invalid transition (direct push)
run_test "staging" "" "Error"          # Invalid transition (direct push)
run_test "aws-dev" "" "Success"        # Valid transition (direct push to aws-dev)
