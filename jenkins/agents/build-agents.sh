#!/usr/bin/env bash

###############################################################################
# Build and publish a Jenkins agent image.
#
# Usage:
#   ./build-agents.sh <dockerhub-username> <dockerhub-access-token> <agent-name> <version>
#
# Example:
#   ./build-agents.sh smit9924 dckr_pat_xxxxxxxxx node 1.0.0
#
# Expected directory structure:
#
# agents/
# ├── VERSION
# ├── build-agents.sh
# ├── Dockerfile.node
# ├── Dockerfile.python
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Validate arguments
###############################################################################

if [[ $# -ne 4 ]]; then
    cat <<EOF
Usage:
  $0 <dockerhub-username> <dockerhub-access-token> <agent-name> <version>

Supported agent names:
  node
  python
EOF
    exit 1
fi

DOCKERHUB_USERNAME="$1"
DOCKERHUB_ACCESS_TOKEN="$2"
AGENT_NAME="$3"
VERSION="$4"

###############################################################################
# Repository configuration
###############################################################################

IMAGE_NAME="hospitia-jenkins-agent"

###############################################################################
# Map agent name -> Dockerfile
###############################################################################

declare -A DOCKERFILES=(
    ["node"]="Dockerfile.node"
    ["python"]="Dockerfile.python"
)

DOCKERFILE="${DOCKERFILES[$AGENT_NAME]:-}"

if [[ -z "${DOCKERFILE}" ]]; then
    echo "Unsupported agent: ${AGENT_NAME}"
    exit 1
fi

if [[ ! -f "${DOCKERFILE}" ]]; then
    echo "Dockerfile not found: ${DOCKERFILE}"
    exit 1
fi

###############################################################################
# Image tags
###############################################################################

IMAGE="${DOCKERHUB_USERNAME}/${IMAGE_NAME}"

VERSION_TAG="${AGENT_NAME}-${VERSION}"
LATEST_TAG="${AGENT_NAME}-latest"

###############################################################################
# Login to Docker Hub
###############################################################################

echo "Logging into Docker Hub..."

echo "${DOCKERHUB_ACCESS_TOKEN}" \
    | docker login \
        --username "${DOCKERHUB_USERNAME}" \
        --password-stdin

###############################################################################
# Build image
###############################################################################

echo
echo "Building image..."

docker build \
    --pull \
    --file "${DOCKERFILE}" \
    --tag "${IMAGE}:${VERSION_TAG}" \
    --tag "${IMAGE}:${LATEST_TAG}" \
    .

###############################################################################
# Push image tags
###############################################################################

echo
echo "Pushing ${IMAGE}:${VERSION_TAG}..."
docker push "${IMAGE}:${VERSION_TAG}"

echo
echo "Pushing ${IMAGE}:${LATEST_TAG}..."
docker push "${IMAGE}:${LATEST_TAG}"

###############################################################################
# Summary
###############################################################################

echo
echo "Successfully published:"
echo
echo "  ${IMAGE}:${VERSION_TAG}"
echo "  ${IMAGE}:${LATEST_TAG}"