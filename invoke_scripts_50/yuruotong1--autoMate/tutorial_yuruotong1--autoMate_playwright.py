#!/usr/bin/env python3
"""
Playwright POC test for yuruotong1--autoMate.

Usage:
    python tutorial_yuruotong1--autoMate_playwright.py [--url http://127.0.0.1:11020]
"""

import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from playwright_base import PlaywrightBaseTest


# ============== CONFIGURATION ==============
REPO_NAME = "yuruotong1--autoMate"
DEFAULT_PORT = 11020
# ===========================================


class RepoPlaywrightTest(PlaywrightBaseTest):
    """Playwright test for yuruotong1--autoMate."""

    def __init__(self, base_url=None, **kwargs):
        if base_url is None:
            base_url = f"http://127.0.0.1:{DEFAULT_PORT}"
        super().__init__(base_url, REPO_NAME, **kwargs)

    def test_main_page(self):
        """Test the main page of the service."""
        self.log(f"Testing {self.base_url}...")

        # Navigate to main page
        response = self.page.goto(self.base_url)
        self.assert_status_code(response)
        self.page.wait_for_load_state("networkidle")

        # Check for localhost URL issues
        html = self.page.content()
        self.check_no_localhost_urls(html, "main page")

        # Take screenshot
        try:
            screenshot_path = os.path.join(
                self.log_dir,
                f"{REPO_NAME}_screenshot.png"
            )
            self.page.screenshot(path=screenshot_path)
            self.log(f"Screenshot saved to: {screenshot_path}")
        except Exception as e:
            self.log(f"Could not take screenshot: {e}", "WARN")

        self.log("Test completed")


def main():
    """Run the test."""
    import argparse

    parser = argparse.ArgumentParser(description=f"Playwright POC test for {REPO_NAME}")
    parser.add_argument("--url", default=None, help=f"Base URL (default: http://127.0.0.1:{DEFAULT_PORT})")
    parser.add_argument("--headless", action="store_true", default=True, help="Run in headless mode")
    parser.add_argument("--no-headless", action="store_false", dest="headless", help="Run with visible browser")
    parser.add_argument("--log-dir", default="/tmp/playwright_logs", help="Log directory")

    args = parser.parse_args()

    test = RepoPlaywrightTest(
        base_url=args.url,
        headless=args.headless,
        log_dir=args.log_dir,
    )

    success = test.run()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
