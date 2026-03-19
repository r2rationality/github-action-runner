#! /bin/bash
set -euo pipefail
sudo chown root:docker /var/run/docker.sock

: "${RUNNER_TOKEN:?RUNNER_TOKEN environment variable is required}"
: "${RUNNER_WORKDIR:?RUNNER_WORKDIR environment variable is required}"
: "${REPO:?REPO environment variable is required}"
RUNNER_NAME="${RUNNER_NAME:-dockerized-runner-$(hostname)}"

cd /home/dev/actions-runner
./config.sh \
    --url "${REPO}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --workdir "${RUNNER_WORKDIR}" \
    --unattended \
    --replace

cleanup() {
    echo "Deregistering runner..."
    kill "$RUNNER_PID" 2>/dev/null
    wait "$RUNNER_PID" 2>/dev/null
    ./config.sh remove --token "${RUNNER_TOKEN}" || true
}
trap cleanup SIGTERM SIGINT

./run.sh &
RUNNER_PID=$!
wait RUNNER_PID