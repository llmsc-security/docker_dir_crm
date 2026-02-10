#!/bin/bash
# Tutorial PoC script for Integuru-AI--Integuru
# This script demonstrates how to use the Integuru AI agent

set -e

echo "=== Integuru AI Agent PoC ==="
echo "This demo shows how to use the Integuru AI agent with Docker"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if the image exists
if ! docker image inspect integuru-image:latest &> /dev/null; then
    echo "Error: integuru-image:latest not found"
    echo "Please run the invoke script first to build the image"
    exit 1
fi

# Create logs directory
mkdir -p /tmp/integuru_logs

echo "=== Available Commands ==="
echo ""
echo "1. Run with default settings (requires OPENAI_API_KEY):"
echo "   docker run --rm -it \\"
echo "     -e OPENAI_API_KEY=\${OPENAI_API_KEY} \\"
echo "     -v /tmp/integuru_logs:/app/logs \\"
echo "     integuru-image:latest \\"
echo "     --prompt 'Your natural language task description' \\"
echo "     --model gpt-4o"
echo ""
echo "2. Run with HAR file (for web automation):"
echo "   docker run --rm -it \\"
echo "     -e OPENAI_API_KEY=\${OPENAI_API_KEY} \\"
echo "     -v /tmp/integuru_logs:/app/logs \\"
echo "     -v /path/to/your/file.har:/app/network_requests.har \\"
echo "     -v /path/to/your/cookies.json:/app/cookies.json \\"
echo "     integuru-image:latest \\"
echo "     --prompt 'Your task' \\"
echo "     --har-path /app/network_requests.har \\"
echo "     --cookie-path /app/cookies.json"
echo ""
echo "3. Run with custom variables:"
echo "   docker run --rm -it \\"
echo "     -e OPENAI_API_KEY=\${OPENAI_API_KEY} \\"
echo "     -v /tmp/integuru_logs:/app/logs \\"
echo "     integuru-image:latest \\"
echo "     --prompt 'Generate code for \${variable1} and \${variable2}' \\"
echo "     --input_variables var1 value1 \\"
echo "     --input_variables var2 value2"
echo ""
echo "4. Generate full integration code (without running):"
echo "   docker run --rm -it \\"
echo "     -e OPENAI_API_KEY=\${OPENAI_API_KEY} \\"
echo "     -v /tmp/integuru_logs:/app/logs \\"
echo "     integuru-image:latest \\"
echo "     --prompt 'Your task' \\"
echo "     --generate-code"
echo ""
echo "=== Notes ==="
echo "- The default port mapping is 11070:11070"
echo "- Logs are written to /app/logs inside the container"
echo "- HAR and cookies files are used for web automation scenarios"
echo "- Input variables allow parameterized prompts"
echo ""

echo "=== Quick Test ==="
echo "To run a simple test, execute:"
echo "export OPENAI_API_KEY=your_key_here"
echo 'docker run --rm -it \\'
echo '  -e OPENAI_API_KEY=${OPENAI_API_KEY} \\'
echo '  -v /tmp/integuru_logs:/app/logs \\'
echo '  integuru-image:latest \\'
echo '  --prompt "Hello, how are you?" --model gpt-4o'
