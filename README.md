[![CodeQL](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/codeql-analysis.yml) ![Proof HTML](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/proof-html.yml/badge.svg) [![Auto Assign PR Creator and Reviewers](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/auto-assign.yml/badge.svg)](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/auto-assign.yml) [![Checkov Security Scan](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/checkov.yml/badge.svg)](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/checkov.yml) [![Enforce Branch Sequence](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/enforce-branch-sequence.yml/badge.svg)](https://github.com/CTLLAW-Org/demo-open-source/actions/workflows/enforce-branch-sequence.yml) [![Snyk Infrastructure as Code](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/snyk-infrastructure.yml/badge.svg)](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/snyk-infrastructure.yml) [![Test Branch Sequence and Permissions](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/test-branch-sequence.yml/badge.svg)](https://github.com/Nucleus-Flow-Testing/demo-repository/actions/workflows/test-branch-sequence.yml)


# Welcome to your organization's demo repository
This code repository (or "repo") is designed to demonstrate the best GitHub offers with the least noise.

The repo includes an `index.html` file (so it can render a web page), two GitHub Actions workflows, and a CSS stylesheet dependency.

# Important

As this demo repository is in the development stage, it is important to clean up the workflow runs using the below command

```ShellSession
for run_id in $(gh run list --limit 100 --json databaseId -q '.[].databaseId'); do gh run delete $run_id --repo CTLLAW-Org/demo-open-source; done
```

After clean-up is performed there should be only one run per workflow in the dashboard, to achieve this it is necessary, to create a last PR and merge it, in the master branch.

In this way We can effectively review only the last run of each workflow, to evaluate the current progress, and identify when we can stop to clean up the workflow runs.
