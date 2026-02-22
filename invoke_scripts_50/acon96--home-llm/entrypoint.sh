#!/bin/bash
set -e

echo "Starting Home LLM HTTP server..."
export PYTHONUNBUFFERED=1
cd /app

exec python http_server.py "$@"
