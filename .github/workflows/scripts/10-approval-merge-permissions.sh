#!/bin/bash
set -e  # Exit immediately if a command fails

# ------------------------------------------------------------------------------
# Test Case 10: Approval and Merge Permissions
# ------------------------------------------------------------------------------

# 1. Environment Setup
# --------------------
source ./.github/workflows/scripts/common_functions.sh   # Source common functions

# GitHub credentials
GH_TOKEN="${{ secrets.GH_TOKEN }}" 

# Repository information from GitHub context
GITHUB_REPOSITORY="${{ github.repository }}"

# 2. Test Scenarios
# -----------------

# Define test scenarios in an array:
# Format: USER BRANCH PR_TYPE ACTION EXPECTED_STATUS_CODE
#   - USER: Who is performing the action
#   - BRANCH: Target branch of the PR
#   - PR_TYPE: "Application" or "Infrastructure"
#   - ACTION: "APPROVE" or "MERGE"
#   - EXPECTED_STATUS_CODE: Expected HTTP status code (200 for success, 403 for forbidden, etc.)

test_scenarios=(
    "GTCrais aws-dev Application APPROVE 200"
    "CTLLaw aws-dev Application APPROVE 200"
    "mbsimonovic aws-dev Infrastructure APPROVE 200" 
    "other-user aws-dev Application APPROVE 403" 
    "GTCrais staging Application APPROVE 200"
    "mbsimonovic staging Infrastructure APPROVE 200"
    "other-user staging Application APPROVE 403" 
    "CTLLaw master Application APPROVE 200"     
    "GTCrais master Application MERGE 200"    
    "mbsimonovic master Application MERGE 403"
    "other-user master Application MERGE 403"
    "GTCrais aws-dev Application MERGE 405"    
    "CTLLaw aws-dev Application MERGE 405"     
)

# 3. Test Execution
# -----------------

# Iterate over test scenarios
for scenario in "${test_scenarios[@]}"; do
    # Parse scenario parameters
    IFS=' ' read -r user branch pr_type action expected_code <<< "$scenario"

    echo "Test: User $user $action $pr_type PR to $branch (expecting status $expected_code)"

    # Create a pull request with a title indicating the PR type
    pr_url=$(create_pull_request "$branch" "feature/test-approval-merge" "Test $pr_type PR for permissions")
    echo "Created PR: $pr_url"

    # Add required reviewers based on the branch and PR type
    if [[ "$branch" == "aws-dev" ]]; then
        if [[ "$pr_type" == "Application" ]]; then
            add_reviewer "$pr_url" "GTCrais"
        else
            add_reviewer "$pr_url" "mbsimonovic"
        fi
    elif [[ "$branch" == "staging" ]]; then
        add_reviewer "$pr_url" "GTCrais"  # For both application and infrastructure
    else  # master
        add_reviewer "$pr_url" "CTLLaw"
        add_reviewer "$pr_url" "GTCrais" 
    fi

    # Set the current user for the GitHub Action
    export PR_CREATOR=$user

    # Perform the action (approve or merge) and check the result
    if [[ "$action" == "APPROVE" ]]; then
        status_code=$(approve_pull_request "$pr_url")
    elif [[ "$action" == "MERGE" ]]; then
        status_code=$(merge_pull_request "$pr_url")
    else
        echo "❌ FAIL: Invalid action specified in scenario: $action"
        exit 1
    fi

    if [[ "$status_code" == "$expected_code" ]]; then
        echo "✅ PASS: Expected status code ($expected_code) received."
    else
        echo "❌ FAIL: Unexpected status code. Expected: $expected_code, Actual: $status_code"
        exit 1
    fi
done
