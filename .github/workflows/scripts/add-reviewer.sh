#!/bin/bash

reviewer=$1
gh_token=$2

# GitHub credentials
GH_TOKEN="${{ secrets.GH_TOKEN }}" 

# Authenticate with GitHub CLI
gh auth login --with-token < "$gh_token"

# Get the Pull Request number
pr_number=$(gh pr list --json number -q '.[].number')

# Add the reviewer
gh pr review "$pr_number" --add-reviewer "$reviewer"
