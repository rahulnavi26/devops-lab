#!/usr/bin/env bash
# Runs the SonarQube scan and WAITS for the quality gate. Skips if no server is configured.
set -euo pipefail
cd "$(dirname "$0")/../.."
if [[ -z "${SONAR_HOST_URL:-}" || -z "${SONAR_TOKEN:-}" ]]; then
  echo "SONAR_HOST_URL / SONAR_TOKEN not set - skipping SonarQube analysis."
  exit 0
fi
VERSION="${IMAGE_TAG:-$(git rev-parse --short=7 HEAD 2>/dev/null || echo local)}"
if command -v sonar-scanner >/dev/null; then
  sonar-scanner "-Dsonar.host.url=${SONAR_HOST_URL}" "-Dsonar.token=${SONAR_TOKEN}" "-Dsonar.projectVersion=${VERSION}"
else
  docker run --rm --network host -e SONAR_HOST_URL -e SONAR_TOKEN \
    -v "$PWD:/usr/src" sonarsource/sonar-scanner-cli:latest "-Dsonar.projectVersion=${VERSION}"
fi
