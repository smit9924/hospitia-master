#!/usr/bin/env bash

# Create Docker network for all containers involved in the development setup
NETWORK_NAME="dev-net"

echo "🔍 Checking Docker network: $NETWORK_NAME"

if docker network ls --format '{{.Name}}' | grep -q "^${NETWORK_NAME}$"; then
    echo "Docker network '$NETWORK_NAME' already exists. Skipping creation."
else
    echo "Creating Docker network '$NETWORK_NAME'..."
    docker network create "$NETWORK_NAME"
    echo "Network '$NETWORK_NAME' created successfully."
fi
# end docker network creation


# Whitelist the frontend and backend repositories
# to prevent Git from prompting for trust each time the devcontainer is rebuilt.
git config --global --add safe.directory /workspace/ && git config --global --add safe.directory /workspace/frontend && git config --global --add safe.directory /workspace/backend

# Create .env files from .sample.env files
cp backend/services/auth/.sample.env backend/services/auth/.env
cp backend/services/notification/.sample.env backend/services/notification/.env

