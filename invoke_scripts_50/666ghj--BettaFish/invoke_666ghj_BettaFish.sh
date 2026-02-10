#!/bin/bash
# Build and run script for 666ghj--BettaFish Docker container
# Port mapping: 11370 (host) -> 5000 (container)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Docker image name (lowercase)
IMAGE_NAME="666ghj-bettafish-image"
CONTAINER_NAME="666ghj-bettafish-container"

# Build the Docker image
echo "Building Docker image: ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/666ghj--BettaFish" 2>&1 | tee /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs/666ghj-BettaFish.build.log

# Stop and remove existing container if exists
echo "Stopping and removing existing container..."
docker stop "${CONTAINER_NAME}" 2>/dev/null || true
docker rm "${CONTAINER_NAME}" 2>/dev/null || true

# Run the Docker container
echo "Starting Docker container..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    -p 11370:5000 \
    -e FLASK_ENV=${FLASK_ENV:-} -e SECRET_KEY=${SECRET_KEY:-} \
    --restart unless-stopped \
    "${IMAGE_NAME}"

echo "Container started. HTTP service accessible at http://localhost:11370"
