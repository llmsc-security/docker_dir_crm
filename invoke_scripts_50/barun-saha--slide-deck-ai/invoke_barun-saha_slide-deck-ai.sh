#!/bin/bash
# Build and run script for barun-saha--slide-deck-ai Docker container
# Port mapping: 11410 (host) -> 8501 (container)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Docker image name
IMAGE_NAME="barun-saha_slide-deck-ai_image"
CONTAINER_NAME="barun-saha_slide-deck-ai_container"

# Build the Docker image
echo "Building Docker image: ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/barun-saha--slide-deck-ai" 2>&1 | tee /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs/barun-saha_slide-deck-ai.build.log

# Stop and remove existing container if exists
echo "Stopping and removing existing container..."
docker stop "${CONTAINER_NAME}" 2>/dev/null || true
docker rm "${CONTAINER_NAME}" 2>/dev/null || true

# Run the Docker container
echo "Starting Docker container..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    -p 11410:8501 \
     \
    --restart unless-stopped \
    "${IMAGE_NAME}"

echo "Container started. HTTP service accessible at http://localhost:11410"
