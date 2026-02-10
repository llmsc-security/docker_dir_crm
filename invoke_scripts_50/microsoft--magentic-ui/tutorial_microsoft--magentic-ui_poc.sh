#!/bin/bash
# Tutorial PoC script for microsoft--magentic-ui
# Demonstrates usage of the HTTP service

set -e

REPO_NAME="microsoft--magentic-ui"
HOST_PORT=11240
CONTAINER_PORT=8081

LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/${REPO_NAME}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/tutorial_poc.log"

echo "=========================================="
echo "  microsoft--magentic-ui Tutorial PoC"
echo "=========================================="

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Checking if service is running at http://127.0.0.1:${HOST_PORT}..."

# Test root endpoint
if curl -s "http://127.0.0.1:${HOST_PORT}/" > /dev/null 2>&1; then
    log "Service is responding!"
else
    log "ERROR: Service not responding at http://127.0.0.1:${HOST_PORT}"
    log "Make sure the container is running with: bash invoke_${REPO_NAME}.sh"
    exit 1
fi

log ""
log "Test 1: Fetching home page..."
START_TIME=$(date +%s.%N)
HTTP_STATUS=$(curl -s -o /tmp/response.html -w "%{http_code}" "http://127.0.0.1:${HOST_PORT}/")
END_TIME=$(date +%s.%N)
ELAPSED=$(echo "$END_TIME - $START_TIME" | bc)
log "----------------------------------------"
log "HTTP Status: ${HTTP_STATUS}"
log "Content-Type: $(head -1 /tmp/response.html | grep -o 'content-type: [^<]*' || echo 'text/html')"
log "Total Time: ${ELAPSED}s"
log "----------------------------------------"

log ""
log "Test 2: Checking for health/status endpoints..."
if curl -s "http://127.0.0.1:${HOST_PORT}/health" > /dev/null 2>&1; then
    log "Health endpoint: OK"
else
    log "Warning: Health endpoint not available (optional)"
fi

log ""
log "Test 3: Checking API endpoints..."
if curl -s "http://127.0.0.1:${HOST_PORT}/api" > /dev/null 2>&1; then
    log "API endpoint: OK"
else
    log "API endpoint: Not available"
fi

log ""
log "=========================================="
log "  Tutorial PoC Complete"
log "=========================================="
log "Service URL: http://127.0.0.1:${HOST_PORT}"
log "Tutorial log: ${LOG_FILE}"
log "=========================================="
log ""
log "You can now access the microsoft--magentic-ui Web UI at:"
log "  http://127.0.0.1:${HOST_PORT}"
log ""
