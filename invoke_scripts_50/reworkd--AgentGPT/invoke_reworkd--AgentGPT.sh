#!/bin/bash
# Invoke script for reworkd--AgentGPT
# Tests the HTTP service endpoint

set -e

REPO_NAME="reworkd--AgentGPT"
DOCKER_IMAGE="reworkd--agentgpt_image"
HOST="localhost"
HOST_PORT=11230
CONTAINER_PORT=11230

echo "============================================"
echo "Testing reworkd--AgentGPT on port $HOST_PORT"
echo "============================================"

# Create log directories
LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/${REPO_NAME}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/invoke.log"
BUILD_LOG="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs/reworkd--AgentGPT.build.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Stop and remove existing container
log "Stopping existing container..."
docker stop "${REPO_NAME}_container" 2>/dev/null || true
docker rm "${REPO_NAME}_container" 2>/dev/null || true

# Build the Docker image
log "Building Docker image..."
cd "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/reworkd--AgentGPT" || exit 1

docker build -t "${DOCKER_IMAGE}:latest" . >> "$BUILD_LOG" 2>&1 || {
    log "ERROR: Docker build failed"
    tail -50 "$BUILD_LOG" >> "$LOG_FILE"
    exit 1
}
log "Docker image built successfully"

# Run the container
log "Starting container for ${REPO_NAME}..."
docker run -d \
    --name "${REPO_NAME}_container" \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    -e OPENAI_API_KEY="11" \
    -e OPENAI_API_BASE_URL="http://157.10.162.82:443/v1/" \
    -e GPT_MODEL="gpt-5.1" \
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

# Test health endpoint
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
