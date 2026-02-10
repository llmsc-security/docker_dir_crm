#!/bin/bash
set -e

# Setup NLTK data directory
mkdir -p /app/.cache/nltk/tokenizers
export NLTK_DATA=/app/.cache/nltk

# Start WebSocket server and audio processing
# The main entry point is audioWhisper.py which starts the WebSocket server on port 8765
cd /app

# Run the main Whispering Tiger application
exec python audioWhisper.py --port 8765
