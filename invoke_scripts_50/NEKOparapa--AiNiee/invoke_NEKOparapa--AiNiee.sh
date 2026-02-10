#!/bin/bash
# Invoke script for NEKOparapa--AiNiee
# Tests the HTTP service endpoint

set -e

REPO_NAME="NEKOparapa--AiNiee"
IMAGE_NAME="nekoparapa--ainenie_image"
CONTAINER_NAME="nekoparapa--ainenie_container"
PORT=11460
HOST="localhost"
CONTAINER_PORT=3388

echo "============================================"
echo "Testing NEKOparapa--AiNiee on port $PORT"
echo "============================================"

# Create log directory if not exists
LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/${REPO_NAME}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/invoke.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if container is running
log "Checking if container is running..."
if docker ps --format '{{.Names}}' | grep -q "${CONTAINER_NAME}"; then
    log "Container ${CONTAINER_NAME} is already running"
else
    log "Starting container for ${REPO_NAME}..."
    # Stop and remove existing container if it exists
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
    docker run -d \
        --name "${CONTAINER_NAME}" \
        -p ${PORT}:${CONTAINER_PORT} \
        -e PYTHONUNBUFFERED=1 \
        --rm \
        "${IMAGE_NAME}:latest" || {
            log "Failed to start container"
            exit 1
        }
    sleep 5
    log "Container started"
fi

# Test HTTP service
log "Testing HTTP service on port $PORT..."
MAX_RETRIES=10
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://$HOST:$PORT/ > /dev/null 2>&1; then
        log "HTTP service is running on port $PORT"
        curl -s http://$HOST:$PORT/ >> "$LOG_FILE" 2>&1
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
if curl -s http://$HOST:$PORT/health > /dev/null 2>&1; then
    log "Health endpoint test: OK"
    curl -s http://$HOST:$PORT/health >> "$LOG_FILE" 2>&1
else
    log "Health endpoint not available (optional)"
fi

log "============================================"
log "All tests passed for ${REPO_NAME}"
log "============================================"
