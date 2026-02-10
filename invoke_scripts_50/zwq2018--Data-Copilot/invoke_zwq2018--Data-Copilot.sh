#!/bin/bash
# Invoke script for zwq2018--Data-Copilot
set -e

REPO_NAME="zwq2018--Data-Copilot"
DOCKER_IMAGE="zwq2018-data-copilot_image"
HOST_PORT=11440
CONTAINER_PORT=7860
HOST="localhost"

echo "============================================"
echo "Testing zwq2018--Data-Copilot on port $HOST_PORT"
echo "============================================"

# Create log directory if not exists
LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/${REPO_NAME}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/invoke.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Build the Docker image
log "Building Docker image..."
cd "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/${REPO_NAME}"
docker build -t "${DOCKER_IMAGE}" . > "${LOG_DIR}/build.log" 2>&1
if [ $? -ne 0 ]; then
    log "ERROR: Docker build failed"
    exit 1
fi
log "Docker image built successfully"

# Stop and remove existing container
log "Cleaning up existing container..."
docker stop "${REPO_NAME}" 2>/dev/null || true
docker rm "${REPO_NAME}" 2>/dev/null || true

# Run new container
log "Starting container..."
docker run -d \
    --name "${REPO_NAME}" \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    --restart unless-stopped \
    "${DOCKER_IMAGE}"
sleep 5
log "Container started"

# Test HTTP service
log "Testing HTTP service on port $HOST_PORT..."
MAX_RETRIES=10
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://$HOST:$HOST_PORT/ > /dev/null 2>&1; then
        log "HTTP service is running on port $HOST_PORT"
        curl -s http://$HOST:$HOST_PORT/ >> "$LOG_FILE" 2>&1
        log "Root endpoint test: OK"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    log "Waiting for service to start... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 3
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    log "ERROR: Service failed to start within timeout"
    exit 1
fi

# Test health endpoint if available
log "Testing health endpoint..."
if curl -s http://$HOST:$HOST_PORT/health > /dev/null 2>&1; then
    log "Health endpoint test: OK"
    curl -s http://$HOST:$HOST_PORT/health >> "$LOG_FILE" 2>&1
else
    log "Health endpoint not available (optional)"
fi

log "============================================"
log "All tests passed for ${REPO_NAME}"
log "============================================"
