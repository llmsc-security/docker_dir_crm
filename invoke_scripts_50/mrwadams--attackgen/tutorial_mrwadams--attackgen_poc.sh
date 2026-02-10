#!/bin/bash
# Tutorial PoC script for mrwadams--attackgen
# Tests the HTTP service endpoint

set -e

# Absolute paths
REPO_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/mrwadams--attackgen"
SCRIPTS_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/mrwadams--attackgen"
BUILD_LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs"
BUILD_LOG="${BUILD_LOG_DIR}/mrwadams--attackgen.build.log"

# Port mapping from port_mapping_50_gap10_1.json
# mrwadams--attackgen maps to base port 11110
HOST_PORT=11110

# Ensure directories exist
mkdir -p "${SCRIPTS_DIR}"
mkdir -p "${BUILD_LOG_DIR}"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Redirect output to log file
exec > "${SCRIPTS_DIR}/tutorial_poc.log" 2>&1

log_message "Starting tutorial PoC script for mrwadams--attackgen"
log_message "Target service: http://127.0.0.1:${HOST_PORT}"

echo ""
echo "=============================================="
echo "AttackGen PoC - Testing Service Endpoints"
echo "=============================================="
echo ""

# Test 1: Health check endpoint
log_message "Test 1: Health check endpoint"
echo "Test 1: Checking health endpoint..."
HEALTH_RESPONSE=$(curl -s "http://127.0.0.1:${HOST_PORT}/_stcore/health")
if [ -n "${HEALTH_RESPONSE}" ]; then
    echo "  Health endpoint response: ${HEALTH_RESPONSE}"
    log_message "  Health check: SUCCESS"
else
    echo "  Health endpoint: No response"
    log_message "  Health check: FAILED"
fi

# Test 2: Root endpoint (Streamlit app)
log_message "Test 2: Root application endpoint"
echo ""
echo "Test 2: Accessing root application endpoint..."
ROOT_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${HOST_PORT}/")
echo "  Root endpoint HTTP status: ${ROOT_RESPONSE}"
if [ "${ROOT_RESPONSE}" = "200" ]; then
    log_message "  Root endpoint: SUCCESS (HTTP ${ROOT_RESPONSE})"
else
    log_message "  Root endpoint: Status ${ROOT_RESPONSE} (may be redirect)"
fi

# Test 3: Check for Streamlit static resources
log_message "Test 3: Checking Streamlit static resources"
echo ""
echo "Test 3: Checking for Streamlit static resources..."
STATIC_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${HOST_PORT}/streamlit/static/js/main.js")
echo "  Static resource HTTP status: ${STATIC_RESPONSE}"
if [ "${STATIC_RESPONSE}" = "200" ]; then
    log_message "  Static resources: SUCCESS"
else
    log_message "  Static resources: Status ${STATIC_RESPONSE}"
fi

# Test 4: Check for favicon (common endpoint)
log_message "Test 4: Checking favicon endpoint"
echo ""
echo "Test 4: Checking favicon endpoint..."
FAVICON_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${HOST_PORT}/favicon.ico")
echo "  Favicon HTTP status: ${FAVICON_RESPONSE}"
log_message "  Favicon status: ${FAVICON_RESPONSE}"

echo ""
echo "=============================================="
echo "PoC Test Summary"
echo "=============================================="
echo ""
echo "Service endpoint: http://127.0.0.1:${HOST_PORT}"
echo "Test 1 - Health check: ${HEALTH_RESPONSE:+OK (response received)}"
echo "Test 2 - Root app: HTTP ${ROOT_RESPONSE}"
echo "Test 3 - Static resources: HTTP ${STATIC_RESPONSE}"
echo "Test 4 - Favicon: HTTP ${FAVICON_RESPONSE}"
echo ""
echo "All logs saved to: ${SCRIPTS_DIR}/tutorial_poc.log"
echo "Build log at: ${BUILD_LOG}"

log_message "Tutorial PoC script completed"
