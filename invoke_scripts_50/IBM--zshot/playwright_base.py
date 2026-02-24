#!/usr/bin/env python3
"""
Base Playwright test module for Docker container verification.

This module provides a base class for creating browser-based POC tests
that simulate real user interactions with containerized web services.

Usage:
    from playwright_base import PlaywrightBaseTest

    class MyRepoTest(PlaywrightBaseTest):
        def test_main_page(self):
            self.page.goto(self.base_url)
            # Add your test logic here

    if __name__ == "__main__":
        test = MyRepoTest("http://127.0.0.1:11000")
        test.run()
"""

import os
import sys
import json
from datetime import datetime
from typing import Optional
from pathlib import Path

try:
    from playwright.sync_api import sync_playwright, Page, Browser, BrowserContext
    PLAYWRIGHT_AVAILABLE = True
except ImportError:
    PLAYWRIGHT_AVAILABLE = False
    print("Warning: Playwright not installed. Run: pip install playwright && playwright install")


class PlaywrightBaseTest:
    """Base class for Playwright-based POC tests."""

    def __init__(
        self,
        base_url: str,
        repo_name: str = "unknown",
        log_dir: Optional[str] = None,
        headless: bool = True,
        timeout: int = 30000,
    ):
        """
        Initialize the test.

        Args:
            base_url: The base URL of the service (e.g., http://127.0.0.1:11000)
            repo_name: Repository name for logging
            log_dir: Directory for log files
            headless: Run browser in headless mode
            timeout: Default timeout in milliseconds
        """
        self.base_url = base_url.rstrip("/")
        self.repo_name = repo_name
        self.log_dir = log_dir or "/tmp/playwright_logs"
        self.headless = headless
        self.timeout = timeout

        # Create log directory
        Path(self.log_dir).mkdir(parents=True, exist_ok=True)

        # Test state
        self.passed = True
        self.results = []
        self.page: Optional[Page] = None
        self.browser: Optional[Browser] = None
        self.context: Optional[BrowserContext] = None

    def log(self, message: str, level: str = "INFO"):
        """Log a message."""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] {message}"
        print(log_entry)
        self.results.append({"timestamp": timestamp, "level": level, "message": message})

    def assert_true(self, condition: bool, message: str):
        """Assert that a condition is true."""
        if condition:
            self.log(f"✓ PASS: {message}")
        else:
            self.log(f"✗ FAIL: {message}", "ERROR")
            self.passed = False

    def assert_status_code(self, response, expected: int = 200):
        """Assert HTTP status code."""
        actual = response.status
        if actual == expected:
            self.log(f"✓ HTTP {actual} (expected {expected})")
        else:
            self.log(f"✗ HTTP {actual} (expected {expected})", "ERROR")
            self.passed = False

    def check_no_localhost_urls(self, html: str, description: str = "page"):
        """Check that there are no hardcoded localhost URLs in the HTML."""
        import re

        # Find localhost URLs that are NOT the base URL
        localhost_pattern = r'(http://(?:localhost|127\.0\.0\.1):(\d+))'
        matches = re.findall(localhost_pattern, html)

        base_port = self.base_url.split(":")[-1] if ":" in self.base_url else "80"

        problematic_urls = []
        for url, port in matches:
            if port != base_port:
                problematic_urls.append(url)

        if problematic_urls:
            self.log(f"✗ Found hardcoded localhost URLs in {description}: {problematic_urls}", "WARN")
            return False
        else:
            self.log(f"✓ No problematic localhost URLs in {description}")
            return True

    def setup(self):
        """Set up browser and page."""
        if not PLAYWRIGHT_AVAILABLE:
            self.log("Playwright not available, skipping browser test", "WARN")
            return False

        self.log(f"Starting browser (headless={self.headless})...")

        playwright = sync_playwright().start()

        # Launch browser
        self.browser = playwright.chromium.launch(
            headless=self.headless,
            args=[
                "--no-sandbox",
                "--disable-setuid-sandbox",
                "--disable-dev-shm-usage",
                "--disable-gpu",
            ]
        )

        # Create context
        self.context = self.browser.new_context(
            viewport={"width": 1920, "height": 1080},
            ignore_https_errors=True,
        )

        # Create page
        self.page = self.context.new_page()
        self.page.set_default_timeout(self.timeout)

        self.log("Browser started successfully")
        return True

    def teardown(self):
        """Clean up browser resources."""
        if self.context:
            self.context.close()
        if self.browser:
            self.browser.close()
        self.log("Browser closed")

    def save_report(self):
        """Save test report to JSON file."""
        report_path = os.path.join(
            self.log_dir,
            f"{self.repo_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        )

        report = {
            "repo_name": self.repo_name,
            "base_url": self.base_url,
            "timestamp": datetime.now().isoformat(),
            "passed": self.passed,
            "results": self.results,
        }

        with open(report_path, "w") as f:
            json.dump(report, f, indent=2)

        self.log(f"Report saved to: {report_path}")
        return report_path

    def run(self, test_func=None):
        """
        Run the test.

        Args:
            test_func: Optional test function to run. If None, runs test_main_page.
        """
        self.log(f"Starting Playwright test for {self.repo_name}")
        self.log(f"Base URL: {self.base_url}")

        if not self.setup():
            return self.passed

        try:
            if test_func:
                test_func(self.page)
            else:
                self.test_main_page()
        except Exception as e:
            self.log(f"Test error: {str(e)}", "ERROR")
            self.passed = False
        finally:
            self.teardown()
            self.save_report()

        status = "PASSED" if self.passed else "FAILED"
        self.log(f"Test {status}")
        return self.passed

    def test_main_page(self):
        """Default test: load main page and check for issues."""
        self.log(f"Navigating to {self.base_url}...")

        response = self.page.goto(self.base_url)
        self.assert_status_code(response, 200)

        # Wait for page to load
        self.page.wait_for_load_state("networkidle")

        # Check for localhost URL issues
        html = self.page.content()
        self.check_no_localhost_urls(html, "main page")

        # Take screenshot
        screenshot_path = os.path.join(
            self.log_dir,
            f"{self.repo_name}_screenshot.png"
        )
        self.page.screenshot(path=screenshot_path)
        self.log(f"Screenshot saved to: {screenshot_path}")


def main():
    """Example usage."""
    if len(sys.argv) < 2:
        print("Usage: python playwright_base.py <base_url> [repo_name]")
        sys.exit(1)

    base_url = sys.argv[1]
    repo_name = sys.argv[2] if len(sys.argv) > 2 else "test"

    test = PlaywrightBaseTest(base_url, repo_name)
    test.run()

    sys.exit(0 if test.passed else 1)


if __name__ == "__main__":
    main()
