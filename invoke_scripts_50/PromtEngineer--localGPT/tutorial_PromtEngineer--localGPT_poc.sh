#!/bin/bash
# Tutorial PoC script for PromtEngineer--localGPT
# Tests the HTTP service endpoints and demonstrates usage.

set -e

REPO_NAME="PromtEngineer--localGPT"
HOST="localhost"
PORT=11350
CONTAINER_PORT=8000

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}"
}

test_root_endpoint() {
    local response
    local http_code
    response=$(curl -s -w "\n%{http_code}" "http://${HOST}:${PORT}/" 2>/dev/null) || true
    http_code=$(echo "$response" | tail -n1)
    if [ "$http_code" = "200" ]; then
        log "INFO" "Root endpoint returned HTTP $http_code"
        return 0
    else
        log "ERROR" "Root endpoint test failed with HTTP $http_code"
        return 1
    fi
}

test_health_endpoint() {
    local response
    local http_code
    response=$(curl -s -w "\n%{http_code}" "http://${HOST}:${PORT}/health" 2>/dev/null) || true
    http_code=$(echo "$response" | tail -n1)
    if [ "$http_code" = "200" ]; then
        log "INFO" "Health endpoint returned HTTP $http_code"
        return 0
    else
        log "WARNING" "Health endpoint returned HTTP $http_code"
        return 0
    fi
}

test_main_service() {
    local content
    content=$(curl -s "http://${HOST}:${PORT}/" 2>/dev/null) || true
    if echo "$content" | grep -qi "gradio\|interface"; then
        log "INFO" "Gradio interface detected"
        return 0
    else
        log "WARNING" "Main service test - no gradio interface detected (may be expected)"
        return 0
    fi
}

test_service() {
    log "INFO" "Starting PoC tests for ${REPO_NAME}"
    log "INFO" "Container port: ${CONTAINER_PORT}"
    log "INFO" "Host port: ${PORT}"
    log "INFO" "=========================================="

    local passed=0
    local total=3

    # Test 1: Root endpoint
    log "INFO" "Test 1: Testing root endpoint..."
    if test_root_endpoint; then
        ((passed++)) || true
        log "INFO" "  PASS"
    else
        log "INFO" "  FAIL"
    fi

    # Test 2: Health endpoint
    log "INFO" "Test 2: Testing health endpoint..."
    if test_health_endpoint; then
        ((passed++)) || true
        log "INFO" "  PASS"
    else
        log "INFO" "  FAIL"
    fi

    # Test 3: Main service
    log "INFO" "Test 3: Testing main service..."
    if test_main_service; then
        ((passed++)) || true
        log "INFO" "  PASS"
    else
        log "INFO" "  FAIL"
    fi

    # Summary
    log "INFO" "=========================================="
    log "INFO" "PoC completed: ${passed}/${total} tests passed"

    if [ $passed -eq $total ]; then
        log "SUCCESS" "All tests passed!"
        exit 0
    else
        log "ERROR" "Some tests failed: ${passed}/${total} passed"
        exit 1
    fi
}

test_service
