Hey there!

This project is composed the following way:

- **repos** - contains the repositories that comprise the test
  - **gha-workflow** - reusable workflows (release and update-submodules workflows)
  - **application** - "application" repository using the workflows above and using 3 submodules
  - **submodule-x** - repositories representing submodule examples

- **terraform** 
  - terraform code to create the repositories along with anything needed to get the test up and running
  - Requires only a test org and a PAT key with **read-write** in the following areas: Actions, Workflows, Administration, Contents, Pull Requests, Secrets, Workflows

- **Dockerfile** used to package everything in an easy-to-use container that terraforms the repositories

## Demo

This is a demonstration of it working end to end: https://youtu.be/YLyOy1eCN6g

## Requirements

- Requires a test Github organization
- Requires a test Github PAT for the organization, with the following read-write permissions: Actions, Workflows, Administration, Contents, Pull Requests, Secrets, Workflows
- Requires Docker to build/run the terraform container

## Setting up 

```bash
# Clone this project
git clone git@github.com:elevate-labs-with-guilherme/assessment.git
cd assessment

export TF_VAR_owner="<YOUR_TEST_ORG_HERE>"
export TF_VAR_token="<YOUR_TEST_ORG_PAT_HERE>" # with **read-write** in the following areas: Actions, Workflows, Administration, Contents, Pull Requests, Secrets, Workflows

make up # this will build the container & run terraform from it
```

After this is up, you have to [enable `Pull Request` creation from actions within the org](pull-request-config.png).

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
  - Verify that I am requested as a reviewer, [as configured here](https://github.com/elevate-labs-with-guilherme/assessment/blob/main/repos/application/.github/workflows/update-submodules.yaml#L19)
  - Open the PR and merge it
  - Trigger a **Release** workflow manually
  - Verify that a release is created (0.2.0) along with its branch


## Notes

- The workflows are also configured [to run on a schedule](https://github.com/elevate-labs-with-guilherme/assessment/blob/24c191b4ae52bb0700c27e95fdef566f09aeacba/repos/application/.github/workflows/update-submodules.yaml#L7C9-L7C36) ([and this one too](https://github.com/elevate-labs-with-guilherme/assessment/blob/24c191b4ae52bb0700c27e95fdef566f09aeacba/repos/application/.github/workflows/release.yaml#L7)), but you may trigger them manually for testing and contingency purposes
- Branch protection rules are not being used for the sake of simplicirty
- Ideally we would tag reusable workflows with v**major** (ex v1) tags as an umbrella for a given stable version, instead of using main
- The github scheduler can be VERY unreliable ! [example](github-actions-schedule-example.png) (this was set to run every 3 minutes!)
  - More details here: https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule
- We have levereged a lot of code from the Github Actions community with their community actions :)
