source_branch=$1
target_branch=$2
gh_token=$3

# Create a temporary branch
temp_branch=$(date +%s)-${RANDOM}
git checkout -b "$temp_branch"

# Make a small change
echo "$temp_branch" >> README.md
git add .
git commit -m "Test commit from $temp_branch to $target_branch"

# Push the branch and create a Pull Request
git push origin "$temp_branch":"$target_branch"

# Get the Pull Request number
pr_number=$(gh pr list --head "$temp_branch" --json number -q '.[].number')

# Merge the Pull Request
gh pr merge "$pr_number" --merge --delete-branch
