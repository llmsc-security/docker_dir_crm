#!/bin/bash
# Invoke script for mrwadams--attackgen
# Builds image, stops/removes existing container, and starts new container

set -e

# Absolute paths
REPO_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/mrwadams--attackgen"
SCRIPTS_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/mrwadams--attackgen"
BUILD_LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs"
BUILD_LOG="${BUILD_LOG_DIR}/mrwadams--attackgen.build.log"

# Port mapping from port_mapping_50_gap10_1.json
# mrwadams--attackgen maps to base port 11110
HOST_PORT=11110
CONTAINER_PORT=8500

# Docker image and container names (lowercase for compatibility)
IMAGE_NAME="mrwadams_attackgen_image"
CONTAINER_NAME="mrwadams_attackgen_container"

# Ensure directories exist
mkdir -p "${SCRIPTS_DIR}"
mkdir -p "${BUILD_LOG_DIR}"

# Function to log messages
log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg"
    echo "$msg" >> "${BUILD_LOG}"
}

# Start build log
log "============================================"
log "Starting build for mrwadams--attackgen"
log "============================================"

# Change to repo directory
cd "${REPO_DIR}"

# Build the Docker image
log "Building Docker image ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" . >> "${BUILD_LOG}" 2>&1
if [ $? -ne 0 ]; then
    log "ERROR: Docker build failed"
    exit 1
fi
log "Docker build completed successfully"

# Stop and remove existing container if it exists
log "Checking for existing container ${CONTAINER_NAME}..."
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log "Stopping existing container..."
    docker stop "${CONTAINER_NAME}" >> "${BUILD_LOG}" 2>&1 || true
    log "Removing existing container..."
    docker rm "${CONTAINER_NAME}" >> "${BUILD_LOG}" 2>&1 || true
fi

# Run the new container
log "Starting new container ${CONTAINER_NAME} on port ${HOST_PORT}..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    -e STREAMLIT_SERVER_HEADLESS="true" \
    --restart unless-stopped \
    "${IMAGE_NAME}" >> "${BUILD_LOG}" 2>&1

if [ $? -ne 0 ]; then
    log "ERROR: Failed to start container"
    exit 1
fi
log "Container started successfully"

# Wait for container to be ready
log "Waiting for service to be ready..."
sleep 10

# Test the endpoint
log "Testing HTTP endpoint..."
MAX_RETRIES=10
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s "http://127.0.0.1:${HOST_PORT}/" > /dev/null 2>&1; then
        log "HTTP endpoint is responding on port ${HOST_PORT}"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    log "Waiting for service... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 3
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    log "WARNING: Service may not be fully ready yet"
fi

log "============================================"
log "Build and run completed for mrwadams--attackgen"
log "Service available at http://127.0.0.1:${HOST_PORT}"
log "============================================"
