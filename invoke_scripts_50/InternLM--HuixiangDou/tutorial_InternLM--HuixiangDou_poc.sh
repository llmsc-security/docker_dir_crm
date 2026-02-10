#!/bin/bash
# Tutorial / PoC for HuixiangDou Docker container
# This script demonstrates how to interact with the HuixiangDou Gradio service
# Running on host port 11390 (container port 7860)

set -e

BASE_URL="http://localhost:11390"

echo "=========================================="
echo "HuixiangDou Docker Container API Tutorial"
echo "=========================================="
echo "Base URL: $BASE_URL"
echo ""

# Test 1: Check if service is running
echo "Test 1: Checking service availability..."
echo "------------------------------------------"
if curl -s -o /dev/null -w "%{http_code}" "$BASE_URL" | grep -q "200"; then
    echo "Service is running!"
else
    echo "WARNING: Could not connect to HuixiangDou server."
    echo "Make sure the Docker container is running:"
    echo "  ./invoke_InternLM--HuixiangDou.sh"
    exit 1
fi
echo ""

# Test 2: Basic Gradio UI access
echo "Test 2: Accessing Gradio UI..."
echo "------------------------------------------"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\nTotal Time: %{time_total}s\n" "$BASE_URL"
echo ""

# Test 3: API endpoint test (Gradio doesn't have the same API endpoints as api_server)
# Gradio UI is primarily for interactive chat through the web interface
echo "Test 3: Gradio UI Access"
echo "------------------------------------------"
echo "The Gradio UI is accessible at: $BASE_URL"
echo "You can interact with the AI assistant through the web interface."
echo ""

# Test 4: Display connection info
echo "Test 4: Connection Information"
echo "------------------------------------------"
echo "Host Port: 11390"
echo "Container Port: 7860"
echo "Service: Gradio AI Assistant"
echo "Repository: /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/InternLM--HuixiangDou"
echo ""

echo "=========================================="
echo "Tutorial Complete!"
echo "=========================================="
echo ""
echo "To start the HuixiangDou server:"
echo "  cd /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/InternLM--HuixiangDou"
echo "  ./invoke_InternLM--HuixiangDou.sh"
echo ""
echo "Then access the Gradio UI at: http://localhost:11390"
echo ""

exit 0
