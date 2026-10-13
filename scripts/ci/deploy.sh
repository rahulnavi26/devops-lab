#!/usr/bin/env bash
# Deploys the pushed image to the Kubernetes (k3s) VM using Ansible over SSH.
# Needs: DEPLOY_HOST (VM public IP), SSH_KEY_FILE (private key path), optional DEPLOY_USER (default ubuntu)
set -euo pipefail
source "$(dirname "$0")/common.sh"
cd "$(dirname "$0")/../.."
: "${DEPLOY_HOST:?Set DEPLOY_HOST to the VM public IP (terraform output public_ip)}"
: "${SSH_KEY_FILE:?Set SSH_KEY_FILE to the private key path}"

if ! command -v ansible-playbook >/dev/null; then
  python3 -m venv .ci/venv
  .ci/venv/bin/pip install --quiet ansible-core
  export PATH="$PWD/.ci/venv/bin:$PATH"
fi

IMAGE="$(image_ref)"
case "$CLOUD" in
  aws)       export REGISTRY_USER=AWS; REGISTRY_PASSWORD="$(aws ecr get-login-password --region "$AWS_REGION")"; REGISTRY_SERVER="$(registry)" ;;
  azure)     export REGISTRY_USER="${ACR_USERNAME:?}"; REGISTRY_PASSWORD="${ACR_PASSWORD:?}"; REGISTRY_SERVER="$ACR_LOGIN_SERVER" ;;
  dockerhub) export REGISTRY_USER=""; REGISTRY_PASSWORD=""; REGISTRY_SERVER="docker.io" ;;  # public repo: no pull secret
esac
export REGISTRY_SERVER REGISTRY_PASSWORD REGISTRY_USER

cd ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "${DEPLOY_HOST}," \
  -u "${DEPLOY_USER:-ubuntu}" --private-key "$SSH_KEY_FILE" \
  deploy.yml -e "image=${IMAGE}" -e "image_tag=${IMAGE_TAG}"
echo "Deployed ${IMAGE} -> http://${DEPLOY_HOST}:30080"
