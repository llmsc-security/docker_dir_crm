#!/bin/bash
# ============================================================
# Batch Verification Script for all 10 repos
# port_mapping_50_gap10_4.json
# ============================================================

echo "=============================================="
echo "Batch Verification for 10 Repos"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

passed=0
failed=0

# Test function
test_repo() {
    local repo=$1
    local port=$2
    echo -n "Testing $repo (port $port)... "

    # Test root endpoint
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/ 2>&1)

    if [ "$response" != "000" ]; then
        echo -e "${GREEN}PASS${NC} (HTTP $response)"
        ((passed++))
    else
        echo -e "${RED}FAIL${NC} (No response)"
        ((failed++))
    fi
}

# Test all 10 repos
test_repo "AbanteAI--rawdog" 11050
test_repo "adithya-s-k--omniparse" 11090
test_repo "stitionai--devika" 11100
test_repo "chenfei-wu--TaskMatrix" 11220
test_repo "reworkd--AgentGPT" 11230
test_repo "binary-husky--gpt_academic" 11270
test_repo "acon96--home-llm" 11310
test_repo "Paper2Poster--Paper2Poster" 11320
test_repo "TauricResearch--TradingAgents" 11360
test_repo "yihong0618--bilingual_book_maker" 11450

total=$((passed + failed))

echo ""
echo "=============================================="
echo "VERIFICATION SUMMARY"
echo "=============================================="
echo -e "Passed: ${GREEN}${passed}${NC}/${total}"
echo -e "Failed: ${RED}${failed}${NC}/${total}"
echo ""

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
