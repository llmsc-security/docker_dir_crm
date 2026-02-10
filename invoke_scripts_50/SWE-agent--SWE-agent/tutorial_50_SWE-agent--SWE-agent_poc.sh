#!/bin/bash
# Tutorial PoC script for SWE-agent--SWE-agent
# This script demonstrates how to use the SWE-agent API

set -e

echo "=== SWE-agent PoC ==="
echo "This demo shows how to use the SWE-agent API with Docker"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if the image exists
if ! docker image inspect swe-agent-image:latest &> /dev/null; then
    echo "Error: swe-agent-image:latest not found"
    echo "Please run the invoke script first to build the image"
    exit 1
fi

echo "=== Application Information ==="
echo "Port: 11400 (host) -> 8000 (container)"
echo "Type: FastAPI web server"
echo ""

echo "=== Usage ==="
echo ""
echo "1. Start the API server:"
echo "   docker run --rm -it \\"
echo "     -e OPENAI_API_KEY=\${OPENAI_API_KEY} \\"
echo "     -p 11400:8000 \\"
echo "     swe-agent-image:latest"
echo ""
echo "2. Access the API:"
echo "   Open http://localhost:11400 in your browser (docs)"
echo "   API endpoint: http://localhost:11400/api"
echo ""
echo "3. API Endpoints:"
echo "   - POST /api/run - Run SWE-agent on a repository"
echo "   - GET /api/status - Get status of running agents"
echo "   - GET /api/logs - Get logs from agents"
echo ""
echo "=== Quick Test ==="
echo "export OPENAI_API_KEY=your_key_here"
echo "docker run --rm -it \\"
echo "  -e OPENAI_API_KEY=\${OPENAI_API_KEY} \\"
echo "  -p 11400:8000 \\"
echo "  swe-agent-image:latest"
echo ""
echo "Then check http://localhost:11400/docs for API docs"
