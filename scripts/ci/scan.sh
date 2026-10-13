#!/usr/bin/env bash
# Trivy image scan. Fails the pipeline on fixable HIGH/CRITICAL vulnerabilities.
set -euo pipefail
source "$(dirname "$0")/common.sh"
cd "$(dirname "$0")/../.."
TRIVY_VERSION="${TRIVY_VERSION:-0.58.1}"
mkdir -p reports

trivy_run() {
  if command -v trivy >/dev/null; then
    trivy "$@"
  else
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache \
      "aquasec/trivy:${TRIVY_VERSION}" "$@"
  fi
}

TARGET="${IMAGE_NAME}:${IMAGE_TAG}"
echo "== Saving a full JSON report (never fails) =="
trivy_run image --quiet --format json --exit-code 0 "$TARGET" > reports/trivy.json
echo "== Gate: fixable HIGH/CRITICAL findings fail the build =="
trivy_run image --quiet --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 "$TARGET"
