### Build the runner
1. Request a new runner token from GitHub
2. Put it into the .token file
3. Build the container
   ```bash
   docker build -t ga-runner .
   ```

### Start the runner
```bash
docker run \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e RUNNER_TOKEN=<token> \
  -e RUNNER_WORKDIR=/tmp/runner \
  -e REPO=https://github.com/org/repo \
  ga-runner
```

Notes:
- running the container without --rm flag insures that the runner's data is kept between restarts