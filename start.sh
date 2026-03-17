#! /bin/bash
set -euo pipefail
sudo chown root:docker /var/run/docker.sock

: "${RUNNER_TOKEN:?RUNNER_TOKEN environment variable is required}"
: "${REPO:?REPO environment variable is required}"
RUNNER_NAME="${RUNNER_NAME:-dockerized-runner-$(hostname)}"

cd /home/dev/actions-runner
./config.sh \
    --url "${REPO}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --unattended \
    --replace

cleanup() {
    echo "Deregistering runner..."
    ./config.sh remove --token "${RUNNER_TOKEN}" || true
}
trap cleanup SIGTERM SIGINT

./run.sh &
wait $!