#!/bin/bash

user=$1
gh_token=$2

# Authenticate with GitHub CLI
gh auth login --with-token < "$gh_token"

# Get the Pull Request number
pr_number=$(gh pr list --json number -q '.[].number')

# Approve the Pull Request
gh pr review "$pr_number" --approve

# Merge the Pull Request
gh pr merge "$pr_number" --merge --delete-branch
