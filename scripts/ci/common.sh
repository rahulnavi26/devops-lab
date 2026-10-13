#!/usr/bin/env bash
# Shared helpers for every pipeline (GitHub Actions, Jenkins, Azure Pipelines).
# Environment contract:
#   CLOUD = aws | azure | dockerhub
#   aws:       AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION
#   azure:     ACR_LOGIN_SERVER, ACR_USERNAME, ACR_PASSWORD
#   dockerhub: DOCKERHUB_USERNAME, DOCKERHUB_TOKEN
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-devops-lab}"
CLOUD="${CLOUD:-aws}"
AWS_REGION="${AWS_REGION:-ap-south-1}"
IMAGE_TAG="${IMAGE_TAG:-$(git rev-parse --short=7 HEAD 2>/dev/null || echo local)}"
export IMAGE_NAME CLOUD AWS_REGION IMAGE_TAG

registry() {
  case "$CLOUD" in
    aws)       echo "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com" ;;
    azure)     echo "${ACR_LOGIN_SERVER:?ACR_LOGIN_SERVER is required}" ;;
    dockerhub) echo "docker.io/${DOCKERHUB_USERNAME:?DOCKERHUB_USERNAME is required}" ;;
    *) echo "Unknown CLOUD '$CLOUD' (use aws, azure or dockerhub)" >&2; return 1 ;;
  esac
}

image_ref() { echo "$(registry)/${IMAGE_NAME}:${IMAGE_TAG}"; }
