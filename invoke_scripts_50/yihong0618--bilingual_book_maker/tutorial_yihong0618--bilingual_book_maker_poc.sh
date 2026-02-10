#!/bin/bash
# tutorial_yihong0618--bilingual_book_maker_poc.sh
# Proof-of-concept script to test the bilingual_book_maker HTTP API

set -e

# Absolute paths
BASE_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin"
SCRIPTS_DIR="${BASE_DIR}/invoke_scripts_50/yihong0618--bilingual_book_maker"
LOCAL_LOG="${SCRIPTS_DIR}/tutorial_poc.log"

# Port mapping from port_mapping_50_gap10_4.json
REPO="yihong0618--bilingual_book_maker"
JSON_FILE="${BASE_DIR}/port_mapping_50_gap10_4.json"
HOST_PORT=$(python3 -c "import json; data=json.load(open('${JSON_FILE}')); print(data.get('${REPO}', 11450))")
HOST_URL="http://127.0.0.1:${HOST_PORT}"

# Create logs directory if it doesn't exist
mkdir -p "${SCRIPTS_DIR}"

# Logging function - append mode
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOCAL_LOG}"
}

# Start PoC
log "=========================================="
log "Starting PoC test for bilingual_book_maker"
log "Service URL: ${HOST_URL}"
log "=========================================="

# Test 1: Check if service is reachable
log "Test 1: Checking service health..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}" 2>&1)
if [ "${HTTP_CODE}" -eq 200 ]; then
    log "SUCCESS: Service accessible (HTTP ${HTTP_CODE})"
    curl -s "${HOST_URL}" >> "${LOCAL_LOG}" 2>&1
else
    log "ERROR: Service returned HTTP ${HTTP_CODE}"
    exit 1
fi

# Test 2: Check API info
log ""
log "Test 2: Checking API info endpoint..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}/info" 2>&1)
if [ "${HTTP_CODE}" -eq 200 ]; then
    log "SUCCESS: /info endpoint accessible (HTTP ${HTTP_CODE})"
else
    log "INFO: /info endpoint returned HTTP ${HTTP_CODE} (not required)"
fi

# Test 3: Check health endpoint
log ""
log "Test 3: Checking health endpoint..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}/health" 2>&1)
if [ "${HTTP_CODE}" -eq 200 ]; then
    log "SUCCESS: /health endpoint accessible (HTTP ${HTTP_CODE})"
    curl -s "${HOST_URL}/health" >> "${LOCAL_LOG}" 2>&1
else
    log "INFO: /health endpoint returned HTTP ${HTTP_CODE}"
fi

# Test 4: List available models
log ""
log "Test 4: Listing available translation models..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}/models" 2>&1)
if [ "${HTTP_CODE}" -eq 200 ]; then
    log "SUCCESS: /models endpoint accessible (HTTP ${HTTP_CODE})"
    curl -s "${HOST_URL}/models" >> "${LOCAL_LOG}" 2>&1
else
    log "INFO: /models endpoint returned HTTP ${HTTP_CODE}"
fi

# Test 5: List supported formats
log ""
log "Test 5: Listing supported book formats..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}/formats" 2>&1)
if [ "${HTTP_CODE}" -eq 200 ]; then
    log "SUCCESS: /formats endpoint accessible (HTTP ${HTTP_CODE})"
    curl -s "${HOST_URL}/formats" >> "${LOCAL_LOG}" 2>&1
else
    log "INFO: /formats endpoint returned HTTP ${HTTP_CODE}"
fi

# Test 6: Test translation job submission (requires API key - will fail without one)
log ""
log "Test 6: Testing translation job submission (will require valid API key)..."
# First, copy the test book to the data directory if it exists
TEST_BOOK="test_books/animal_farm.epub"
if [ -f "${TEST_BOOK}" ]; then
    mkdir -p "/app/data"
    cp "${TEST_BOOK}" "/app/data/" 2>/dev/null || true
    log "Test book found and copied to data directory"
fi

# Try to submit a test job (will fail without API key, but that's expected)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${HOST_URL}/translate" \
    -F "book_name=test_books/animal_farm.epub" \
    -F "model=chatgptapi" \
    -F "language=Simplified Chinese" \
    -F "test=true" 2>&1 || true)
log "Translation job submission test: HTTP ${HTTP_CODE} (expected 400 if no API key provided)"

log ""
log "=========================================="
log "PoC test completed!"
log "=========================================="

exit 0
