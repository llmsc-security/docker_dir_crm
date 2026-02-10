#!/bin/bash

# Data-Copilot Tutorial PoC
# This script demonstrates how to interact with the Data-Copilot Gradio app
# The app provides a natural language interface for querying Chinese financial data

echo "=========================================="
echo "Data-Copilot Tutorial PoC"
echo "=========================================="
echo ""

# Configuration
HOST_PORT=11440
BASE_URL="http://localhost:${HOST_PORT}"

echo "Step 1: Verify Data-Copilot is running"
echo "----------------------------------------"
if docker ps | grep -q "zwq2018--Data-Copilot"; then
    echo "[OK] Data-Copilot container is running."
    echo ""
    echo "Container info:"
    docker ps --filter "name=zwq2018--Data-Copilot" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo "[ERROR] Data-Copilot is not running."
    echo ""
    echo "To start Data-Copilot, run:"
    echo "  ./invoke_zwq2018--Data-Copilot.sh"
    echo ""
    echo "Then wait for the service to start (usually 10-20 seconds)."
    exit 1
fi

echo ""
echo "Step 2: Test Gradio App Accessibility"
echo "----------------------------------------"
# Test if the Gradio app is accessible
if curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}" | grep -q "200"; then
    echo "[OK] Gradio app is accessible at ${BASE_URL}"
else
    echo "[WARNING] Cannot reach Gradio app. It may still be starting up."
    echo "Please wait a few more seconds and try again."
fi

echo ""
echo "Step 3: Understanding Data-Copilot Capabilities"
echo "------------------------------------------------"
echo ""
echo "Data-Copilot is an LLM-based system that helps with data-related tasks."
echo "It connects data sources from different domains including:"
echo "  - Chinese stocks (股票)"
echo "  - Chinese funds (基金)"
echo "  - Chinese economic data (经济数据)"
echo "  - Chinese financial data (金融数据)"
echo ""
echo "Supported models:"
echo "  - OpenAI GPT-3.5"
echo "  - Azure GPT-3.5"
echo "  - Qwen-72b-Chat"
echo ""

echo "Step 4: Example Queries"
echo "-----------------------"
echo ""
echo "Stock queries (查股票):"
echo "  - '给我画一下可孚医疗2022年年中到今天的股价'"
echo "  - '北向资金今年的每日流入和累计流入'"
echo "  - '看一下近三年宁德时代和贵州茅台的pb变化'"
echo ""
echo "Economic queries (查经济):"
echo "  - '中国过去十年的cpi走势是什么'"
echo "  - '我想看看中国近十年gdp的走势'"
echo "  - '预测中国未来12个季度的GDP增速'"
echo ""
echo "Fund queries (查基金):"
echo "  - '易方达的张坤管理了几个基金'"
echo "  - '基金经理周海栋名下的所有基金今年的收益率情况'"
echo "  - '我想看看周海栋管理的华商优势行业的近三年来的的净值曲线'"
echo ""
echo "Company queries (查公司):"
echo "  - '介绍下贵州茅台,这公司是干什么的,主营业务是什么'"
echo "  - '我想比较下工商银行和贵州茅台近十年的净资产回报率'"
echo ""

echo "Step 5: Using the API"
echo "---------------------"
echo "The Gradio app exposes internal API endpoints:"
echo "  - Root: ${BASE_URL}/"
echo "  - Queue join: ${BASE_URL}/queue/join"
echo "  - Config: ${BASE_URL}/config"
echo ""
echo "Note: Data-Copilot requires an OpenAI API key or Azure OpenAI key"
echo "to be set in the app interface before queries will work."
echo ""

echo "Step 6: Stopping the Service"
echo "-----------------------------"
echo "To stop Data-Copilot:"
echo "  docker stop zwq2018--Data-Copilot"
echo ""
echo "To remove the container:"
echo "  docker rm zwq2018--Data-Copilot"
echo ""
echo "=========================================="
echo "Tutorial Complete"
echo "=========================================="
