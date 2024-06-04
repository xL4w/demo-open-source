#!/bin/bash

reviewer=$1
gh_token=$2

# Get the Pull Request number
pr_number=$(gh pr list --json number -q '.[].number')

# Add the reviewer
gh pr review "$pr_number" --add-reviewer "$reviewer"
