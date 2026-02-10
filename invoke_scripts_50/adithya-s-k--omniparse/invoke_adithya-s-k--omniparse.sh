#!/bin/bash
# Invoke script for adithya-s-k--omniparse
# Tests the HTTP service endpoint

set -e

REPO_NAME="adithya-s-k--omniparse"
PORT=11090
HOST="localhost"

echo "============================================"
echo "Testing adithya-s-k--omniparse on port $PORT"
echo "============================================"

# Create log directory if not exists
LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/${REPO_NAME}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/invoke.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

REPO_NAME="adithya-s-k--omniparse"
DOCKER_IMAGE="adithya-s-k--omniparse"
HOST="localhost"
HOST_PORT=11090
CONTAINER_PORT=8000

echo "============================================"
echo "Testing adithya-s-k--omniparse on port $HOST_PORT"
echo "============================================"

# Create log directory if not exists
LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/${REPO_NAME}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/invoke.log"
BUILD_LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs"
mkdir -p "$BUILD_LOG_DIR"
BUILD_LOG="$BUILD_LOG_DIR/${REPO_NAME}.build.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Stop and remove existing container if present
log "Stopping existing container if present..."
docker stop "${REPO_NAME}" 2>/dev/null || true
docker rm "${REPO_NAME}" 2>/dev/null || true

# Build the Docker image
log "Building Docker image..."
cd "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/${REPO_NAME}" || exit 1

docker build -t "${DOCKER_IMAGE}:latest" . >> "$BUILD_LOG" 2>&1 || {
    log "ERROR: Docker build failed"
    tail -50 "$BUILD_LOG" >> "$LOG_FILE"
    exit 1
}
log "Docker image built successfully"

# Run the container
log "Starting container for ${REPO_NAME}..."
docker run -d \
    --name "${REPO_NAME}" \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    --rm \
    "${DOCKER_IMAGE}:latest" || {
    log "Failed to start container"
    exit 1
}
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

