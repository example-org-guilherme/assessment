Hey there!

This project is composed the following way:

- **repos** - contains the repositories that comprise the test
  - **gha-workflow** - reusable workflows (release and update-submodules workflows)
  - **application** - "application" repository using the workflows above and using 3 submodules
  - **submodule-x** - repositories representing submodule examples

- **terraform** 
  - terraform code to create the repositories along with anything needed to get the test up and running
  - Requires only a test org and a PAT key with **read-write** in the following areas: Actions, Workflows, Administration, Contents, Pull Requests, Secrets, Workflows

- **Dockerfile** used to build everything in a easy-to-use container

## Setting up 

```bash
export TF_VAR_owner="<YOUR_TEST_ORG_HERE>"
export TF_VAR_token="<YOUR_TEST_ORG_PAT_HERE>" # with **read-write** in the following areas: Actions, Workflows, Administration, Contents, Pull Requests, Secrets, Workflows

make up
```

With this you should be ready to hop on to the `application` repository's actions and manually trigger the `Release` and `Update Submodules` actions.

## Testing

Suggested test flow:

- Go to the `application` repository actions page
  - Trigger a **Release** workflow manually
  - Verify that a release is created (0.1.0) along with its branch
  - Trigger a **Update Submodules** workflow manually
  - Verify that nothing is done (no submodule updated yet)
    - Check the job summary to confirm
- Go to the `submodule-a` repository
  - Edit any file into the main branch and commit it
- Go to the `application` repository actions page
  - Trigger a **Update Submodules** workflow manually
  - Verify that a PR is created to update the `submodule-a`
  - Verify that I am requested as a reviewer
  - Open the PR and merge it
  - Trigger a **Release** workflow manually
  - Verify that a release is created (0.2.0) along with its branch


## Notes

- The workflow is also configured to run on a schedule, but you may trigger it manually for testing and contingency purposes
- Branch protection rules are not being used for the sake of simplicirty
- Ideally we would tag reusable workflows with v<major> tags as an umbrella for a given stable version, instead of using main
- The github scheduler can be VERY unreliable ! [example](github-actions-schedule-example.png) (this was set to run every 3 minutes!)
  - More details here: https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule
- We have levereged a lot of code from the Github Actions community with their community actions :)