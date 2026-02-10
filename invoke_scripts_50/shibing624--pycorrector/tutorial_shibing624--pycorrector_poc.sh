#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Tutorial PoC script for shibing624--pycorrector
# Calls the deployed HTTP service using curl
# ============================================================================

# Absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}"

# Port configuration (from port_mapping_50_gap10.json)
# Base port: 11000, Host port: 11000 (within range [11000, 11010])
HOST_PORT=11000
BASE_URL="http://127.0.0.1:${HOST_PORT}"

# Create log directory if not exists
mkdir -p "${LOG_DIR}"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Start tutorial log
log "=== Tutorial PoC started for shibing624--pycorrector ===" > "${LOG_DIR}/tutorial_poc.log"
log "Base URL: ${BASE_URL}" >> "${LOG_DIR}/tutorial_poc.log"

echo ""
echo "=========================================="
echo "Chinese Spelling Correction - PoC Test"
echo "=========================================="
echo ""

# Test 1: Check service health
log "Test 1: Checking service health..." | tee -a "${LOG_DIR}/tutorial_poc.log"
echo "Test 1: Checking service health..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/" 2>&1 || echo "000")
if [ "${RESPONSE}" = "200" ]; then
    log "Health check: PASSED (HTTP ${RESPONSE})" | tee -a "${LOG_DIR}/tutorial_poc.log"
    echo "  Health check: PASSED (HTTP ${RESPONSE})"
else
    log "Health check: FAILED (HTTP ${RESPONSE})" | tee -a "${LOG_DIR}/tutorial_poc.log"
    echo "  Health check: FAILED (HTTP ${RESPONSE})"
fi
echo ""

# Test 2: Correct Chinese text with errors
log "Test 2: Correcting Chinese text with errors..." | tee -a "${LOG_DIR}/tutorial_poc.log"
echo "Test 2: Correcting Chinese text with errors..."

# FastAPI endpoint for single text correction
PAYLOAD='{"text": "少先队员因该为老人让坐"}'
echo "  Request payload: ${PAYLOAD}"

RESULT=$(curl -s -X POST "${BASE_URL}/correct" \
    -H "Content-Type: application/json" \
    -d "${PAYLOAD}" 2>&1 || echo '{"error": "Request failed"}')

log "Response: ${RESULT}" | tee -a "${LOG_DIR}/tutorial_poc.log"
echo "  Response: ${RESULT}"

# Test 3: Another example
log "Test 3: Correcting another Chinese sentence..." | tee -a "${LOG_DIR}/tutorial_poc.log"
echo ""
echo "Test 3: Correcting another Chinese sentence..."
PAYLOAD='{"text": "今天新情很好"}'
echo "  Request payload: ${PAYLOAD}"

RESULT=$(curl -s -X POST "${BASE_URL}/correct" \
    -H "Content-Type: application/json" \
    -d "${PAYLOAD}" 2>&1 || echo '{"error": "Request failed"}')

log "Response: ${RESULT}" | tee -a "${LOG_DIR}/tutorial_poc.log"
echo "  Response: ${RESULT}"

# Test 4: Health endpoint
log "Test 4: Health check endpoint..." | tee -a "${LOG_DIR}/tutorial_poc.log"
echo ""
echo "Test 4: Health check endpoint..."
RESULT=$(curl -s "${BASE_URL}/health" 2>&1 || echo '{"error": "Request failed"}')
log "Response: ${RESULT}" | tee -a "${LOG_DIR}/tutorial_poc.log"
echo "  Response: ${RESULT}"

echo ""
echo "=========================================="
echo "PoC tests completed!"
echo "=========================================="
echo ""
log "=== Tutorial PoC completed ===" >> "${LOG_DIR}/tutorial_poc.log"
