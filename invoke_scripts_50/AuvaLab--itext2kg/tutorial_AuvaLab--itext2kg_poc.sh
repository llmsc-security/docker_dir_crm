#!/bin/bash
# Tutorial PoC script for AuvaLab--itext2kg
# Tests the HTTP service endpoint

set -e

# Absolute paths
REPO_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/AuvaLab--itext2kg"
SCRIPTS_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/AuvaLab--itext2kg"
BUILD_LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs"
BUILD_LOG="${BUILD_LOG_DIR}/AuvaLab--itext2kg.build.log"

# Port mapping from port_mapping_50_gap10_1.json
# AuvaLab--itext2kg maps to base port 11380
HOST_PORT=11380

# Ensure directories exist
mkdir -p "${SCRIPTS_DIR}"
mkdir -p "${BUILD_LOG_DIR}"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Redirect output to log file
exec > "${SCRIPTS_DIR}/tutorial_poc.log" 2>&1

log_message "Starting tutorial PoC script for AuvaLab--itext2kg"
log_message "Target service: http://127.0.0.1:${HOST_PORT}"

echo ""
echo "=============================================="
echo "AuvaLab--itext2kg PoC - Testing Service Endpoints"
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

# Test 3: Check API docs (FastAPI)
log_message "Test 3: API docs endpoint"
echo ""
echo "Test 3: Checking API docs..."
DOCS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${HOST_PORT}/docs" 2>/dev/null || echo "N/A")
echo "  API docs HTTP status: ${DOCS_RESPONSE}"
log_message "  API docs check: COMPLETE"

echo ""
echo "=============================================="
echo "PoC Test Summary"
echo "=============================================="
echo ""
echo "Service endpoint: http://127.0.0.1:${HOST_PORT}"
echo "Test 1 - Root endpoint: HTTP ${ROOT_RESPONSE}"
echo "Test 2 - Health endpoint: ${HEALTH_RESPONSE}"
echo "Test 3 - API docs: ${DOCS_RESPONSE}"
echo ""
echo "All logs saved to: ${SCRIPTS_DIR}/tutorial_poc.log"
echo "Build log at: ${BUILD_LOG}"

log_message "Tutorial PoC script completed"
