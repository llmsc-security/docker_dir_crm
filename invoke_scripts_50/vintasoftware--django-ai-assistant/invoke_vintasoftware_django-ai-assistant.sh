#!/bin/bash
# Build and run script for vintasoftware--django-ai-assistant Docker container
# Port mapping: 11140 (host) -> 8000 (container)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Docker image name
IMAGE_NAME="vintasoftware_django-ai-assistant_image"
CONTAINER_NAME="vintasoftware_django-ai-assistant_container"

# Build the Docker image
echo "Building Docker image: ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/vintasoftware--django-ai-assistant" 2>&1 | tee /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs/vintasoftware_django-ai-assistant.build.log

# Stop and remove existing container if exists
echo "Stopping and removing existing container..."
docker stop "${CONTAINER_NAME}" 2>/dev/null || true
docker rm "${CONTAINER_NAME}" 2>/dev/null || true

# Run the Docker container
echo "Starting Docker container..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    -p 11140:8000 \
    -e DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY:-} \
    --restart unless-stopped \
    "${IMAGE_NAME}"

echo "Container started. HTTP service accessible at http://localhost:11140"
