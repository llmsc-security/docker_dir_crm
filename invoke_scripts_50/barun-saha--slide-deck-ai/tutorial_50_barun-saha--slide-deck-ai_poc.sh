#!/bin/bash
# Tutorial PoC script for barun-saha--slide-deck-ai
# This script demonstrates how to use the SlideDeck AI application

set -e

echo "=== SlideDeck AI PoC ==="
echo "This demo shows how to use the SlideDeck AI application with Docker"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if the image exists
if ! docker image inspect slide-deck-ai-image:latest &> /dev/null; then
    echo "Error: slide-deck-ai-image:latest not found"
    echo "Please run the invoke script first to build the image"
    exit 1
fi

echo "=== Application Information ==="
echo "Port: 11410 (host) -> 8501 (container)"
echo "Type: Streamlit web application"
echo ""

echo "=== Usage ==="
echo ""
echo "1. Start the application:"
echo "   docker run --rm -it \\"
echo "     -p 11410:8501 \\"
echo "     slide-deck-ai-image:latest"
echo ""
echo "2. Access the application:"
echo "   Open http://localhost:11410 in your browser"
echo ""
echo "=== Features ==="
echo "- Generate slides from text"
echo "- AI-powered slide design"
echo "- Export slides as PDF/HTML"
echo "- Customize slide templates"
echo ""
echo "=== Quick Test ==="
echo "docker run --rm -it \\"
echo "  -p 11410:8501 \\"
echo "  slide-deck-ai-image:latest"
echo ""
echo "Then open http://localhost:11410 in your browser"
