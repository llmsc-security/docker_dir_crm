#!/bin/bash

# tutorial_adithya-s-k--omniparse_poc.sh
# Proof-of-concept script to test the omniparse service

set -e

# Absolute paths
BASE_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin"
SCRIPTS_DIR="${BASE_DIR}/invoke_scripts_50/adithya-s-k--omniparse"
LOCAL_LOG="${SCRIPTS_DIR}/tutorial_poc.log"

# Port mapping from port_mapping_50_gap10_4.json
REPO="adithya-s-k--omniparse"
JSON_FILE="${BASE_DIR}/port_mapping_50_gap10_4.json"
HOST_PORT=$(python3 -c "import json; data=json.load(open('${JSON_FILE}')); print(data.get('${REPO}', 11090))")
HOST_URL="http://127.0.0.1:${HOST_PORT}"

# Create logs directory if it doesn't exist
mkdir -p "${SCRIPTS_DIR}"

# Logging function - append mode
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOCAL_LOG}"
}

# Start PoC
log "=========================================="
log "Starting PoC test for omniparse"
log "Service URL: ${HOST_URL}"
log "=========================================="

# Test 1: Check if service is reachable
log "Test 1: Checking service health..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}/docs" 2>&1)
if [ "${HTTP_CODE}" -eq 200 ]; then
    log "SUCCESS: Service is running (HTTP ${HTTP_CODE})"
else
    log "WARNING: Service returned HTTP ${HTTP_CODE}"
fi

# Test 2: Check API endpoints are registered
log ""
log "Test 2: Checking API endpoints..."
curl -s "${HOST_URL}/openapi.json" >> "${LOCAL_LOG}" 2>&1 || true

# Test 3: Test document parsing endpoint (without actual file)
log ""
log "Test 3: Testing /parse_document endpoint (schema check)..."
curl -s -X POST "${HOST_URL}/parse_document/pdf" \
    -H "Content-Type: multipart/form-data" \
    -F "file=@/dev/null" 2>&1 >> "${LOCAL_LOG}" || true

# Test 4: Test Gradio UI
log ""
log "Test 4: Checking Gradio UI..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}" 2>&1)
if [ "${HTTP_CODE}" -eq 200 ]; then
    log "SUCCESS: Gradio UI accessible (HTTP ${HTTP_CODE})"
else
    log "INFO: Gradio UI returned HTTP ${HTTP_CODE}"
fi

log ""
log "=========================================="
log "PoC test completed!"
log "=========================================="

exit 0
