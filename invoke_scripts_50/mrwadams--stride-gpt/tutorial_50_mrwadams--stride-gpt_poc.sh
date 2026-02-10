#!/bin/bash
# Tutorial PoC script for mrwadams--stride-gpt
# This script demonstrates how to use the STRIDE-GPT application

set -e

echo "=== STRIDE-GPT PoC ==="
echo "This demo shows how to use the STRIDE-GPT application with Docker"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if the image exists
if ! docker image inspect stride-gpt-image:latest &> /dev/null; then
    echo "Error: stride-gpt-image:latest not found"
    echo "Please run the invoke script first to build the image"
    exit 1
fi

echo "=== Application Information ==="
echo "Port: 11040 (host) -> 8501 (container)"
echo "Type: Streamlit web application"
echo ""

echo "=== Usage ==="
echo ""
echo "1. Start the application:"
echo "   docker run --rm -it \\"
echo "     -p 11040:8501 \\"
echo "     stride-gpt-image:latest"
echo ""
echo "2. Access the application:"
echo "   Open http://localhost:11040 in your browser"
echo ""
echo "=== Features ==="
echo "- Run STRIDE threat modeling analysis"
echo "- Generate STRIDE reports"
echo "- Analyze architectural diagrams"
echo "- Export results in various formats"
echo ""
echo "=== Quick Test ==="
echo "docker run --rm -it \\"
echo "  -p 11040:8501 \\"
echo "  stride-gpt-image:latest"
echo ""
echo "Then open http://localhost:11040 in your browser"
