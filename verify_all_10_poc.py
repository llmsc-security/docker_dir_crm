#!/usr/bin/env python3
"""
Comprehensive PoC verification script for all 10 repos in port_mapping_50_gap10_4.json
Tests HTTP endpoints for all services.
"""

import sys
import time
import urllib.request
import json
from typing import Dict, List, Tuple

# Configuration for all 10 repos
REPOS = {
    "AbanteAI--rawdog": {"port": 11050, "container_port": 8000, "endpoints": ["/", "/health"]},
    "adithya-s-k--omniparse": {"port": 11090, "container_port": 8000, "endpoints": ["/"]},
    "stitionai--devika": {"port": 11100, "container_port": 1337, "endpoints": ["/"]},
    "chenfei-wu--TaskMatrix": {"port": 11220, "container_port": 11220, "endpoints": ["/"]},
    "reworkd--AgentGPT": {"port": 11230, "container_port": 11230, "endpoints": ["/"]},
    "binary-husky--gpt_academic": {"port": 11270, "container_port": 8000, "endpoints": ["/", "/health"]},
    "acon96--home-llm": {"port": 11310, "container_port": 11310, "endpoints": ["/", "/health"]},
    "Paper2Poster--Paper2Poster": {"port": 11320, "container_port": 7860, "endpoints": ["/"]},
    "TauricResearch--TradingAgents": {"port": 11360, "container_port": 11360, "endpoints": ["/", "/health"]},
    "yihong0618--bilingual_book_maker": {"port": 11450, "container_port": 7860, "endpoints": ["/"]},
}


def log(message: str, level: str = "INFO"):
    """Log message with timestamp."""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] [{level}] {message}")


def test_endpoint(host: str, port: int, endpoint: str, timeout: int = 10) -> Tuple[bool, str]:
    """Test a single HTTP endpoint."""
    try:
        url = f"http://{host}:{port}{endpoint}"
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=timeout) as response:
            status = response.status
            content_type = response.headers.get('Content-Type', '')
            return True, f"HTTP {status} ({content_type.split(';')[0] if content_type else 'unknown'})"
    except urllib.error.HTTPError as e:
        return True, f"HTTP {e.code} ({e.reason})"
    except Exception as e:
        return False, str(e)


def test_repo(repo_name: str, config: Dict) -> Dict:
    """Test all endpoints for a single repo."""
    log(f"Testing {repo_name} on port {config['port']}...")

    results = {
        "repo": repo_name,
        "port": config["port"],
        "container_port": config["container_port"],
        "tests": [],
        "passed": 0,
        "failed": 0
    }

    for endpoint in config["endpoints"]:
        success, message = test_endpoint("localhost", config["port"], endpoint)
        test_result = {
            "endpoint": endpoint,
            "success": success,
            "message": message
        }
        results["tests"].append(test_result)

        if success:
            results["passed"] += 1
            log(f"  ✓ {endpoint}: {message}", "PASS")
        else:
            results["failed"] += 1
            log(f"  ✗ {endpoint}: {message}", "FAIL")

    return results


def main():
    """Main function to run all tests."""
    log("=" * 60)
    log("Starting comprehensive PoC verification for all 10 repos")
    log("=" * 60)

    all_results = []
    total_passed = 0
    total_failed = 0

    for repo_name, config in REPOS.items():
        results = test_repo(repo_name, config)
        all_results.append(results)
        total_passed += results["passed"]
        total_failed += results["failed"]
        log("-" * 40)

    # Summary
    log("=" * 60)
    log("VERIFICATION SUMMARY")
    log("=" * 60)

    for results in all_results:
        status = "✓ PASS" if results["failed"] == 0 else "✗ PARTIAL" if results["passed"] > 0 else "✗ FAIL"
        log(f"{results['repo']:40} {status} ({results['passed']}/{results['passed'] + results['failed']} endpoints)")

    log("=" * 60)
    log(f"Total: {total_passed} passed, {total_failed} failed")
    log("=" * 60)

    if total_failed == 0:
        log("All tests passed!", "SUCCESS")
        return 0
    else:
        log(f"Some tests failed: {total_failed} endpoints", "ERROR")
        return 1


if __name__ == "__main__":
    sys.exit(main())
