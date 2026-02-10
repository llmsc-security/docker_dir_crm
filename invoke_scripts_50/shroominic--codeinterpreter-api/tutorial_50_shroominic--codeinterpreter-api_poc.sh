#!/bin/bash
# Tutorial PoC script for shroominic--codeinterpreter-api
# This script demonstrates how to use the Code Interpreter API

set -e

echo "=== Code Interpreter API PoC ==="
echo "This demo shows how to use the Code Interpreter API with Docker"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if the image exists
if ! docker image inspect codeinterpreter-api-image:latest &> /dev/null; then
    echo "Error: codeinterpreter-api-image:latest not found"
    echo "Please run the invoke script first to build the image"
    exit 1
fi

echo "=== Application Information ==="
echo "Port: 11300 (host) -> 8501 (container)"
echo "Type: Streamlit web application"
echo ""

echo "=== Usage ==="
echo ""
echo "1. Start the application:"
echo "   docker run --rm -it \\"
echo "     -p 11300:8501 \\"
echo "     codeinterpreter-api-image:latest"
echo ""
echo "2. Access the application:"
echo "   Open http://localhost:11300 in your browser"
echo ""
echo "=== Features ==="
echo "- Python code execution in sandboxed environment"
echo "- Data visualization"
echo "- File upload and download"
echo "- Multi-turn conversations"
echo ""
echo "=== Quick Test ==="
echo "docker run --rm -it \\"
echo "  -p 11300:8501 \\"
echo "  codeinterpreter-api-image:latest"
echo ""
echo "Then open http://localhost:11300 in your browser"
