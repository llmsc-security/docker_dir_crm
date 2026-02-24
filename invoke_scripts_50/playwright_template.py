#!/usr/bin/env python3
"""
Template for creating Playwright POC tests for specific repositories.

Copy this file and customize it for each repository:
  cp playwright_template.py tutorial_<repo>_playwright.py

Then customize:
1. Update REPO_NAME and DEFAULT_PORT
2. Customize test_main_page() with repo-specific selectors
3. Add additional test methods as needed
"""

import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from playwright_base import PlaywrightBaseTest


# ============== CONFIGURATION ==============
REPO_NAME = "<repo_name>"  # e.g., "shibing624--pycorrector"
DEFAULT_PORT = 11000  # Replace with assigned port
# ===========================================


class RepoPlaywrightTest(PlaywrightBaseTest):
    """Playwright test for <repo_name>."""

    def __init__(self, base_url=None, **kwargs):
        if base_url is None:
            base_url = f"http://127.0.0.1:{DEFAULT_PORT}"
        super().__init__(base_url, REPO_NAME, **kwargs)

    def test_main_page(self):
        """
        Test the main page of the service.

        Customize this method for your repo:
        1. Navigate to specific pages
        2. Interact with UI elements
        3. Verify expected content
        4. Test API endpoints via browser
        """
        # Navigate to main page
        self.log(f"Testing {self.base_url}...")
        response = self.page.goto(self.base_url)
        self.assert_status_code(response)

        # Wait for page to load
        self.page.wait_for_load_state("networkidle")

        # Example: Check for specific content
        # Customize these selectors for your repo
        try:
            # Wait for a specific element that indicates the app is loaded
            # Example: self.page.wait_for_selector("#app", timeout=10000)
            self.log("Page loaded successfully")
        except Exception as e:
            self.log(f"Warning: Could not verify app-specific element: {e}", "WARN")

        # Check for localhost URL issues
        html = self.page.content()
        self.check_no_localhost_urls(html, "main page")

        # Example: Take screenshot
        # self.page.screenshot(path=f"/tmp/playwright_logs/{REPO_NAME}_main.png")

        # ============== CUSTOMIZE BELOW ==============
        # Add your repo-specific test logic here
        # Examples:
        #
        # # For Gradio apps:
        # self.page.wait_for_selector("gradio-app")
        #
        # # For Streamlit apps:
        # self.page.wait_for_selector("[data-testid='stApp']")
        #
        # # For FastAPI docs:
        # if "/docs" in self.base_url:
        #     self.page.wait_for_selector(".swagger-ui")
        #
        # # Test input and submission:
        # self.page.fill("input#query", "test input")
        # self.page.click("button#submit")
        # self.page.wait_for_selector(".result")
        # ===========================================

        self.log("Main page test completed")


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
