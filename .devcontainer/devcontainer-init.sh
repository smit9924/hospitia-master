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
