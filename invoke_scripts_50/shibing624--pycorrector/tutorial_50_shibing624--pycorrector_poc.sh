#!/bin/bash
# Tutorial PoC script for shibing624--pycorrector
# This script demonstrates how to use the Chinese spelling correction service

set -e

echo "=== Chinese Spelling Correction (pycorrector) PoC ==="
echo "This demo shows how to use the pycorrector service with Docker"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if the image exists
if ! docker image inspect pycorrector-image:latest &> /dev/null; then
    echo "Error: pycorrector-image:latest not found"
    echo "Please run the invoke script first to build the image"
    exit 1
fi

echo "=== Service Information ==="
echo "Port: 11000 (host) -> 5001 (container)"
echo "Endpoint: /api correct"
echo ""

echo "=== API Usage ==="
echo ""
echo "1. Correct a single sentence:"
echo 'curl -X POST http://localhost:11000/api correct \\'
echo '  -H "Content-Type: application/json" \\'
echo '  -d "{\"text\": \"我今天不吃面条\"}"'
echo ""
echo "2. Correct multiple sentences:"
echo 'curl -X POST http://localhost:11000/api correct_batch \\'
echo '  -H "Content-Type: application/json" \\'
echo '  -d "{\"texts\": [\"我今天不吃面条\", \"他去学校\"]}"'
echo ""
echo "3. Get symptoms (correct with context):"
echo 'curl -X POST http://localhost:11000/api symptoms \\'
echo '  -H "Content-Type: application/json" \\'
echo '  -d "{\"text\": \"我今天不吃面条\", \"keywords\": [\"吃\"]}"'
echo ""
echo "4. Using curl with shorthand:"
echo 'curl http://localhost:11000/api correct -H "Content-Type: application/json" -d "{\"text\":\"今天吃面\"}"'
echo ""
echo "=== Response Format ==="
echo '{"code": 200, "data": {"correct": "corrected text", "errors": [...]}}'
echo ""
echo "=== Quick Test ==="
echo "docker run --rm -it \\"
echo "  -p 11000:5001 \\"
echo "  pycorrector-image:latest"
echo ""
echo "Then in another terminal:"
echo 'curl http://localhost:11000/api correct -H "Content-Type: application/json" -d "{\"text\":\"今天吃面\"}"'
