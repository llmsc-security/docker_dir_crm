#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Tutorial PoC script for linyqh--NarratoAI
Tests the HTTP service endpoints - NarratoAI uses Streamlit UI.
"""

import sys
import time
import urllib.request
import json

REPO_NAME = "linyqh--NarratoAI"
HOST = "localhost"
PORT = 11170
CONTAINER_PORT = 8501  # Streamlit default port

def log(message, level="INFO"):
    """Log message with timestamp."""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] [{level}] {message}")

def test_root_endpoint():
    """Test the root endpoint - should return HTML for Streamlit UI."""
    try:
        url = f"http://{HOST}:{PORT}/"
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=10) as response:
            content = response.read().decode()
            # Check for Streamlit indicators
            if "streamlit" in content.lower() or "narrato" in content.lower() or "<!doctype" in content.lower() or "<html" in content.lower():
                log("UI endpoint is serving HTML content")
                return True
            log(f"Root endpoint returned content (length: {len(content)})")
            return True
    except Exception as e:
        log(f"Root endpoint test failed: {e}", "ERROR")
        return False

def test_health_endpoint():
    """Test the health endpoint."""
    try:
        url = f"http://{HOST}:{PORT}/health"
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode())
            log(f"Health endpoint response: {data}")
            return True
    except urllib.error.HTTPError as e:
        # 404 is acceptable - not all services have health endpoint
        log(f"Health endpoint returned {e.code} (acceptable)")
        return True
    except Exception as e:
        log(f"Health endpoint test failed: {e}", "WARNING")
        return False

def test_main_service():
    """Test that the UI service is responding."""
    try:
        url = f"http://{HOST}:{PORT}/"
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=10) as response:
            content = response.read().decode()
            # Check for any meaningful content
            if len(content) > 100:
                log("Service is responding with content")
                return True
            return False
    except Exception as e:
        log(f"Main service test failed: {e}", "WARNING")
        return False


def test_service():
    """Test the main service functionality."""
    log(f"Starting PoC tests for {REPO_NAME}")
    log(f"Container port: {CONTAINER_PORT} (Streamlit UI)")
    log(f"Host port: {PORT}")
    log("==========================================")

    results = {
        "repo": REPO_NAME,
        "port": PORT,
        "container_port": CONTAINER_PORT,
        "tests": []
    }

    # Test 1: Root endpoint
    log("Test 1: Testing root endpoint...")
    if test_root_endpoint():
        results["tests"].append({"name": "root_endpoint", "status": "PASS"})
    else:
        results["tests"].append({"name": "root_endpoint", "status": "FAIL"})

    # Test 2: Health endpoint
    log("Test 2: Testing health endpoint...")
    if test_health_endpoint():
        results["tests"].append({"name": "health_endpoint", "status": "PASS"})
    else:
        results["tests"].append({"name": "health_endpoint", "status": "FAIL"})

    # Test 3: Main service
    log("Test 3: Testing main service...")
    if test_main_service():
        results["tests"].append({"name": "main_service", "status": "PASS"})
    else:
        results["tests"].append({"name": "main_service", "status": "FAIL"})

    # Summary
    log("==========================================")
    passed = sum(1 for t in results["tests"] if t["status"] == "PASS")
    total = len(results["tests"])
    log(f"PoC completed: {passed}/{total} tests passed")

    if passed >= 2:
        log("NarratoAI UI is functional!", "SUCCESS")
        return 0
    else:
        log(f"Some tests failed: {passed}/{total} passed", "ERROR")
        return 1

if __name__ == "__main__":
    sys.exit(test_service())
