#!/bin/bash
# Tutorial PoC script for assafelovic--gpt-researcher
# This script demonstrates how to use the GPT-Researcher API

set -e

echo "=== GPT-Researcher PoC ==="
echo "This demo shows how to use the GPT-Researcher API with Docker"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if the image exists
if ! docker image inspect gpt-researcher-image:latest &> /dev/null; then
    echo "Error: gpt-researcher-image:latest not found"
    echo "Please run the invoke script first to build the image"
    exit 1
fi

echo "=== Application Information ==="
echo "Port: 11250 (host) -> 8000 (container)"
echo "Type: FastAPI web server"
echo ""

echo "=== Usage ==="
echo ""
echo "1. Start the research API server:"
echo "   docker run --rm -it \\"
echo "     -e OPENAI_API_KEY=\${OPENAI_API_KEY} \\"
echo "     -p 11250:8000 \\"
echo "     gpt-researcher-image:latest"
echo ""
echo "2. Access the API:"
echo "   API: http://localhost:11250"
echo "   Docs: http://localhost:11250/docs"
echo ""
echo "3. API Endpoints:"
echo "   - POST /api/research - Start a new research task"
echo "   - GET /api/research/{id} - Get research results"
echo "   - POST /api/long_research - Start a long-running research"
echo ""
echo "=== Example Request ==="
echo 'curl -X POST http://localhost:11250/api/research \\'
echo '  -H "Content-Type: application/json" \\'
echo '  -d "{\"topic\": \"Artificial Intelligence trends 2024\", \"model\": \"gpt-4\"}"'
echo ""
echo "=== Quick Test ==="
echo "export OPENAI_API_KEY=your_key_here"
echo "docker run --rm -it \\"
echo "  -e OPENAI_API_KEY=\${OPENAI_API_KEY} \\"
echo "  -p 11250:8000 \\"
echo "  gpt-researcher-image:latest"
echo ""
echo "Then check http://localhost:11250/docs for API docs"
