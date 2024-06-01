#!/bin/bash

# Test Case 09: Adding Invalid Reviewer (Not Allowed)

# Set GitHub environment variables
export GH_TOKEN="<span class="math-inline">\{\{ secrets\.GITHUB\_TOKEN \}\}"
export GITHUB\_REPOSITORY\="</span>{{ github.repository }}"
export INVALID_REVIEWER="4k4xs4pH1r3-2" # Replace with an actual GitHub username not in the allowed list

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
  local pr_url="$1"
  local reviewer="<span class="math-inline">2"
response\=</span>(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"reviewers\":[\"$reviewer\"]}" \
    "$pr_url/requested_reviewers")
    echo <span class="math-inline">response
\}
\# Create a pull request \(choose appropriate branches based on your test\)
pr\_url\=</span>(create_pull_request "aws-dev" "feature/new-feature-for-review")  # Modify base/head as needed
echo "Created PR: <span class="math-inline">pr\_url"
\# Attempt to add an invalid reviewer to the PR
add\_reviewer\_status\_code\=</span>(add_reviewer "$pr_url" "$INVALID_REVIEWER")

# Verify if the request to add the invalid reviewer was not successful (HTTP 422)
if [[ "$add_reviewer_status_code" == "422" ]]; then
  echo "✅ PASS: Adding invalid reviewer ($INVALID_REVIEWER) correctly failed."
else
  echo "❌ FAIL:
