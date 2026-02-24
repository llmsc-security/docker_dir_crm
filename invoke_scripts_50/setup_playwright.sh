#!/bin/bash
# Setup Playwright for all repositories and generate test scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
REPO_DIR="$BASE_DIR/repo_dirs"

echo "=== Playwright Setup for Docker Containers ==="
echo ""

# Install playwright if not already installed
echo "Step 1: Installing Playwright..."
if ! python3 -c "import playwright" 2>/dev/null; then
    echo "Installing playwright Python package..."
    pip install playwright
    echo "Installing browsers..."
    playwright install chromium
else
    echo "Playwright already installed"
fi

# Create base test module if not exists
echo ""
echo "Step 2: Creating base test module..."
if [ ! -f "$SCRIPT_DIR/playwright_base.py" ]; then
    echo "Creating playwright_base.py..."
    # Copy from template or create new
    cat > "$SCRIPT_DIR/playwright_base.py" << 'PYEOF'
# Base module will be created separately
PYEOF
fi

# Generate repo-specific test scripts
echo ""
echo "Step 3: Generating repo-specific test scripts..."

# List of repos with their ports
declare -A ports=(
    ["shibing624--pycorrector"]=11000
    ["mrwadams--stride-gpt"]=11040
    ["AbanteAI--rawdog"]=11050
    ["fynnfluegge--codeqai"]=11060
    ["Integuru-AI--Integuru"]=11070
    ["zyddnys--manga-image-translator"]=11080
    ["adithya-s-k--omniparse"]=11090
    ["stitionai--devika"]=11100
    ["mrwadams_attackgen"]=11110
    ["ur-whitelab--chemcrow-public"]=11120
    ["gptme--gptme"]=11130
    ["vintasoftware--django-ai-assistant"]=11140
    ["linyqh--NarratoAI"]=11170
    ["bowang-lab--medrax"]=11180
    ["finaldie-auto-news"]=11190
    ["IBM--zshot"]=11200
    ["OpenDCAI--DataFlow"]=11210
    ["taskmatrix"]=11220
    ["reworkd--AgentGPT"]=11230
    ["microsoft--magentic-ui"]=11240
    ["assafelovic--gpt-researcher"]=11250
    ["snap-stanford--Biomni"]=11260
    ["binary-husky--gpt_academic"]=11270
    ["microsoft--TaskWeaver"]=11280
    ["microsoft--RD-Agent"]=11290
    ["shroominic--codeinterpreter-api"]=11300
    ["acon96--home-llm"]=11310
    ["Paper2Poster--Paper2Poster"]=11320
    ["bhaskatripathi-pdfgpt"]=11340
    ["PromtEngineer--localGPT"]=11350
    ["TauricResearch--TradingAgents"]=11360
    ["666ghj--BettaFish"]=11370
    ["auvalab--itext2kg"]=11380
    ["InternLM--HuixiangDou"]=11390
    ["SWE-agent--SWE-agent"]=11400
    ["barun-saha--slide-deck-ai"]=11410
    ["modelscope--funclip"]=11430
    ["zwq2018--Data-Copilot"]=11440
    ["yihong0618--bilingual_book_maker"]=11450
    ["nekoparapa--ainenie"]=11460
    ["yuka-friends--windrecorder"]=11480
)

generated=0
for repo in "${!ports[@]}"; do
    port=${ports[$repo]}
    test_file="$SCRIPT_DIR/tutorial_${repo}_playwright.py"

    if [ ! -f "$test_file" ]; then
        echo "  Creating: tutorial_${repo}_playwright.py (port $port)"

        # Generate repo-specific test file
        cat > "$test_file" << PYEOF
#!/usr/bin/env python3
"""
Playwright POC test for $repo.

Usage:
    python tutorial_${repo}_playwright.py [--url http://127.0.0.1:$port]
"""

import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from playwright_base import PlaywrightBaseTest


# ============== CONFIGURATION ==============
REPO_NAME = "$repo"
DEFAULT_PORT = $port
# ===========================================


class RepoPlaywrightTest(PlaywrightBaseTest):
    """Playwright test for $repo."""

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
PYEOF
        chmod +x "$test_file"
        ((generated++))
    fi
done

echo ""
echo "=== Setup Complete ==="
echo "Generated $generated new Playwright test scripts"
echo ""
echo "Usage:"
echo "  python $SCRIPT_DIR/tutorial_<repo>_playwright.py --url http://127.0.0.1:<port>"
echo ""
echo "Example:"
echo "  python $SCRIPT_DIR/tutorial_shibing624--pycorrector_playwright.py"
