#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
REG="$(registry)"
case "$CLOUD" in
  aws)       aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REG" ;;
  azure)     printf '%s' "${ACR_PASSWORD:?}" | docker login "$ACR_LOGIN_SERVER" -u "${ACR_USERNAME:?}" --password-stdin ;;
  dockerhub) printf '%s' "${DOCKERHUB_TOKEN:?}" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin ;;
esac
REF="$(image_ref)"
docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "$REF"
docker push "$REF"
echo "Pushed $REF"
