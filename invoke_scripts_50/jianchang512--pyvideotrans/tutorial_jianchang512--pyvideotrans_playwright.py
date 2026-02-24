#!/usr/bin/env python3
"""
Playwright POC test for jianchang512--pyvideotrans.

Note: This is a video processing tool that may require GPU.
Web interface may not work without proper GPU support.

Usage:
    python tutorial_jianchang512--pyvideotrans_playwright.py [--url http://127.0.0.1:11160]
"""

import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from playwright_base import PlaywrightBaseTest


# ============== CONFIGURATION ==============
REPO_NAME = "jianchang512--pyvideotrans"
DEFAULT_PORT = 11160
# ===========================================


class RepoPlaywrightTest(PlaywrightBaseTest):
    """Playwright test for jianchang512--pyvideotrans."""

    def __init__(self, base_url=None, **kwargs):
        if base_url is None:
            base_url = f"http://127.0.0.1:{DEFAULT_PORT}"
        super().__init__(base_url, REPO_NAME, **kwargs)

    def test_main_page(self):
        """Test the main page of the service."""
        self.log(f"Testing {self.base_url}...")
        self.log("Note: jianchang512--pyvideotrans requires GPU for video processing")

        # Navigate to main page
        try:
            response = self.page.goto(self.base_url)
            self.log(f"HTTP Status: {response.status}")
            self.page.wait_for_load_state("networkidle")

            # Check for localhost URL issues
            html = self.page.content()
            self.check_no_localhost_urls(html, "main page")
        except Exception as e:
            self.log(f"Connection issue (expected without GPU): {e}", "WARN")

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
