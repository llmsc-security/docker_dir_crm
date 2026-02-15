#!/bin/bash
# Tutorial PoC script for joshpxyne--gpt-migrate
# Tests the HTTP service endpoint

set -e

# Absolute paths
REPO_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/joshpxyne--gpt-migrate"
SCRIPTS_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/joshpxyne--gpt-migrate"
BUILD_LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs"
BUILD_LOG="${BUILD_LOG_DIR}/joshpxyne--gpt-migrate.build.log"

# Port mapping from port_mapping_50_gap10_1.json
# joshpxyne--gpt-migrate maps to base port 11470
HOST_PORT=11470

# Ensure directories exist
mkdir -p "${SCRIPTS_DIR}"
mkdir -p "${BUILD_LOG_DIR}"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Redirect output to log file
exec > "${SCRIPTS_DIR}/tutorial_poc.log" 2>&1

log_message "Starting tutorial PoC script for joshpxyne--gpt-migrate"
log_message "Target service: http://127.0.0.1:${HOST_PORT}"

echo ""
echo "=============================================="
echo "joshpxyne--gpt-migrate PoC - Testing Service Endpoints"
echo "=============================================="
echo ""

# Test 1: Root endpoint
log_message "Test 1: Root endpoint"
echo "Test 1: Checking root endpoint..."
ROOT_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${HOST_PORT}/")
echo "  Root endpoint HTTP status: ${ROOT_RESPONSE}"
if [ "${ROOT_RESPONSE}" = "200" ]; then
    log_message "  Root endpoint: SUCCESS (HTTP ${ROOT_RESPONSE})"
else
    log_message "  Root endpoint: Status ${ROOT_RESPONSE}"
fi

# Test 2: Health endpoint (if available)
log_message "Test 2: Health endpoint"
echo ""
echo "Test 2: Checking health endpoint..."
HEALTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${HOST_PORT}/health" 2>/dev/null || echo "N/A")
echo "  Health endpoint HTTP status: ${HEALTH_RESPONSE}"
if [ "${HEALTH_RESPONSE}" = "200" ]; then
    log_message "  Health endpoint: SUCCESS"
else
    log_message "  Health endpoint: Not available or status ${HEALTH_RESPONSE}"
fi

# Test 3: Check main interface
log_message "Test 3: Main interface endpoint"
echo ""
echo "Test 3: Checking main interface..."
INTERFACE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${HOST_PORT}/" 2>/dev/null || echo "N/A")
echo "  Interface endpoint HTTP status: ${INTERFACE_RESPONSE}"
log_message "  Interface check: COMPLETE"

echo ""
echo "=============================================="
echo "PoC Test Summary"
echo "=============================================="
echo ""
echo "Service endpoint: http://127.0.0.1:${HOST_PORT}"
echo "Test 1 - Root endpoint: HTTP ${ROOT_RESPONSE}"
echo "Test 2 - Health endpoint: ${HEALTH_RESPONSE}"
echo "Test 3 - Interface: ${INTERFACE_RESPONSE}"
echo ""
echo "All logs saved to: ${SCRIPTS_DIR}/tutorial_poc.log"
echo "Build log at: ${BUILD_LOG}"

log_message "Tutorial PoC script completed"
