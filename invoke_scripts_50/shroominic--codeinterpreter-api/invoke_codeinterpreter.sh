#!/bin/bash
# invoke script for shroominic--codeinterpreter-api
# This script builds and runs the Docker container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
REPO_NAME="shroominic--codeinterpreter-api"
REPO_PATH="${BASE_DIR}/repo_dirs/${REPO_NAME}"
LOG_DIR="${BASE_DIR}/build_logs"

# Create log directory
mkdir -p "$LOG_DIR"

BUILD_LOG="${LOG_DIR}/${REPO_NAME}.build.log"

echo "=== Building Docker image for ${REPO_NAME} ==="
echo "Build started at: $(date)"

cd "$REPO_PATH"

# Build the Docker image
docker buildx build \
    --tag codeinterpreter-api-image:latest \
    --file Dockerfile \
    --progress=plain \
    . 2>&1 | tee "$BUILD_LOG"

BUILD_EXIT_CODE=${PIPESTATUS[0]}

echo "Build completed at: $(date)"

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "Build successful!"
    echo ""
    echo "=== Container Info ==="
    echo "Port mapping: 11300:8501"
    echo ""
    echo "=== To run the container ==="
    echo "docker run --rm -it \\"
    echo "  -p 11300:8501 \\"
    echo "  codeinterpreter-api-image:latest"
    echo ""
    echo "=== Access the service ==="
    echo "Open http://localhost:11300 in your browser"
else
    echo "Build failed! Check ${BUILD_LOG} for details."
    exit 1
fi
