#!/bin/bash
# Tutorial PoC script for Biomni Gradio App
# Tests the Gradio interface running on port 11260 (host) -> 7860 (container)

set -e

HOST_PORT=11260
CONTAINER_PORT=7860
SERVER_URL="http://localhost:$HOST_PORT"

echo "============================================================"
echo "Biomni Gradio App - Tutorial PoC"
echo "============================================================"
echo "Target: $SERVER_URL"
echo "Host Port: $HOST_PORT -> Container Port: $CONTAINER_PORT (Gradio)"
echo "============================================================"

# Function to test HTTP endpoints
test_endpoint() {
    local path="$1"
    local description="$2"
    local url="${SERVER_URL}${path}"
    
    echo ""
    echo "[TEST] $description"
    echo "URL: $url"
    
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null || echo "000")
    echo "HTTP Status: $response"
    
    if [ "$response" = "200" ] || [ "$response" = "307" ] || [ "$response" = "302" ]; then
        echo "Result: PASS"
        return 0
    else
        echo "Result: FAIL"
        return 1
    fi
}

echo ""
echo "============================================================"
echo "Step 1: Verify Container is Running"
echo "============================================================"
if docker ps --format "table {{.Names}}" | grep -q "biomni-gradio"; then
    echo "Container 'biomni-gradio' is running"
    docker ps --filter "name=biomni-gradio" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo "Container 'biomni-gradio' is NOT running"
    echo "Please run: ./invoke_snap-stanford--Biomni.sh run"
    exit 1
fi

echo ""
echo "============================================================"
echo "Step 2: Gradio Interface Endpoints Test"
echo "============================================================"

# Test Gradio endpoints
test_endpoint "/" "Main Interface"
test_endpoint "/queue/join" "Queue Join Endpoint"
test_endpoint "/queue/data" "Queue Data (WebSocket)"
test_endpoint "/health" "Health Endpoint"

echo ""
echo "============================================================"
echo "Step 3: Check API Documentation"
echo "============================================================"
# Gradio typically exposes API docs at /api/docs or similar
curl -s -I "$SERVER_URL/api" --max-time 5 2>/dev/null | head -5 || echo "API endpoint check complete"

echo ""
echo "============================================================"
echo "Step 4: Full HTTP Response Check"
echo "============================================================"
echo "Fetching main page..."
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "$SERVER_URL/"
curl -s -I "$SERVER_URL/" --max-time 5 2>/dev/null | grep -E "^(HTTP|Content-Type|Server):" || echo "Response headers check complete"

echo ""
echo "============================================================"
echo "Step 5: Test Gradio via Python Client (Optional)"
echo "============================================================"
# Check if we can connect via Python
python3 -c "
import urllib.request
import json

try:
    # Test health endpoint
    req = urllib.request.Request('${SERVER_URL}/health', method='GET')
    with urllib.request.urlopen(req, timeout=5) as response:
        data = response.read().decode('utf-8')
        print('Health endpoint response:')
        print(data[:500] if len(data) > 500 else data)
except Exception as e:
    print(f'Python client test: {e}')
"

echo ""
echo "============================================================"
echo "Step 6: Container Logs Check"
echo "============================================================"
echo "Recent container logs:"
docker logs biomni-gradio --tail 20 2>/dev/null || echo "Could not retrieve logs"

echo ""
echo "============================================================"
echo "Tutorial PoC Complete"
echo "============================================================"
echo ""
echo "To access the Gradio interface:"
echo "  Open http://localhost:$HOST_PORT in your browser"
echo ""
echo "To stop the container:"
echo "  ./invoke_snap-stanford--Biomni.sh stop"
echo ""
echo "To view logs:"
echo "  ./invoke_snap-stanford--Biomni.sh logs"
