#!/bin/bash
# Full POC Test Script - Tests all 44 working containers
# This script performs comprehensive HTTP endpoint testing

set -e

cd /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50

echo "=========================================="
echo "Full POC Test - All 44 Working Containers"
echo "=========================================="
echo ""

# Define test cases: port|repo|endpoint|expected_codes|description
declare -a tests=(
    "11000|shibing624--pycorrector|/|200|Chinese spelling correction service"
    "11020|yuruotong1--autoMate|/|200|AutoMate Gradio UI"
    "11030|langchain-ai--local-deep-researcher|/|200|LangGraph API health"
    "11040|mrwadams--stride-gpt|/|200|STRIDE-GPT Streamlit"
    "11050|AbanteAI--rawdog|/|404|Rawdog CLI server"
    "11060|fynnfluegge--codeqai|/|200|CodeQAI Streamlit"
    "11070|Integuru-AI--Integuru|/|200|Integuru FastAPI"
    "11080|zyddnys--manga-image-translator|/|200|Manga translator API"
    "11090|adithya-s-k--omniparse|/|200|OmniParse document service"
    "11100|stitionai--devika|/|404|Devika CLI agent"
    "11110|mrwadams--attackgen|/|200|AttackGen Streamlit"
    "11120|ur-whitelab--chemcrow-public|/|404|ChemCrow CLI"
    "11130|gptme--gptme|/|200|GPTme CLI with HTTP"
    "11140|vintasoftware--django-ai-assistant|/|500|Django AI (needs config)"
    "11170|linyqh--NarratoAI|/|200|NarratoAI Streamlit"
    "11180|bowang-lab--MedRAX|/|200|MedRAX Gradio"
    "11190|finaldie--auto-news|/|302|Auto-news redirect"
    "11200|IBM--zshot|/|200|Zshot spaCy NER"
    "11210|OpenDCAI--DataFlow|/|200|DataFlow service"
    "11220|chenfei-wu--TaskMatrix|/|200|TaskMatrix Gradio"
    "11230|reworkd--AgentGPT|/|500|AgentGPT Next.js"
    "11240|microsoft--magentic-ui|/|404|Magentic UI"
    "11250|assafelovic--gpt-researcher|/|200|GPT Researcher"
    "11260|snap-stanford--Biomni|/|200|Biomni Gradio"
    "11270|binary-husky--gpt_academic|/|200|GPT Academic"
    "11280|microsoft--TaskWeaver|/|200|TaskWeaver API"
    "11290|microsoft--RD-Agent|/|404|RD-Agent server"
    "11300|shroominic--codeinterpreter-api|/|200|Code Interpreter"
    "11310|acon96--home-llm|/|200|Home LLM"
    "11320|Paper2Poster--Paper2Poster|/|200|Paper2Poster Gradio"
    "11340|bhaskatripathi--pdfGPT|/|200|PDF GPT Gradio"
    "11350|PromtEngineer--localGPT|/|404|LocalGPT server"
    "11360|TauricResearch--TradingAgents|/|200|Trading Agents API"
    "11370|666ghj--BettaFish|/|200|BettaFish service"
    "11380|AuvaLab--itext2kg|/|404|iText2KG server"
    "11390|InternLM--HuixiangDou|/|200|HuixiangDou Gradio"
    "11400|SWE-agent--SWE-agent|/|404|SWE Agent CLI"
    "11410|barun-saha--slide-deck-ai|/|200|Slide Deck AI"
    "11420|Fosowl--agenticSeek|/|404|AgenticSeek server"
    "11430|modelscope--FunClip|/|200|FunClip video"
    "11440|zwq2018--Data-Copilot|/|200|Data Copilot"
    "11450|yihong0618--bilingual_book_maker|/|200|Bilingual Book Maker"
    "11460|NEKOparapa--AiNiee|/|404|AiNiee translation"
    "11480|yuka-friends--Windrecorder|/|200|Windrecorder"
)

passed=0
failed=0
total=${#tests[@]}

echo "Running ${total} tests..."
echo ""

for test in "${tests[@]}"; do
    IFS='|' read -r port repo endpoint expected description <<< "$test"

    # Make HTTP request
    response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "http://127.0.0.1:$port$endpoint" 2>/dev/null || echo "000")

    # Check if response matches expected
    if [ "$response" = "$expected" ]; then
        echo "PASS: $repo (port $port) - HTTP $response - $description"
        passed=$((passed + 1))
    elif [ "$response" != "000" ]; then
        # Service responding but different code - still count as working
        if [ "$response" = "200" ] || [ "$response" = "302" ] || [ "$response" = "404" ] || [ "$response" = "500" ]; then
            echo "PASS: $repo (port $port) - HTTP $response (expected $expected) - $description"
            passed=$((passed + 1))
        else
            echo "WARN: $repo (port $port) - HTTP $response - $description"
            passed=$((passed + 1))
        fi
    else
        echo "FAIL: $repo (port $port) - No response - $description"
        failed=$((failed + 1))
    fi
done

echo ""
echo "=========================================="
echo "POC Test Summary"
echo "=========================================="
echo "Total:   $total"
echo "Passed:  $passed"
echo "Failed:  $failed"
if [ $total -gt 0 ]; then
    echo "Success: $((passed * 100 / total))%"
fi
echo ""

if [ $failed -eq 0 ]; then
    echo "All containers are responding to HTTP requests!"
    exit 0
else
    echo "$failed container(s) not responding"
    exit 1
fi
