#!/bin/bash

# Test Case 10: Approval and Merge Permissions

# Set GitHub environment variables
export GH_TOKEN="${{ secrets.GH_TOKEN }}"
export GITHUB_REPOSITORY="${{ github.repository }}"

# Source the workflow file
source ../enforce-branch-sequence.yml 

# Helper functions (Re-use the functions from previous test cases)
create_pull_request() {
  # ... (copy the function from 07-pr-creation-gtcrais.sh or 08-pr-creation-ctllaw.sh)
}

get_pull_request_reviewers() {
  # ... (copy the function from 07-pr-creation-gtcrais.sh or 08-pr-creation-ctllaw.sh)
}

add_reviewer() {
  # ... (copy the function from 09-add-invalid-reviewer.sh)
}

approve_pull_request() {
  local pr_url="$1"

  response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d '{"event": "APPROVE"}' \
    "$pr_url/reviews")
    echo $response
}

merge_pull_request() {
  local pr_url="$1"

  response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "$pr_url/merge")
    echo $response
}

# Test Scenarios (Adjust branch names and users as needed)
test_scenarios=(
  "GTCrais aws-dev APPROVE 200"  # @GTCrais approves and merges a PR to aws-dev (success)
  "CTLLaw aws-dev APPROVE 200"   # @CTLLaw approves and merges a PR to aws-dev (success)
  "other-user aws-dev APPROVE 403" # Other user tries to approve a PR to aws-dev (forbidden)
  # ... Add more scenarios for staging->master, attempting to merge without approval, etc.
)

# Iterate through test scenarios
for scenario in "${test_scenarios[@]}"; do
  user=$(echo "$scenario" | awk '{print $1}')
  branch=$(echo "$scenario" | awk '{print $2}')
  action=$(echo "$scenario" | awk '{print $3}')
  expected_code=$(echo "$scenario" | awk '{print $4}')
  
  echo "Test: User $user $action PR to $branch"
  
  # Create a pull request
  pr_url=$(create_pull_request "$branch" "feature/test-approval-merge")
  echo "Created PR: $pr_url"

  # Add GTCrais and CTLLaw as reviewers
  add_reviewer "$pr_url" "GTCrais"
  add_reviewer "$pr_url" "CTLLaw"

  # Set the current user as the environment variable for the GitHub Action
  export PR_CREATOR=$user

  # Perform the action (approve or merge)
  if [[ "$action" == "APPROVE" ]]; then
    status_code=$(approve_pull_request "$pr_url")
  elif [[ "$action" == "MERGE" ]]; then
    status_code=$(merge_pull_request "$pr_url")
  fi

  # Verify the result
  if [[ "$status_code" == "$expected_code" ]]; then
    echo "✅ PASS: Expected status code ($expected_code) received."
  else
    echo "❌ FAIL: Unexpected status code. Expected: $expected_code, Actual: $status_code"
    exit 1
  fi
  
done
