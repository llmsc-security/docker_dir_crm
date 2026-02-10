#!/usr/bin/env bash
set -euo pipefail

# Tutorial PoC script for fynnfluegge--codeqai
# This script demonstrates the basic usage of the CodeQAI Streamlit app

HOST_PORT=11060
CONTAINER_NAME="codeqai_11060"

echo "========================================"
echo "CodeQAI Tutorial PoC"
echo "========================================"
echo ""

# Step 1: Start the container if not running
if [ ! "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Step 1: Starting CodeQAI container..."
    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
    docker run -d \
        --name ${CONTAINER_NAME} \
        -p ${HOST_PORT}:8501 \
        --restart unless-stopped \
        llmsc-security/fynnfluegge--codeqai:latest
    echo "Waiting for service to be ready..."
    sleep 10
else
    echo "Step 1: Container is already running."
fi
echo ""

# Step 2: Check health endpoint
echo "Step 2: Checking service health..."
if command -v curl &> /dev/null; then
    curl -s http://localhost:${HOST_PORT}/_stcore/health | head -c 200
    echo ""
else
    echo "curl not installed, skipping health check"
fi
echo ""

# Step 3: Show service information
echo "Step 3: Service Information"
echo "========================================"
echo "  URL:           http://localhost:${HOST_PORT}"
echo "  Container:     ${CONTAINER_NAME}"
echo "  Image:         llmsc-security/fynnfluegge--codeqai:latest"
echo "  Description:   Streamlit app for code semantic search and chat"
echo ""

# Step 4: Open in browser (if xdg-open is available)
if command -v xdg-open &> /dev/null; then
    echo "Step 4: Opening in browser..."
    xdg-open "http://localhost:${HOST_PORT}" 2>/dev/null || true
else
    echo "Step 4: Open manually at http://localhost:${HOST_PORT}"
fi
echo ""

# Step 5: Show available features
echo "Step 5: Available Features"
echo "========================================"
echo "  - Semantic code search"
echo "  - Chat with codebase"
echo "  - Codebase indexing"
echo "  - Finetuning dataset generation"
echo ""

# Step 6: Stop container (optional cleanup)
echo "To stop the container, run:"
echo "  docker stop ${CONTAINER_NAME}"
echo ""

echo "Tutorial completed successfully!"
