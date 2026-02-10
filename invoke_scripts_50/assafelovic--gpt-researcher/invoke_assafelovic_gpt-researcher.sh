#!/bin/bash
# Build and run script for assafelovic--gpt-researcher Docker container
# Port mapping: 11250 (host) -> 11250 (container)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Docker image name
IMAGE_NAME="assafelovic_gpt-researcher_image"
CONTAINER_NAME="assafelovic_gpt-researcher_container"

# Build the Docker image
echo "Building Docker image: ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/assafelovic--gpt-researcher" 2>&1 | tee /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs/assafelovic_gpt-researcher.build.log

# Stop and remove existing container if exists
echo "Stopping and removing existing container..."
docker stop "${CONTAINER_NAME}" 2>/dev/null || true
docker rm "${CONTAINER_NAME}" 2>/dev/null || true

# Run the Docker container
echo "Starting Docker container..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    -p 11250:11250 \
    -e OPENAI_API_KEY=${OPENAI_API_KEY:-} -e TAVILY_API_KEY=${TAVILY_API_KEY:-} \
    --restart unless-stopped \
    "${IMAGE_NAME}"

echo "Container started. HTTP service accessible at http://localhost:11250"
