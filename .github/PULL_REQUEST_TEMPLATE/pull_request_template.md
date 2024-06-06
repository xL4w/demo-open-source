## Pull Request Title

Provide a clear and concise title summarizing the change (e.g., "Add user authentication feature" or "Fix bug in inventory calculation").

## Description

**What does this PR do?**

* Concisely describe the problem this pull request solves or the feature it adds.
* Explain the changes made in detail, including specific code modifications, new files, or configuration adjustments.
* Provide any relevant background information or context to help reviewers understand the changes.

**Specify whether this PR is related to Applications or Infrastructure changes.**

- [ ] **Applications**
- [ ] **Infrastructure**

**How was this tested?**

* Describe the testing strategy you used (e.g., unit tests, integration tests, manual testing).
* List the specific tests you ran to verify the correctness of your changes.
* If applicable, include any screenshots or other evidence of successful testing.

## Related Issues or Tickets

List any related issues or tickets (e.g., Jira tickets) that this pull request addresses.

* Jira Link: [https://nucleuslegalcloud.atlassian.net/browse/ID](https://nucleuslegalcloud.atlassian.net/browse/ID) (Replace `ID` with the actual Jira task associated with your PR.)

## Code Reviewers and Approval Process

**Important:**

* **Do not** manually assign additional reviewers. The system will automatically add the required reviewers based on the target branch and changes:
* **@ig-ctllaw-testing:** Required for all Application changes.
* **@4k4xs4pH1r3-2:** Required for all Infrastructure changes.
* **@CTLLaw:** Required for all changes targeting the `master` branch.

* **No other users are allowed to review or approve pull requests.**
* **Only @ig-ctllaw-testing and @CTLLaw** are authorized to create pull requests targeting the `staging` or `master` branches.

**Merging Policy:**

To maintain a controlled and secure deployment process, adhere to the following rules:

1. **Target Branch:** All pull requests **must** initially target the `aws-dev` branch. Any attempts to directly push to `master` or `staging` will be rejected.
2. **Approval Requirements:**
* **`aws-dev` (Applications):** Requires approval from **@ig-ctllaw-testing**.
* **`aws-dev` (Infrastructure):** Requires approval from **@4k4xs4pH1r3-2**.
* **`staging` (Applications):** Requires approval from **@ig-ctllaw-testing**.
* **`staging` (Infrastructure):** Requires approval from **@4k4xs4pH1r3-2**.
* **`master` (production):** After thorough testing on `staging`, a final PR from `staging` to `master` requires approval from **@CTLLaw**.

## Checklist for Contributors

Please confirm the following before submitting this PR:

- [ ] I have provided a detailed description of the changes and their purpose.
- [ ] I have thoroughly tested the changes (including unit tests, if applicable).
- [ ] I have not modified any existing migration files.
- [ ] My code is clean and well-formatted (no unnecessary files, comments, or logging).
- [ ] My function/method/property names are clear and descriptive.
- [ ] This PR targets the correct branch:
    - [ ] **`aws-dev`** for initial development and testing
    - [ ] **`staging`** after successful testing on `aws-dev`
    - [ ] **`master`** only after thorough testing on `staging` and with approval from @CTLLaw
