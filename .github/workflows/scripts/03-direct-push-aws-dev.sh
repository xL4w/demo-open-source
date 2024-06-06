#!/bin/bash

# Test Case 03: Direct Push to aws-dev Branch (Allowed)

# Source common helper functions
source ./.github/workflows/scripts/common_functions.sh

# GitHub credentials
GH_TOKEN="${{ secrets.GH_TOKEN }}" 

# Define expected outcome based on the test case
expected_outcome="Success: The branch sequence is valid."

# Execute the test case logic and check the result
run_test_case "push" "aws-dev" "" "$expected_outcome"