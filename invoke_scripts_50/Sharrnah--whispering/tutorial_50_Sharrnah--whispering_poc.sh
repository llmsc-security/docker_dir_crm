#!/bin/bash
# Tutorial PoC script for Sharrnah--whispering
# This script demonstrates how to use the Whispering Tiger audio processing

set -e

echo "=== Whispering Tiger PoC ==="
echo "This demo shows how to use the Whispering Tiger audio processing with Docker"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if the image exists
if ! docker image inspect whispering-image:latest &> /dev/null; then
    echo "Error: whispering-image:latest not found"
    echo "Please run the invoke script first to build the image"
    exit 1
fi

echo "=== Application Information ==="
echo "Port: 11010 (host) -> 5000 (container)"
echo "Type: WebSocket server for audio transcription"
echo ""

echo "=== Usage ==="
echo ""
echo "1. Start the application:"
echo "   docker run --rm -it \\"
echo "     -p 11010:5000 \\"
echo "     whispering-image:latest"
echo ""
echo "2. Access via WebSocket:"
echo "   ws://localhost:11010"
echo ""
echo "3. WebSocket message format:"
echo '   {"type": "start", "language": "en"}'
echo '   {"type": "audio", "data": "...base64 audio..."}'
echo '   {"type": "stop"}'
echo ""
echo "=== Features ==="
echo "- Real-time audio transcription"
echo "- Multiple language support"
echo "- Speaker diarization"
echo "- Audio processing with Whisper"
echo ""
echo "=== Quick Test ==="
echo "docker run --rm -it \\"
echo "  -p 11010:5000 \\"
echo "  whispering-image:latest"
echo ""
echo "Then connect via WebSocket to ws://localhost:11010"
