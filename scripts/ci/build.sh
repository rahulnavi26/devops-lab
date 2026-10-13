#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
cd "$(dirname "$0")/../.."
docker build --pull --build-arg "APP_VERSION=${IMAGE_TAG}" -t "${IMAGE_NAME}:${IMAGE_TAG}" app
echo "Built ${IMAGE_NAME}:${IMAGE_TAG}"
