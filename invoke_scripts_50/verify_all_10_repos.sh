#!/bin/bash
# Comprehensive verification script for all 10 repositories
# Tests HTTP endpoints and reports status

echo "============================================"
echo "HTTP Verification Report for 10 Repositories"
echo "Generated: $(date)"
echo "============================================"
echo ""

# Define repositories and their ports
declare -A REPOS=(
    ["mrwadams--attackgen"]=11110
    ["gptme--gptme"]=11130
    ["NEKOparapa--AiNiee"]=11460
    ["langchain-ai--local-deep-researcher"]=11030
    ["AuvaLab--itext2kg"]=11380
    ["bowang-lab--MedRAX"]=11180
    ["modelscope--FunClip"]=11430
    ["AntonOsika--gpt-engineer"]=11330
    ["joshpxyne--gpt-migrate"]=11470
    ["jianchang512--pyvideotrans"]=11160
)

# Define expected types
declare -A TYPES=(
    ["mrwadams--attackgen"]="Streamlit"
    ["gptme--gptme"]="API Server"
    ["NEKOparapa--AiNiee"]="Qt GUI (HTTP API)"
    ["langchain-ai--local-deep-researcher"]="LangGraph"
    ["AuvaLab--itext2kg"]="FastAPI"
    ["bowang-lab--MedRAX"]="Gradio"
    ["modelscope--FunClip"]="Web App"
    ["AntonOsika--gpt-engineer"]="CLI Tool"
    ["joshpxyne--gpt-migrate"]="CLI Tool"
    ["jianchang512--pyvideotrans"]="Qt GUI"
)

# Results arrays
declare -a RESULTS=()
SUCCESS_COUNT=0
FAIL_COUNT=0
PARTIAL_COUNT=0

# Function to test HTTP endpoint
test_endpoint() {
    local repo=$1
    local port=$2
    local type=$3

    local status_code="000"
    local endpoint_tested="/"

    # Try root endpoint first
    status_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/ 2>/dev/null)
    endpoint_tested="/"

    # If root fails, try health endpoint
    if [ "$status_code" = "000" ] || [ "$status_code" = "404" ]; then
        local health_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/health 2>/dev/null)
        if [ "$health_code" = "200" ]; then
            status_code="200"
            endpoint_tested="/health"
        fi
    fi

    # Try /api/status for AiNiee
    if [ "$repo" = "NEKOparapa--AiNiee" ] && ([ "$status_code" = "000" ] || [ "$status_code" = "404" ]); then
        local api_status_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/api/status 2>/dev/null)
        if [ "$api_status_code" = "200" ]; then
            status_code="200"
            endpoint_tested="/api/status"
        fi
    fi

    # Try /docs for FastAPI apps
    if [ "$status_code" = "000" ] || [ "$status_code" = "404" ]; then
        local docs_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/docs 2>/dev/null)
        if [ "$docs_code" = "200" ]; then
            status_code="200"
            endpoint_tested="/docs"
        fi
    fi

    # Determine status
    local status=""
    if [ "$status_code" = "200" ]; then
        if [ "$type" = "CLI Tool" ]; then
            status="⚠️ RUNNING (CLI tool, not web service)"
            PARTIAL_COUNT=$((PARTIAL_COUNT + 1))
        elif [ "$type" = "Qt GUI" ]; then
            status="⚠️ RUNNING (GUI app, no HTTP)"
            PARTIAL_COUNT=$((PARTIAL_COUNT + 1))
        elif [ "$type" = "Qt GUI (HTTP API)" ]; then
            status="✅ PASS (HTTP API enabled)"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            status="✅ PASS"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        fi
    elif [ "$status_code" = "404" ]; then
        status="⚠️ RUNNING (404 on $endpoint_tested)"
        PARTIAL_COUNT=$((PARTIAL_COUNT + 1))
    else
        status="❌ FAIL ($status_code)"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    RESULTS+=("$repo | $port | $type | $status_code ($endpoint_tested) | $status")
}

echo "Testing all repositories..."
echo ""

# Test each repository
for repo in "${!REPOS[@]}"; do
    port=${REPOS[$repo]}
    type=${TYPES[$repo]}
    test_endpoint "$repo" "$port" "$type"
done

# Print results table
echo ""
echo "============================================"
echo "RESULTS SUMMARY"
echo "============================================"
echo ""
printf "%-40s | %-6s | %-20s | %-15s | %-30s\n" "REPOSITORY" "PORT" "TYPE" "STATUS" "RESULT"
echo "---------------------------------------------|--------|----------------------|-----------------|-------------------------------"

for result in "${RESULTS[@]}"; do
    IFS='|' read -ra PARTS <<< "$result"
    printf "%-40s | %-6s | %-20s | %-15s | %-30s\n" "${PARTS[0]}" "${PARTS[1]}" "${PARTS[2]}" "${PARTS[3]}" "${PARTS[4]}"
done

echo ""
echo "============================================"
echo "SUMMARY: $SUCCESS_COUNT passed, $PARTIAL_COUNT partial, $FAIL_COUNT failed out of 10"
echo "============================================"

# Export results for further processing
echo ""
echo "Detailed status:"
echo "- ✅ PASS: HTTP endpoint returns 200 OK (web service)"
echo "- ⚠️ RUNNING: Container running but CLI/GUI app or 404"
echo "- ❌ FAIL: HTTP endpoint not responding or returning error"
echo ""
echo "Note: CLI tools and GUI apps are not designed for HTTP verification."
