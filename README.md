### Build the runner
```bash
docker build -t ga-runner .
```

### Configure access for multiple repositories

1. In your GitHub organization's **Settings > Actions > Runners**, choose
   **New runner > New self-hosted runner**, then select Linux and x64.
2. Copy the registration token from the generated configuration command.
   Use an organization registration token, which expires after one hour.
3. Under **Settings > Actions > Runner groups**, open the **Default** group
   and configure repository access for the repositories that should use this
   runner. This script registers organization runners in the default group.

See GitHub's instructions for [adding an organization runner](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners#adding-a-self-hosted-runner-to-an-organization)
and [managing repository access](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/manage-access#changing-which-repositories-can-access-a-runner-group).

### Start the runner
```bash
docker run \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e RUNNER_NAME=your-ci-1 \
  -e RUNNER_TOKEN='YOUR_ORGANIZATION_REGISTRATION_TOKEN' \
  -e RUNNER_WORKDIR=/tmp/runner \
  -e RUNNER_URL=https://github.com/YOUR_ORGANIZATION \
  ga-runner
```

In each allowed repository, target the runner's default labels in the relevant
workflow jobs:

```yaml
jobs:
  build:
    runs-on: [self-hosted, linux, x64]
    steps:
      - run: echo "Running on a shared organization runner"
```

Any accessible runner with these labels can receive these jobs. One runner
executes one job at a time; GitHub controls assignment across repositories.
This setup does not enforce round-robin or FIFO scheduling.

### Repository-level runners and compatibility

To register for a single repository, use
`RUNNER_URL=https://github.com/OWNER/REPOSITORY` with a registration token from
that repository's settings. The legacy `REPO` environment variable is still
accepted when `RUNNER_URL` is unset or empty. A nonempty `RUNNER_URL` takes
precedence over `REPO`.

When migrating an existing repository runner to organization scope, stop the old
container and create a fresh container with the organization URL and token.
Changing the URL does not migrate the registration stored in an existing
container. Remove the old repository runner entry in GitHub if it remains.

Running the container without `--rm` retains its filesystem after it stops.
