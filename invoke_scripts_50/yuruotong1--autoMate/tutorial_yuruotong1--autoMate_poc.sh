#!/bin/bash
# Tutorial PoC script for yuruotong1--autoMate
# This demonstrates how to use the autoMate Docker container

set -e

REPO_NAME="yuruotong1--automate"
HOST_PORT=11020
CONTAINER_PORT=7888
HOST="localhost"

echo "============================================"
echo "autoMate Docker Tutorial PoC"
echo "============================================"
echo ""
echo "This script demonstrates the autoMate AI automation tool"
echo "running in a Docker container."
echo ""

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Step 1: Check if image exists
log "Step 1: Checking for Docker image..."
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "${REPO_NAME}"; then
    log "Docker image found: ${REPO_NAME}"
else
    log "Docker image not found. Building..."
    cd /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/yuruotong1--autoMate
    docker build -t "${REPO_NAME}" .
    log "Build complete"
fi

# Step 2: Start container
log "Step 2: Starting container..."
if docker ps --format '{{.Names}}' | grep -q "${REPO_NAME}"; then
    log "Container is already running"
else
    log "Starting new container..."
    docker run -d \
        --name "${REPO_NAME}" \
        -p ${HOST_PORT}:${CONTAINER_PORT} \
        --rm \
        "${REPO_NAME}" || {
            log "Failed to start container"
            exit 1
        }
    log "Container started"
fi

# Step 3: Wait for service to be ready
log "Step 3: Waiting for service to be ready..."
MAX_RETRIES=20
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://$HOST:$HOST_PORT/ > /dev/null 2>&1; then
        log "Service is ready!"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    log "Waiting... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 3
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    log "ERROR: Service failed to start"
    exit 1
fi

# Step 4: Test basic endpoints
log "Step 4: Testing HTTP endpoints..."

# Test root endpoint
log "Testing root endpoint..."
ROOT_RESPONSE=$(curl -s http://$HOST:$HOST_PORT/)
if [ -n "$ROOT_RESPONSE" ]; then
    log "Root endpoint response: OK (${#ROOT_RESPONSE} bytes)"
else
    log "Root endpoint: No response"
fi

# Check if the response contains expected Gradio content
if echo "$ROOT_RESPONSE" | grep -qi "gradio"; then
    log "Gradio interface detected"
fi

# Step 5: Display connection info
echo ""
echo "============================================"
echo "Connection Information"
echo "============================================"
echo "Host: http://${HOST}:${HOST_PORT}"
echo "Container Port: ${CONTAINER_PORT}"
echo "Service: autoMate Gradio Web Interface"
echo ""
echo "Usage:"
echo "  - Open http://${HOST}:${HOST_PORT} in your browser"
echo "  - Configure your API key in the settings panel"
echo "  - Use natural language to describe automation tasks"
echo ""
echo "Container Status:"
docker ps --filter "name=${REPO_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "To stop the container, run: docker stop ${REPO_NAME}"
echo "============================================"

# Step 6: Cleanup option
log "Step 6: Cleanup option..."
echo ""
echo "When finished, you can stop the container with:"
echo "  docker stop ${REPO_NAME}"
echo ""
echo "Or run this command to stop immediately:"
echo "  docker stop ${REPO_NAME}"
echo ""
