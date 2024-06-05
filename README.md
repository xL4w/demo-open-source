[![CodeQL](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/github-code-scanning/codeql) [![Dependency Review](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/dependency-review.yml/badge.svg)](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/dependency-review.yml) [![Proof HTML](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/proof-html.yml/badge.svg)](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/proof-html.yml) [![Auto Assign PR Creator](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/auto-assign_PR_Creator.yml/badge.svg)](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/auto-assign_PR_Creator.yml) [![Auto Assign PR Reviewers](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/auto-assign_PR_Reviewers.yml/badge.svg)](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/auto-assign_PR_Reviewers.yml) [![Checkov Security Scan](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/checkov.yml/badge.svg)](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/checkov.yml) [![Enforce Branch Sequence and Permissions](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/enforce-branch-sequence.yml/badge.svg)](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/enforce-branch-sequence.yml) [![Snyk Infrastructure as Code](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/snyk-infrastructure.yml/badge.svg)](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/snyk-infrastructure.yml)

# Welcome to CTL Law organization's demo open source repository, using GitHub Enterprise, with GitHub Advanced Security Enabled.   

This code repository (or "repo") is designed to demonstrate the best GitHub offers with the least noise.

The repo includes an `index.html` file (so it can render a web page), two GitHub Actions workflows, and a CSS stylesheet dependency.

# Important

As this demo repository is in the development stage, cleaning up the workflow runs is important. We recommend creating a final PR, merging it into the master branch, and then cleaning up.

To clean up the workflow runs, use the below command:

```bash
gh run list --limit 100 --json databaseId -q '.[].databaseId' | xargs -n1 gh run delete --repo CTLLAW-Org/demo-open-source && gh cache list | awk '{print $1}' | xargs -n1 gh cache delete
```

After clean-up, there should be only one run per workflow in the dashboard.

This allows us to effectively review only the last run of each workflow to evaluate the current progress and identify when we can stop to clean up the workflow runs.

## GitHub Guardian: Enforcing Workflow and Access Control

This solution implements a robust GitHub Guardian setup utilizing GitHub Actions workflows to enforce strict branch protection rules, control reviewer assignments, and manage the pull request flow.

### Directory Structure:

```
.github
└── workflows
├── auto-assign_PR_Creator.yml
├── auto-assign_PR_Reviewers.yml
├── enforce-branch-sequence.yml
├── scripts
│ ├── 01-direct-push-master.sh
│ ├── 02-direct-push-staging.sh
│ ├── 03-direct-push-aws-dev.sh
│ ├── 04-pr-any-to-aws-dev.sh
│ ├── 05-pr-aws-dev-to-staging.sh
│ ├── 06-pr-staging-to-master.sh
│ ├── 07-pr-creation-gtcrais.sh
│ ├── 08-pr-creation-ctllaw.sh
│ ├── 09-add-invalid-reviewer.sh
│ ├── 10-approval-merge-permissions.sh
│ ├── add-reviewer.sh
│ ├── approve-and-merge-pr.sh
│ ├── check-reviewers.sh
│ ├── common_functions.sh
│ ├── create-and-merge-pr.sh
│ ├── create-pr.sh
│ └── enforce-branch-sequence-test.sh
└── test-workflows.yml
```

### Core Principles:

* **Branch Protection:** Direct pushes to `master`, `staging`, and `aws-dev` branches are prohibited. This ensures that all code changes undergo review and automated checks.
* **Controlled PR Flow:** A strict branching strategy is enforced, allowing PRs only in the following sequence:
* Any branch to `aws-dev`
* `aws-dev` to `staging`
* `staging` to `master`
* **Automated Reviewer Assignment:** `@GTCrais` and `@CTLLaw` are automatically assigned as reviewers to all PRs, ensuring consistent code review coverage.
* **Restricted Approvals and Merges:** Only `@GTCrais` and `@CTLLaw` can approve and merge PRs, enhancing security and control.
* **Automated Testing:** A suite of test scripts, executed through GitHub Actions, continuously validates the effectiveness of the implemented guardrails.

### Implementation Details:

1. **Branch Protection Rules:**

The following settings are applied to `master`, `staging`, and `aws-dev` branches:
* **Require pull request reviews before merging:** Enabled
* **Required approving reviews:**
* 1 (for `aws-dev`)
* 2 (for `staging` and `master`)
* **Dismiss stale pull request approvals when new commits are pushed:** Enabled
* **Require status checks to pass before merging:** Enabled 
* **Require branches to be up to date before merging:** Enabled
* **Restrict who can push to matching branches:** Enabled, limited to `GTCrais` and `CTLLaw` (except `aws-dev`)
* **Require linear history:** Enabled (optional, prevents merge commits)
* **Allow force pushes:** Disabled
* **Allow deletions:** Disabled

2. **GitHub Actions Workflows:**

* `.github/workflows/auto-assign_PR_Reviewers.yml`: Automatically assigns `@GTCrais` and `@CTLLaw` as reviewers to every new PR.
* `.github/workflows/enforce-branch-sequence.yml`: This workflow enforces the defined branch flow, preventing PRs that don't adhere to the allowed sequence. It also blocks direct pushes to protected branches.

3. **Test Suite:**

The repository includes a comprehensive test suite (`test-branch-sequence.yml` and associated scripts) designed to rigorously validate the GitHub Guardian setup. The tests cover scenarios such as:
* Direct pushes to protected branches (should fail)
* PRs created out of the allowed sequence (should fail)
* PRs created by unauthorized users (should fail)
* Attempts to add unauthorized reviewers (should fail)
* Attempts to approve or merge PRs by unauthorized users (should fail)
* Valid PRs created and merged by authorized users (should succeed)

4. **Scripts:**

The `scripts` directory contains shell scripts used by the test suite:

* `common_functions.sh`: Holds reusable functions used across different test scripts.
* **Test Case Scripts:** Individual scripts (`01-direct-push-master.sh`, `02-direct-push-staging.sh`, etc.) simulate specific scenarios to verify the expected behavior of the GitHub Guardian.

### How to Test:

1. Create a separate branch called "test-branch" for testing.
2. Commit and push the workflows, scripts, and branch protection rules.
3. Trigger the test workflows either locally or through your CI/CD pipeline.

### Important Notes:

* **Placeholders:** Remember to replace placeholders like `@GTCrais`, `@CTLLaw`, and branch names with your actual usernames and branch names.
* **Regular Review:** Periodically review and update your GitHub Guardian configuration to adapt to changing requirements and evolving security best practices.
* **Additional Security:** Consider implementing additional security measures like secret scanning, dependency vulnerability analysis, and code security audits.
