#!/bin/bash
# Tutorial PoC script for bhaskatripathi--pdfGPT
# Service: Gradio-based PDF GPT chat application (port 11340)
# This script demonstrates a basic Proof of Concept usage

set -e

PORT_HOST=11340
CONTAINER_NAME="pdfgpt-poc"
LOG_FILE="/tmp/pdfgpt_poc.log"

echo "=========================================="
echo "PDF GPT PoC Tutorial"
echo "=========================================="
echo ""
echo "This is a Proof of Concept demonstration for:"
echo "  Repository: bhaskatripathi--pdfGPT"
echo "  Port: ${PORT_HOST}"
echo "  Service: Gradio-based PDF chat application"
echo ""
echo "=========================================="
echo "Step 1: Starting the PDF GPT container"
echo "=========================================="

# Stop and remove existing container if present
if docker ps -q --filter "name=${CONTAINER_NAME}" | grep -q .; then
    echo "Stopping existing container..."
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
fi

# Run the container
echo "Starting PDF GPT container on port ${PORT_HOST}..."
docker run -d \
    --name ${CONTAINER_NAME} \
    -p ${PORT_HOST}:7860 \
    -e OPENAI_API_KEY="${OPENAI_API_KEY:-}" \
    --restart unless-stopped \
    pdfgpt:latest

echo ""
echo "Container started successfully!"
echo "Container name: ${CONTAINER_NAME}"
echo ""
echo "=========================================="
echo "Step 2: Waiting for service to be ready"
echo "=========================================="

# Wait for service to be ready
sleep 10

# Check if service is responding
echo "Checking service health..."
if curl -s -o /dev/null -w "%{http_code}" "http://localhost:${PORT_HOST}" | grep -q "200"; then
    echo "Service is responding on http://localhost:${PORT_HOST}"
else
    echo "Service may be starting up... checking logs"
    docker logs ${CONTAINER_NAME} 2>/dev/null | tail -20
fi

echo ""
echo "=========================================="
echo "Step 3: Access the application"
echo "=========================================="
echo ""
echo "Open your browser and navigate to:"
echo "  http://localhost:${PORT_HOST}"
echo ""
echo "Usage instructions:"
echo "  1. Enter your API Host (default: http://localhost:8080)"
echo "  2. Enter your OpenAI API key"
echo "  3. Enter a PDF URL or upload a PDF file"
echo "  4. Ask a question about the document"
echo "  5. Click Submit to get answers"
echo ""
echo "=========================================="
echo "Step 4: Container management commands"
echo "=========================================="
echo ""
echo "View logs:    docker logs -f ${CONTAINER_NAME}"
echo "Stop service: docker stop ${CONTAINER_NAME}"
echo "Remove:       docker rm ${CONTAINER_NAME}"
echo ""
echo "=========================================="
echo "PoC completed successfully!"
echo "=========================================="
