#!/bin/bash

# Batch verification script for all 10 repos from port_mapping_50_gap10_3.json
# Output file
OUTPUT_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/verification_report_$(date +%Y%m%d_%H%M%S).md"

echo "# Batch Verification Report - $(date)" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Repos verified: 10" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Repositories to verify
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

# Counters
TOTAL=0
RUNNING=0
STOPPED=0
HTTP_OK=0
HTTP_FAIL=0
TESTS_PASSED=0
TESTS_FAILED=0

for repo in "${!REPOS[@]}"; do
    PORT=${REPOS[$repo]}
    TOTAL=$((TOTAL + 1))
    
    echo "## Verification: $repo (Port $PORT)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Timestamp: $(date)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Get container name based on repo name patterns
    CONTAINER_NAME=""
    CONTAINER_NAME=$(docker ps -a --format "{{.Names}}" | grep -i "$repo" | head -1)
    
    if [ -z "$CONTAINER_NAME" ]; then
        # Try with different patterns
        CONTAINER_NAME=$(docker ps -a --format "{{.Names}}" | grep -i "$(echo $repo | sed 's/--/-/g')" | head -1)
    fi
    
    if [ -z "$CONTAINER_NAME" ]; then
        # Try with underscores
        CONTAINER_NAME=$(docker ps -a --format "{{.Names}}" | grep -i "$(echo $repo | sed 's/--/_/g')" | head -1)
    fi
    
    echo "### 1. Container Status" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    if [ -n "$CONTAINER_NAME" ]; then
        echo "Container name found: \`$CONTAINER_NAME\`" >> "$OUTPUT_FILE"
        
        # Check if running
        STATE=$(docker inspect --format='{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null)
        STATUS=$(docker ps -a --format "{{.Status}}" --filter "name=$CONTAINER_NAME" 2>/dev/null)
        
        echo "Container status: \`$STATUS\`" >> "$OUTPUT_FILE"
        
        if [ "$STATE" == "true" ]; then
            echo "Container state: Running" >> "$OUTPUT_FILE"
            RUNNING=$((RUNNING + 1))
        else
            echo "Container state: Not running" >> "$OUTPUT_FILE"
            STOPPED=$((STOPPED + 1))
        fi
    else
        echo "Container name: NOT FOUND" >> "$OUTPUT_FILE"
        STOPPED=$((STOPPED + 1))
    fi
    echo "" >> "$OUTPUT_FILE"
    
    # HTTP test
    echo "### 2. HTTP Endpoint Test" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    HTTP_RESULT=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://localhost:$PORT/" 2>&1)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://localhost:$PORT/" 2>&1)
    RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" --connect-timeout 10 "http://localhost:$PORT/" 2>&1)
    
    if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "302" ] || [ "$HTTP_CODE" == "301" ]; then
        echo "HTTP Status Code: \`$HTTP_CODE\`" >> "$OUTPUT_FILE"
        echo "Response Time: ${RESPONSE_TIME}s" >> "$OUTPUT_FILE"
        echo "Result: HTTP OK" >> "$OUTPUT_FILE"
        HTTP_OK=$((HTTP_OK + 1))
    else
        echo "HTTP Status Code: \`$HTTP_CODE\`" >> "$OUTPUT_FILE"
        echo "Response Time: ${RESPONSE_TIME}s" >> "$OUTPUT_FILE"
        echo "Result: HTTP FAILED" >> "$OUTPUT_FILE"
        HTTP_FAIL=$((HTTP_FAIL + 1))
        
        # Try full response for debugging
        FULL_RESPONSE=$(curl -s --connect-timeout 10 "http://localhost:$PORT/" 2>&1 | head -50)
        echo "" >> "$OUTPUT_FILE"
        echo "Full Response (first 50 lines):" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "$FULL_RESPONSE" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    # Container logs if container exists
    echo "### 3. Container Logs Check" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    if [ -n "$CONTAINER_NAME" ]; then
        LOGS=$(docker logs "$CONTAINER_NAME" --tail 50 2>&1)
        echo "Last 50 lines of logs:" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "$LOGS" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        
        # Check for errors in logs
        if echo "$LOGS" | grep -qi "error\|exception\|failed"; then
            echo "" >> "$OUTPUT_FILE"
            echo "**Warning: Errors found in logs!**" >> "$OUTPUT_FILE"
        fi
    else
        echo "No container found for log check" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    # Check entry_point.sh and Dockerfile
    echo "### 4. File Existence Check (entry_point.sh, Dockerfile)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Find repo directory
    REPO_DIR=$(find /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin -type d -name "*$repo*" 2>/dev/null | head -1)
    
    if [ -n "$REPO_DIR" ]; then
        echo "Repo directory: \`$REPO_DIR\`" >> "$OUTPUT_FILE"
        
        # Check entry_point.sh
        if [ -f "$REPO_DIR/entry_point.sh" ]; then
            echo "- entry_point.sh: **FOUND**" >> "$OUTPUT_FILE"
        else
            echo "- entry_point.sh: NOT FOUND" >> "$OUTPUT_FILE"
        fi
        
        # Check Dockerfile
        if [ -f "$REPO_DIR/Dockerfile" ]; then
            echo "- Dockerfile: **FOUND**" >> "$OUTPUT_FILE"
        else
            echo "- Dockerfile: NOT FOUND" >> "$OUTPUT_FILE"
        fi
    else
        echo "Repo directory: NOT FOUND" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    # Check and run tutorial script
    echo "### 5. Tutorial Script Check" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Find tutorial script in invoke_scripts_50
    TUTORIAL_SCRIPT=$(find /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50 -name "*$repo*" -type f 2>/dev/null | head -1)
    
    if [ -n "$TUTORIAL_SCRIPT" ]; then
        echo "Tutorial script found: \`$TUTORIAL_SCRIPT\`" >> "$OUTPUT_FILE"
        
        # Try to run tutorial script if it's executable
        if [ -x "$TUTORIAL_SCRIPT" ]; then
            echo "Running tutorial script..." >> "$OUTPUT_FILE"
            
            # Export environment variables
            export OPENAI_API_KEY="11"
            export OPENAI_API_BASE_URL="http://157.10.162.82:443/v1/"
            export GPT_MODEL="gpt-5.1"
            
            TUTORIAL_OUTPUT=$(timeout 60 bash "$TUTORIAL_SCRIPT" 2>&1)
            TUTORIAL_EXIT=$?
            
            echo "Exit code: \`$TUTORIAL_EXIT\`" >> "$OUTPUT_FILE"
            echo "Output:" >> "$OUTPUT_FILE"
            echo '```' >> "$OUTPUT_FILE"
            echo "$TUTORIAL_OUTPUT" >> "$OUTPUT_FILE"
            echo '```' >> "$OUTPUT_FILE"
            
            if [ $TUTORIAL_EXIT -eq 0 ]; then
                echo "Tutorial script: **PASSED**" >> "$OUTPUT_FILE"
                TESTS_PASSED=$((TESTS_PASSED + 1))
            else
                echo "Tutorial script: **FAILED**" >> "$OUTPUT_FILE"
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi
        else
            echo "Tutorial script exists but not executable" >> "$OUTPUT_FILE"
        fi
    else
        echo "No tutorial script found for this repo" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    # Check for unit tests
    echo "### 6. Unit Tests Check" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    if [ -n "$REPO_DIR" ]; then
        # Check for common test files
        TEST_FILES=""
        if [ -d "$REPO_DIR/tests" ]; then
            TEST_FILES="$TEST_FILES tests/ directory"
        fi
        if [ -d "$REPO_DIR/test" ]; then
            TEST_FILES="$TEST_FILES test/ directory"
        fi
        if [ -f "$REPO_DIR/test_*.py" ] || [ -f "$REPO_DIR/*_test.py" ]; then
            TEST_FILES="$TEST_FILES Python test files"
        fi
        if [ -f "$REPO_DIR/Makefile" ] && grep -q "test" "$REPO_DIR/Makefile" 2>/dev/null; then
            TEST_FILES="$TEST_FILES Makefile with test target"
        fi
        
        if [ -n "$TEST_FILES" ]; then
            echo "Test files found: \`$TEST_FILES\`" >> "$OUTPUT_FILE"
            
            # Try running tests if pytest or similar is available
            if [ -f "$REPO_DIR/requirements.txt" ] || [ -f "$REPO_DIR/pyproject.toml" ]; then
                echo "Python test setup detected" >> "$OUTPUT_FILE"
            fi
        else
            echo "No unit tests found" >> "$OUTPUT_FILE"
        fi
    else
        echo "Repo directory not found, cannot check for tests" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

# Summary
echo "# Summary" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- **Total Repositories**: $TOTAL" >> "$OUTPUT_FILE"
echo "- **Running Containers**: $RUNNING" >> "$OUTPUT_FILE"
echo "- **Stopped Containers**: $STOPPED" >> "$OUTPUT_FILE"
echo "- **HTTP OK**: $HTTP_OK" >> "$OUTPUT_FILE"
echo "- **HTTP Failed**: $HTTP_FAIL" >> "$OUTPUT_FILE"
echo "- **Tests Passed**: $TESTS_PASSED" >> "$OUTPUT_FILE"
echo "- **Tests Failed**: $TESTS_FAILED" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Report generated at: $(date)" >> "$OUTPUT_FILE"

echo "Verification complete. Report saved to: $OUTPUT_FILE"
cat "$OUTPUT_FILE"
