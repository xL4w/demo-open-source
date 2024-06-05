#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# Test Case 10: Approval and Merge Permissions
# ------------------------------------------------------------------------------

# Source common functions
source ./.github/workflows/scripts/common_functions.sh

# GitHub credentials
GH_TOKEN="${{ secrets.GH_TOKEN }}" 

# Repository information from GitHub context
GITHUB_REPOSITORY="${{ github.repository }}"

# Function to run a test scenario for PR approval/merge
run_test_scenario() {
    local user="$1"
    local branch="$2"
    local action="$3"
    local expected_code="$4"
    local pr_type="$5"

    echo "Test: User $user $action $pr_type PR to $branch (expecting status $expected_code)"

    # Create a pull request
    local pr_url=$(create_pull_request "$branch" "feature/test-approval-merge" "Test $pr_type PR for permissions")
    echo "Created PR: $pr_url"

    # Add required reviewers (adjust logic as needed)
    if [[ "$branch" == "aws-dev" ]]; then
        add_reviewer "$pr_url" "4k4xs4pH1r3-2"
    elif [[ "$branch" == "staging" ]]; then
        add_reviewer "$pr_url" "4k4xs4pH1r3-2"
    else  # master
        add_reviewer "$pr_url" "CTLLaw"
        add_reviewer "$pr_url" "4k4xs4pH1r3-2" 
    fi

    # Set the current user for the GitHub Action
    export PR_CREATOR=$user

    # Perform the action and check the result
    local status_code
    if [[ "$action" == "APPROVE" ]]; then
        status_code=$(approve_pull_request "$pr_url")
    elif [[ "$action" == "MERGE" ]]; then
        status_code=$(merge_pull_request "$pr_url")
    else
        echo "❌ FAIL: Invalid action specified: $action"
        exit 1
    fi

    if [[ "$status_code" == "$expected_code" ]]; then
        echo "✅ PASS: Expected status code ($expected_code) received."
    else
        echo "❌ FAIL: Unexpected status code. Expected: $expected_code, Actual: $status_code"
        exit 1
    fi
}

# -------------------- Test Scenarios --------------------

# Approvals 
run_test_scenario "4k4xs4pH1r3-2" "aws-dev" "APPROVE" 200 "Application"
run_test_scenario "CTLLaw" "aws-dev" "APPROVE" 200 "Application"
run_test_scenario "4k4xs4pH1r3-2" "aws-dev" "APPROVE" 403 "Application"
run_test_scenario "other-user" "aws-dev" "APPROVE" 403 "Application"

run_test_scenario "4k4xs4pH1r3-2" "staging" "APPROVE" 200 "Application"
run_test_scenario "4k4xs4pH1r3-2" "staging" "APPROVE" 403 "Application"
run_test_scenario "other-user" "staging" "APPROVE" 403 "Application"

run_test_scenario "CTLLaw" "master" "APPROVE" 200 "Application"
run_test_scenario "4k4xs4pH1r3-2" "master" "APPROVE" 403 "Application"
run_test_scenario "other-user" "master" "APPROVE" 403 "Application"

# Merges
run_test_scenario "4k4xs4pH1r3-2" "master" "MERGE" 200 "Application"
run_test_scenario "4k4xs4pH1r3-2" "master" "MERGE" 403 "Application"
run_test_scenario "other-user" "master" "MERGE" 403 "Application"

# Negative Test Cases: Merging to non-master branches
run_test_scenario "4k4xs4pH1r3-2" "aws-dev" "MERGE" 405 "Application" 
run_test_scenario "CTLLaw" "aws-dev" "MERGE" 405 "Application"
run_test_scenario "4k4xs4pH1r3-2" "staging" "MERGE" 405 "Application" 
run_test_scenario "CTLLaw" "staging" "MERGE" 405 "Application"
