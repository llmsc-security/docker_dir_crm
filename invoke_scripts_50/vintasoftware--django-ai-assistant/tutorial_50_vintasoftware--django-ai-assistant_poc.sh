#!/bin/bash
# Tutorial PoC script for vintasoftware--django-ai-assistant
# This script demonstrates how to use the Django AI Assistant

set -e

echo "=== Django AI Assistant PoC ==="
echo "This demo shows how to use the Django AI Assistant with Docker"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if the image exists
if ! docker image inspect django-ai-assistant-image:latest &> /dev/null; then
    echo "Error: django-ai-assistant-image:latest not found"
    echo "Please run the invoke script first to build the image"
    exit 1
fi

echo "=== Application Information ==="
echo "Port: 11140 (host) -> 8000 (container)"
echo "Type: Django web application with AI assistant"
echo ""

echo "=== Usage ==="
echo ""
echo "1. Start the application:"
echo "   docker run --rm -it \\"
echo "     -e OPENAI_API_KEY=\${OPENAI_API_KEY} \\"
echo "     -p 11140:8000 \\"
echo "     django-ai-assistant-image:latest"
echo ""
echo "2. Access the application:"
echo "   Open http://localhost:11140 in your browser"
echo ""
echo "3. Default credentials (if created):"
echo "   Username: admin"
echo "   Password: adminpassword"
echo ""
echo "=== API Endpoints ==="
echo "- /admin - Django admin panel"
echo "- /api/ - AI assistant API endpoints"
echo "- / - Main application page"
echo ""
echo "=== Quick Test ==="
echo "export OPENAI_API_KEY=your_key_here"
echo "docker run --rm -it \\"
echo "  -e OPENAI_API_KEY=\${OPENAI_API_KEY} \\"
echo "  -p 11140:8000 \\"
echo "  django-ai-assistant-image:latest"
