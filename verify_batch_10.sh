#!/bin/bash

# Batch verification script for 10 repos from port_mapping_50_gap10_3.json
# Output directory for results
RESULTS_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/verification_results_10"
mkdir -p "$RESULTS_DIR"

# Configuration
export OPENAI_API_KEY="11"
export OPENAI_API_BASE_URL="http://157.10.162.82:443/v1/"
export GPT_MODEL="gpt-5.1"

# Repo definitions: name:port
declare -A REPOS=(
    ["yuka-friends--Windrecorder"]=11480
    ["microsoft--magentic-ui"]=11240
    ["InternLM--HuixiangDou"]=11390
    ["fynnfluegge--codeqai"]=11060
    ["snap-stanford--Biomni"]=11260
    ["zwq2018--Data-Copilot"]=11440
    ["bhaskatripathi--pdfGPT"]=11340
    ["finaldie--auto-news"]=11190
    ["zyddnys--manga-image-translator"]=11080
    ["IBM--zshot"]=11200
)

# Initialize report
REPORT_FILE="$RESULTS_DIR/verification_report.md"
echo "# Batch Verification Report - 10 Repos" > "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Start JSON report
echo '{' > "$RESULTS_DIR/verification_results.json"
echo '  "timestamp": "'$(date -Iseconds)'",' >> "$RESULTS_DIR/verification_results.json"
echo '  "repos": [' >> "$RESULTS_DIR/verification_results.json"

FIRST_REPO=true

for repo_name in "${!REPOS[@]}"; do
    port=${REPOS[$repo_name]}
    echo "=========================================="
    echo "Verifying: $repo_name (port $port)"
    echo "=========================================="
    
    # Initialize per-repo results
    REPO_RESULTS="$RESULTS_DIR/${repo_name//\//_}_results.json"
    CONTAINER_STATUS="not_found"
    HTTP_STATUS="N/A"
    HTTP_DETAILS=""
    HTTP_ERROR=""
    CONTAINER_LOGS=""
    ENTRY_POINT_EXISTS="false"
    DOCKERFILE_EXISTS="false"
    TUTORIAL_EXISTS="false"
    TUTORIAL_RESULT=""
    UNIT_TEST_EXISTS="false"
    UNIT_TEST_RESULT=""
    
    # 1. Check if container is running
    echo "Step 1: Checking container status..."
    CONTAINER_INFO=$(docker ps -a --filter "name=$repo_name" --format "{{.Names}}|{{.Status}}|{{.Ports}}" 2>/dev/null)
    if [ -n "$CONTAINER_INFO" ]; then
        CONTAINER_STATUS=$(echo "$CONTAINER_INFO" | cut -d'|' -f2 | tr -d ' ')
        if echo "$CONTAINER_STATUS" | grep -q "Up"; then
            CONTAINER_STATUS="running"
        else
            CONTAINER_STATUS="exited"
        fi
        echo "  Container status: $CONTAINER_STATUS"
    else
        CONTAINER_STATUS="not_found"
        echo "  Container not found"
    fi
    
    # 2. Test HTTP endpoint
    echo "Step 2: Testing HTTP endpoint..."
    HTTP_RESPONSE=$(curl -s -o /tmp/http_body.txt -w "%{http_code}" --connect-timeout 5 --max-time 10 "http://localhost:$port" 2>/dev/null)
    HTTP_STATUS=$HTTP_RESPONSE
    if [ -f /tmp/http_body.txt ]; then
        HTTP_DETAILS=$(head -c 200 /tmp/http_body.txt)
    fi
    echo "  HTTP Response Code: $HTTP_STATUS"
    
    # 3. Check container logs for errors
    echo "Step 3: Checking container logs..."
    if [ "$CONTAINER_STATUS" = "running" ]; then
        CONTAINER_LOGS=$(docker logs "$repo_name" --tail 50 2>/dev/null)
        if echo "$CONTAINER_LOGS" | grep -iq "error\|fail\|exception"; then
            echo "  Found errors in logs"
            HTTP_ERROR="errors_found_in_logs"
        else
            echo "  No obvious errors in logs"
        fi
    fi
    
    # 4. Verify entry_point.sh and Dockerfile exist
    echo "Step 4: Checking entry_point.sh and Dockerfile..."
    repo_dir="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50/$repo_name"
    if [ -d "$repo_dir" ]; then
        if [ -f "$repo_dir/entry_point.sh" ]; then
            ENTRY_POINT_EXISTS="true"
            echo "  entry_point.sh: found"
        else
            echo "  entry_point.sh: not found"
        fi
        if [ -f "$repo_dir/Dockerfile" ]; then
            DOCKERFILE_EXISTS="true"
            echo "  Dockerfile: found"
        else
            echo "  Dockerfile: not found"
        fi
    else
        echo "  Repo directory not found: $repo_dir"
    fi
    
    # 5. Run tutorial script if exists
    echo "Step 5: Checking for tutorial script..."
    tutorial_script="$repo_dir/tutorial_$repo_name_poc.sh"
    if [ -f "$tutorial_script" ]; then
        TUTORIAL_EXISTS="true"
        echo "  Tutorial found: $tutorial_script"
        # Run tutorial (with timeout)
        timeout 60 bash "$tutorial_script" > "$RESULTS_DIR/${repo_name//\//_}_tutorial.log" 2>&1
        TUTORIAL_EXIT=$?
        if [ $TUTORIAL_EXIT -eq 0 ]; then
            TUTORIAL_RESULT="success"
        elif [ $TUTORIAL_EXIT -eq 124 ]; then
            TUTORIAL_RESULT="timeout"
        else
            TUTORIAL_RESULT="failed_exit_code_$TUTORIAL_EXIT"
        fi
        echo "  Tutorial result: $TUTORIAL_RESULT"
    else
        # Check alternative paths for tutorial
        alt_paths=(
            "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/$repo_name"
            "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/task_dirs"
        )
        for alt in "${alt_paths[@]}"; do
            if [ -d "$alt" ]; then
                if ls "$alt"/*tutorial* 1> /dev/null 2>&1; then
                    echo "  Tutorial found at alternative location: $alt"
                    TUTORIAL_EXISTS="true"
                    break
                fi
            fi
        done
    fi
    
    # 6. Check for unit tests
    echo "Step 6: Checking for unit tests..."
    if [ -d "$repo_dir" ]; then
        if find "$repo_dir" -name "*test*" -type f 2>/dev/null | grep -q .; then
            UNIT_TEST_EXISTS="true"
            echo "  Unit tests found"
            # Try running tests (with timeout)
            if [ -f "$repo_dir/requirements.txt" ]; then
                pip install -r "$repo_dir/requirements.txt" > /dev/null 2>&1
            fi
            timeout 120 bash -c "cd '$repo_dir' && python -m pytest 2>&1 || true" > "$RESULTS_DIR/${repo_name//\//_}_tests.log" 2>&1
            UNIT_TEST_RESULT="tests_run"
        else
            echo "  No unit tests found"
        fi
    fi
    
    # Write individual repo JSON
    cat > "$REPO_RESULTS" << JSONEOF
{
  "repo_name": "$repo_name",
  "port": $port,
  "container_status": "$CONTAINER_STATUS",
  "http_status": "$HTTP_STATUS",
  "http_details": "$HTTP_DETAILS",
  "http_error": "$HTTP_ERROR",
  "entry_point_exists": $ENTRY_POINT_EXISTS,
  "dockerfile_exists": $DOCKERFILE_EXISTS,
  "tutorial_exists": $TUTORIAL_EXISTS,
  "tutorial_result": "$TUTORIAL_RESULT",
  "unit_test_exists": $UNIT_TEST_EXISTS,
  "unit_test_result": "$UNIT_TEST_RESULT"
}
JSONEOF
    
    # Add to main JSON array
    if [ "$FIRST_REPO" = "true" ]; then
        FIRST_REPO=false
    else
        echo ',' >> "$RESULTS_DIR/verification_results.json"
    fi
    
    cat >> "$RESULTS_DIR/verification_results.json" << JSONEOF
    {
      "repo_name": "$repo_name",
      "port": $port,
      "container_status": "$CONTAINER_STATUS",
      "http_status": "$HTTP_STATUS",
      "http_details": "$HTTP_DETAILS",
      "http_error": "$HTTP_ERROR",
      "entry_point_exists": $ENTRY_POINT_EXISTS,
      "dockerfile_exists": $DOCKERFILE_EXISTS,
      "tutorial_exists": $TUTORIAL_EXISTS,
      "tutorial_result": "$TUTORIAL_RESULT",
      "unit_test_exists": $UNIT_TEST_EXISTS,
      "unit_test_result": "$UNIT_TEST_RESULT"
    }
JSONEOF
    
    # Write to markdown report
    echo "## $repo_name" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "- **Container Status**: $CONTAINER_STATUS" >> "$REPORT_FILE"
    echo "- **HTTP Response**: $HTTP_STATUS" >> "$REPORT_FILE"
    echo "- **HTTP Details**: $HTTP_DETAILS" >> "$REPORT_FILE"
    echo "- **HTTP Error**: $HTTP_ERROR" >> "$REPORT_FILE"
    echo "- **entry_point.sh**: $ENTRY_POINT_EXISTS" >> "$REPORT_FILE"
    echo "- **Dockerfile**: $DOCKERFILE_EXISTS" >> "$REPORT_FILE"
    echo "- **Tutorial**: $TUTORIAL_EXISTS ($TUTORIAL_RESULT)" >> "$REPORT_FILE"
    echo "- **Unit Tests**: $UNIT_TEST_EXISTS ($UNIT_TEST_RESULT)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    echo ""
done

# Close JSON array and file
echo '  ]' >> "$RESULTS_DIR/verification_results.json"
echo '}' >> "$RESULTS_DIR/verification_results.json"

echo "=========================================="
echo "Verification Complete!"
echo "=========================================="
echo "Report saved to: $REPORT_FILE"
echo "JSON results saved to: $RESULTS_DIR/verification_results.json"
