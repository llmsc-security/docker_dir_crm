#!/bin/bash

# tutorial_Paper2Poster--Paper2Poster_poc.sh
# Proof-of-concept script to test the Paper2Poster Gradio service

set -e

# Absolute paths
BASE_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin"
SCRIPTS_DIR="${BASE_DIR}/invoke_scripts_50/Paper2Poster--Paper2Poster"
LOCAL_LOG="${SCRIPTS_DIR}/tutorial_poc.log"

# Port mapping from port_mapping_50_gap10_4.json
REPO="Paper2Poster--Paper2Poster"
JSON_FILE="${BASE_DIR}/port_mapping_50_gap10_4.json"
HOST_PORT=$(python3 -c "import json; data=json.load(open('${JSON_FILE}')); print(data.get('${REPO}', 11320))")
HOST_URL="http://127.0.0.1:${HOST_PORT}"

# Create logs directory if it doesn't exist
mkdir -p "${SCRIPTS_DIR}"

# Logging function - append mode
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOCAL_LOG}"
}

# Start PoC
log "=========================================="
log "Starting PoC test for Paper2Poster"
log "Service URL: ${HOST_URL}"
log "=========================================="

# Test 1: Check if service is reachable
log "Test 1: Checking service health..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}" 2>&1)
if [ "${HTTP_CODE}" -eq 200 ]; then
    log "SUCCESS: Gradio UI accessible (HTTP ${HTTP_CODE})"
else
    log "WARNING: Service returned HTTP ${HTTP_CODE}"
fi

# Test 2: Check API endpoints are registered
log ""
log "Test 2: Checking API endpoints..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}/info" 2>&1)
if [ "${HTTP_CODE}" -eq 200 ]; then
    log "SUCCESS: /info endpoint accessible (HTTP ${HTTP_CODE})"
else
    log "INFO: /info endpoint returned HTTP ${HTTP_CODE}"
fi

# Test 3: Check Gradio config
log ""
log "Test 3: Checking Gradio config..."
curl -s "${HOST_URL}/config" >> "${LOCAL_LOG}" 2>&1 || true

log ""
log "=========================================="
log "PoC test completed!"
log "=========================================="

exit 0
