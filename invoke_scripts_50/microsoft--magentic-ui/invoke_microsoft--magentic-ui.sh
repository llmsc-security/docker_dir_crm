#!/bin/bash
# =============================================================================
# Invoke script for microsoft--magentic-ui Docker Container
# =============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_NAME="microsoft--magentic-ui"
REPO_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/${REPO_NAME}"
BASE_LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs"
INVOKE_LOG="${SCRIPT_DIR}/invoke.log"
BUILD_LOG="${BASE_LOG_DIR}/${REPO_NAME}.build.log"

# Port mapping from port_mapping_50_gap10_3.json
# microsoft--magentic-ui: 11240
HOST_PORT=11240
CONTAINER_PORT=8081
IMAGE_NAME="microsoft--magentic-ui_image"
CONTAINER_NAME="microsoft--magentic-ui_container"

# =============================================================================
# Logging setup
# =============================================================================
mkdir -p "$(dirname "${INVOKE_LOG}")"
mkdir -p "$(dirname "${BUILD_LOG}")"

# =============================================================================
# Functions
# =============================================================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=========================================="
log "  microsoft--magentic-ui Docker Invoke Script"
log "=========================================="

# =============================================================================
# Step 1: Build the Docker image
# =============================================================================
log "Step 1: Building Docker image..."

cd "${REPO_DIR}"

# Build the image and log output
docker build -t "${IMAGE_NAME}" . > "${BUILD_LOG}" 2>&1
BUILD_EXIT_CODE=$?

if [ ${BUILD_EXIT_CODE} -ne 0 ]; then
    log "ERROR: Docker build failed. Check ${BUILD_LOG} for details."
    echo "ERROR: Docker build failed. Check ${BUILD_LOG} for details." > "${INVOKE_LOG}"
    exit 1
fi

log "Step 1: Docker image built successfully."
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Docker image built successfully." >> "${INVOKE_LOG}"

# =============================================================================
# Step 2: Stop and remove existing container
# =============================================================================
log "Step 2: Cleaning up existing container..."

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log "Stopping existing container..."
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true

    log "Removing existing container..."
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
    log "Existing container removed."
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Existing container removed." >> "${INVOKE_LOG}"
else
    log "No existing container found."
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] No existing container found." >> "${INVOKE_LOG}"
fi

# =============================================================================
# Step 3: Start new container
# =============================================================================
log "Step 3: Starting new container..."

docker run -d \
    --name "${CONTAINER_NAME}" \
    -p "${HOST_PORT}:${CONTAINER_PORT}" \
    --restart unless-stopped \
    -v "${REPO_DIR}/src:/workspace/src:ro" \
    -e OPENAI_API_KEY="${OPENAI_API_KEY:-}" \
    "${IMAGE_NAME}" > /dev/null 2>&1

log "Step 3: Container started."
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Container started on port ${HOST_PORT}." >> "${INVOKE_LOG}"

# =============================================================================
# Step 4: Wait for service to be ready
# =============================================================================
log "Step 4: Waiting for service to be ready..."

sleep 5

# Check if service is running
for i in {1..15}; do
    if curl -s "http://127.0.0.1:${HOST_PORT}" > /dev/null 2>&1; then
        log "Service is ready at http://127.0.0.1:${HOST_PORT}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Service is ready at http://127.0.0.1:${HOST_PORT}" >> "${INVOKE_LOG}"
        break
    fi
    log "Waiting for service... (${i}/15)"
    sleep 2
done

# =============================================================================
# Summary
# =============================================================================
log "=========================================="
log "  microsoft--magentic-ui Deployment Complete"
log "=========================================="
log "Container: ${CONTAINER_NAME}"
log "Image: ${IMAGE_NAME}"
log "URL: http://127.0.0.1:${HOST_PORT}"
log "Logs: ${INVOKE_LOG}"
log "Build log: ${BUILD_LOG}"
log "=========================================="

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deployment complete. Service available at http://127.0.0.1:${HOST_PORT}" >> "${INVOKE_LOG}"
