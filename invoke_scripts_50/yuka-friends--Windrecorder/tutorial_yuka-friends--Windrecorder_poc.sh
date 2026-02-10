#!/bin/bash
# =============================================================================
# Tutorial PoC script for Windrecorder HTTP Service
# =============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_NAME="yuka-friends--Windrecorder"
TUTORIAL_LOG="${SCRIPT_DIR}/tutorial_poc.log"

# Port mapping from port_mapping_50_gap10_3.json
# yuka-friends--Windrecorder: 11480
HOST_PORT=11480

# =============================================================================
# Logging setup
# =============================================================================
mkdir -p "$(dirname "${TUTORIAL_LOG}")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=========================================="
log "  Windrecorder Tutorial PoC"
log "=========================================="

# =============================================================================
# Check if service is running
# =============================================================================
log "Checking if service is running at http://127.0.0.1:${HOST_PORT}..."

if ! curl -s "http://127.0.0.1:${HOST_PORT}" > /dev/null 2>&1; then
    log "ERROR: Service is not responding at http://127.0.0.1:${HOST_PORT}"
    log "Please run invoke_yuka-friends--Windrecorder.sh first to start the service."
    echo "ERROR: Service is not responding at http://127.0.0.1:${HOST_PORT}" > "${TUTORIAL_LOG}"
    exit 1
fi

log "Service is responding!"

# =============================================================================
# Test 1: Check home page
# =============================================================================
log ""
log "Test 1: Fetching home page..."
echo "----------------------------------------"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\nContent-Type: %{content_type}\nTotal Time: %{time_total}s\n" "http://127.0.0.1:${HOST_PORT}/"
echo "----------------------------------------"

# =============================================================================
# Test 2: Check health endpoint (if available)
# =============================================================================
log ""
log "Test 2: Checking for health/status endpoints..."

# Streamlit doesn't have a standard health endpoint, but we can check the page
HEALTH_RESPONSE=$(curl -s "http://127.0.0.1:${HOST_PORT}/")
if echo "${HEALTH_RESPONSE}" | grep -q "Windrecorder"; then
    log "Success: Windrecorder UI is accessible"
else
    log "Warning: Could not verify Windrecorder UI content"
fi

# =============================================================================
# Test 3: Check Streamlit health endpoint
# =============================================================================
log ""
log "Test 3: Checking Streamlit _stcore/health endpoint..."
STREAMLIT_HEALTH=$(curl -s "http://127.0.0.1:${HOST_PORT}/_stcore/health")
log "Streamlit health response: ${STREAMLIT_HEALTH}"

# =============================================================================
# Summary
# =============================================================================
log ""
log "=========================================="
log "  Tutorial PoC Complete"
log "=========================================="
log "Service URL: http://127.0.0.1:${HOST_PORT}"
log "Tutorial log: ${TUTORIAL_LOG}"
log "=========================================="
log ""
log "You can now access the Windrecorder Web UI at:"
log "  http://127.0.0.1:${HOST_PORT}"
log ""

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Tutorial PoC completed. Service available at http://127.0.0.1:${HOST_PORT}" >> "${TUTORIAL_LOG}"
