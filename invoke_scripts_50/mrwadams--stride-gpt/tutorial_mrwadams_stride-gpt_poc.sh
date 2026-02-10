#!/bin/bash
# Tutorial PoC script for testing mrwadams--stride-gpt HTTP endpoints
# Port: 11040

set -e

HOST="localhost"
PORT="11040"

echo "=========================================="
echo "mrwadams--stride-gpt - Tutorial PoC"
echo "=========================================="
echo ""

# Test the HTTP service
echo "Testing HTTP service at http://${HOST}:${PORT}..."

# Check if the service is running
if curl -s "http://${HOST}:${PORT}/health" > /dev/null 2>&1; then
    echo "Service is running!"
else
    echo "Service may not be running. Trying to access the main page..."
fi

# Try to access the main page
echo ""
echo "Accessing main page..."
curl -s "http://${HOST}:${PORT}/" | head -30

echo ""
echo "=========================================="
echo "Tutorial PoC Complete!"
echo "=========================================="
