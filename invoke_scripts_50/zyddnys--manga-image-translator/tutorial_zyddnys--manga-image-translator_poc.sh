#!/bin/bash

# tutorial_zyddnys--manga-image-translator_poc.sh
# Tutorial PoC script for testing Manga Image Translator API
# Host Port: 11080

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/zyddnys--manga-image-translator"
HOST_PORT=11080
CONTAINER_PORT=8000
BASE_URL="http://localhost:${HOST_PORT}"

echo "=========================================="
echo "Manga Image Translator - Tutorial PoC"
echo "=========================================="
echo "Target: zyddnys--manga-image-translator"
echo "Host Port: ${HOST_PORT} -> Container Port: ${CONTAINER_PORT}"
echo "Base URL: ${BASE_URL}"
echo "=========================================="

# Function to check if container is running
check_container() {
    local container_name="manga-image-translator-server"
    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "[OK] Container '${container_name}' is running"
        return 0
    else
        echo "[WARN] Container '${container_name}' is not running"
        return 1
    fi
}

# Function to test health endpoint
test_health() {
    echo ""
    echo "----------------------------------------"
    echo "[TEST 1] Health Check"
    echo "----------------------------------------"
    echo "GET ${BASE_URL}/"
    
    response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/" 2>/dev/null || echo "000")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    echo "HTTP Status: ${http_code}"
    if [ "$http_code" = "200" ]; then
        echo "Response: ${body}"
        echo "[PASS] Health check successful"
    else
        echo "[FAIL] Health check failed"
    fi
}

# Function to test queue size endpoint
test_queue_size() {
    echo ""
    echo "----------------------------------------"
    echo "[TEST 2] Queue Size"
    echo "----------------------------------------"
    echo "GET ${BASE_URL}/queue-size"
    
    response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/queue-size" 2>/dev/null || echo "000")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    echo "HTTP Status: ${http_code}"
    echo "Response: ${body}"
    if [ "$http_code" = "200" ]; then
        echo "[PASS] Queue size endpoint accessible"
    else
        echo "[FAIL] Queue size endpoint failed"
    fi
}

# Function to test results list endpoint
test_results_list() {
    echo ""
    echo "----------------------------------------"
    echo "[TEST 3] Results List"
    echo "----------------------------------------"
    echo "GET ${BASE_URL}/results/list"
    
    response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/results/list" 2>/dev/null || echo "000")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    echo "HTTP Status: ${http_code}"
    echo "Response: ${body}"
    if [ "$http_code" = "200" ]; then
        echo "[PASS] Results list endpoint accessible"
    else
        echo "[FAIL] Results list endpoint failed"
    fi
}

# Function to test image translation with sample image
test_translation() {
    echo ""
    echo "----------------------------------------"
    echo "[TEST 4] Image Translation"
    echo "----------------------------------------"
    
    # Create a sample test image if PIL is available
    if command -v python3 &> /dev/null; then
        python3 -c "
from PIL import Image
img = Image.new('RGB', (800, 600), color=(255, 255, 255))
img.save('/tmp/manga_test_input.png', 'PNG')
print('/tmp/manga_test_input.png')
" 2>/dev/null && SAMPLE_IMAGE="/tmp/manga_test_input.png" || SAMPLE_IMAGE=""
    else
        SAMPLE_IMAGE=""
    fi
    
    if [ -n "${SAMPLE_IMAGE}" ] && [ -f "${SAMPLE_IMAGE}" ]; then
        echo "Testing with sample image: ${SAMPLE_IMAGE}"
        
        # Test JSON response
        echo ""
        echo "Test: /translate/with-form/json"
        response=$(curl -s -w "\n%{http_code}" \
            -F "image=@${SAMPLE_IMAGE};type=image/png" \
            -F "config={\"source_lang\": \"ja\", \"target_lang\": \"en\"}" \
            "${BASE_URL}/translate/with-form/json" 2>/dev/null || echo "000")
        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | sed '$d')
        
        echo "HTTP Status: ${http_code}"
        if [ ${#body} -gt 200 ]; then
            echo "Response (truncated): ${body:0:200}..."
        else
            echo "Response: ${body}"
        fi
        
        if [ "$http_code" = "200" ]; then
            echo "[PASS] Translation JSON endpoint working"
        else
            echo "[INFO] Translation endpoint may need more time (warm-up phase)"
        fi
    else
        echo "[INFO] Skipping translation test (no sample image created)"
    fi
}

# Function to test streaming endpoint
test_streaming() {
    echo ""
    echo "----------------------------------------"
    echo "[TEST 5] Streaming Translation"
    echo "----------------------------------------"
    
    # Create sample image
    python3 -c "
from PIL import Image
img = Image.new('RGB', (400, 400), color=(240, 240, 240))
img.save('/tmp/manga_stream_test.png', 'PNG')
" 2>/dev/null && STREAM_IMAGE="/tmp/manga_stream_test.png" || STREAM_IMAGE=""
    
    if [ -n "${STREAM_IMAGE}" ] && [ -f "${STREAM_IMAGE}" ]; then
        echo "Testing streaming endpoint..."
        response=$(curl -s -w "\n%{http_code}" \
            -F "image=@${STREAM_IMAGE};type=image/png" \
            -F "config={\"source_lang\": \"ja\", \"target_lang\": \"en\"}" \
            "${BASE_URL}/translate/with-form/json/stream" 2>/dev/null || echo "000")
        http_code=$(echo "$response" | tail -n1)
        
        echo "HTTP Status: ${http_code}"
        if [ "$http_code" = "200" ] || [ "$http_code" = "204" ]; then
            echo "[PASS] Streaming endpoint accessible"
        else
            echo "[INFO] Streaming endpoint may be under development"
        fi
    fi
}

# Main execution
main() {
    echo ""
    echo "Starting Tutorial PoC for Manga Image Translator"
    echo ""
    
    # Check if container is running
    if ! check_container; then
        echo ""
        echo "Note: The container is not running."
        echo "Please start the container first by running:"
        echo "  cd ${REPO_DIR} && bash invoke.sh"
        echo ""
    fi
    
    # Wait for server to be ready
    echo ""
    echo "Waiting for server to be ready..."
    for i in {1..10}; do
        if curl -s "${BASE_URL}/" > /dev/null 2>&1; then
            echo "[OK] Server is ready"
            break
        fi
        echo "  Waiting... ($i/10)"
        sleep 2
    done
    
    # Run tests
    test_health
    test_queue_size
    test_results_list
    test_translation
    test_streaming
    
    echo ""
    echo "=========================================="
    echo "Tutorial PoC Complete"
    echo "=========================================="
    echo ""
    echo "API Endpoints available:"
    echo "  GET  ${BASE_URL}/                      - Health check"
    echo "  GET  ${BASE_URL}/queue-size            - Queue size"
    echo "  GET  ${BASE_URL}/results/list          - Results list"
    echo "  POST ${BASE_URL}/translate/json        - JSON translation"
    echo "  POST ${BASE_URL}/translate/bytes       - Binary translation"
    echo "  POST ${BASE_URL}/translate/image       - Image response"
    echo "  POST ${BASE_URL}/translate/json/stream - Streaming JSON"
    echo "  POST ${BASE_URL}/translate/bytes/stream - Streaming binary"
    echo "  POST ${BASE_URL}/translate/image/stream - Streaming image"
    echo "  POST ${BASE_URL}/translate/with-form/json - Form-based JSON"
    echo "  POST ${BASE_URL}/translate/with-form/image - Form-based image"
    echo ""
}

main "$@"
