#!/bin/bash
# Run POC tests for all 7 working repositories

echo "============================================"
echo "POC Tests for 7 Working Repositories"
echo "Generated: $(date)"
echo "============================================"
echo ""

# Define test function
test_repo() {
    local repo=$1
    local port=$2
    local expected_type=$3
    
    echo "----------------------------------------"
    echo "Testing: $repo on port $port"
    echo "----------------------------------------"
    
    # Test root endpoint
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/ 2>/dev/null)
    echo "  Root endpoint (/): $status_code"
    
    # Test health endpoint (if available)
    local health_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/health 2>/dev/null)
    if [ "$health_code" != "000" ]; then
        echo "  Health endpoint (/health): $health_code"
    fi
    
    # Test API/status endpoints for specific repos
    if [ "$repo" = "NEKOparapa--AiNiee" ]; then
        local api_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/api/status 2>/dev/null)
        echo "  API status (/api/status): $api_status"
        local api_response=$(curl -s http://localhost:$port/api/status 2>/dev/null)
        echo "  API Response: $api_response"
    fi
    
    if [ "$repo" = "AuvaLab--itext2kg" ]; then
        local docs_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/docs 2>/dev/null)
        echo "  Docs endpoint (/docs): $docs_code"
        local health_response=$(curl -s http://localhost:$port/health 2>/dev/null)
        echo "  Health Response: $health_response"
    fi
    
    # Get response sample for verification
    local response_sample=$(curl -s http://localhost:$port/ 2>/dev/null | head -c 200)
    if [ -n "$response_sample" ]; then
        echo "  Response Sample: ${response_sample:0:100}..."
    fi
    
    # Determine result
    if [ "$status_code" = "200" ]; then
        echo "  Result: ✅ PASS"
        return 0
    else
        echo "  Result: ❌ FAIL"
        return 1
    fi
    echo ""
}

# Run tests for all 7 working repos
test_repo "mrwadams--attackgen" 11110 "Streamlit"
echo ""
test_repo "gptme--gptme" 11130 "API Server"
echo ""
test_repo "langchain-ai--local-deep-researcher" 11030 "LangGraph"
echo ""
test_repo "AuvaLab--itext2kg" 11380 "FastAPI"
echo ""
test_repo "bowang-lab--MedRAX" 11180 "Gradio"
echo ""
test_repo "modelscope--FunClip" 11430 "Web App"
echo ""
test_repo "NEKOparapa--AiNiee" 11460 "Qt GUI + API"
echo ""

echo "============================================"
echo "All POC Tests Completed"
echo "============================================"
