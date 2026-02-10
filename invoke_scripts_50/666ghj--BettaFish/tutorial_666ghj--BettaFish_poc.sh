#!/bin/bash
# tutorial_666ghj--BettaFish_poc.sh - Proof of concept script for BettaFish
# This script demonstrates how to use the deployed BettaFish service via curl

set -e

# Absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="${SCRIPT_DIR}"

# Port mapping from port_mapping_50_gap10_2.json
BASE_PORT=11370
HOST_PORT=${BASE_PORT}

# Ensure logs directory exists
mkdir -p "${LOGS_DIR}"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOGS_DIR}/tutorial_poc.log"
}

# Start logging
log "=== BettaFish PoC Tutorial ==="
log "Testing service at http://127.0.0.1:${HOST_PORT}/"

# Test 1: Check if service is responding
log ""
log "Test 1: Checking service health..."
log "Request: GET /"
HEALTH_RESPONSE=$(curl -s "http://127.0.0.1:${HOST_PORT}/" 2>&1)
HEALTH_EXIT_CODE=$?

if [ ${HEALTH_EXIT_CODE} -eq 0 ] && [ -n "${HEALTH_RESPONSE}" ]; then
    log "SUCCESS: Service is responding"
    log "Response status: HTTP 200"
    log "Response preview: ${HEALTH_RESPONSE:0:200}..."
else
    log "ERROR: Service is not responding"
    log "Please ensure the container is running: ./invoke_666ghj--BettaFish.sh"
    exit 1
fi

# Test 2: Check API status endpoint
log ""
log "Test 2: Checking API status endpoint..."
log "Request: GET /api/status"
STATUS_RESPONSE=$(curl -s "http://127.0.0.1:${HOST_PORT}/api/status" 2>&1)
STATUS_EXIT_CODE=$?

if [ ${STATUS_EXIT_CODE} -eq 0 ]; then
    log "SUCCESS: Status endpoint responded"
    log "Response: ${STATUS_RESPONSE}"
else
    log "ERROR: Status endpoint failed"
fi

# Test 3: Check config endpoint
log ""
log "Test 3: Checking configuration endpoint..."
log "Request: GET /api/config"
CONFIG_RESPONSE=$(curl -s "http://127.0.0.1:${HOST_PORT}/api/config" 2>&1)
CONFIG_EXIT_CODE=$?

if [ ${CONFIG_EXIT_CODE} -eq 0 ]; then
    log "SUCCESS: Config endpoint responded"
    # Pretty print the JSON response
    echo "${CONFIG_RESPONSE}" | head -c 500
    log "..."
else
    log "ERROR: Config endpoint failed"
fi

# Test 4: Check system status endpoint
log ""
log "Test 4: Checking system status..."
log "Request: GET /api/system/status"
SYS_STATUS_RESPONSE=$(curl -s "http://127.0.0.1:${HOST_PORT}/api/system/status" 2>&1)
log "Response: ${SYS_STATUS_RESPONSE}"

# Summary
log ""
log "=== PoC Tutorial Completed ==="
log "Service is accessible at: http://127.0.0.1:${HOST_PORT}/"
log "Full log: ${LOGS_DIR}/tutorial_poc.log"
echo ""
echo "BettaFish PoC completed successfully!"
echo "Access the web interface at: http://127.0.0.1:${HOST_PORT}/"
echo "Full tutorial log: ${LOGS_DIR}/tutorial_poc.log"
