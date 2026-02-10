#!/bin/bash

# Verification and fix script for 10 repos
# Logs to: /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/verification_report.log

LOG_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/verification_report.log"
REPO_BASE_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs"
PORT_MAPPING_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/port_mapping_50_gap10_2.json"

# Initialize log
echo "========================================" > "$LOG_FILE"
echo "Verification Report - $(date)" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Clear previous report
> "$LOG_FILE"

# Repos and ports from port_mapping_50_gap10_2.json
declare -A REPO_PORT_MAP
REPO_PORT_MAP["shroominic--codeinterpreter-api"]=11300
REPO_PORT_MAP["SWE-agent--SWE-agent"]=11400
REPO_PORT_MAP["mrwadams--stride-gpt"]=11040
REPO_PORT_MAP["Integuru-AI--Integuru"]=11070
REPO_PORT_MAP["vintasoftware--django-ai-assistant"]=11140
REPO_PORT_MAP["Sharrnah--whispering"]=11010
REPO_PORT_MAP["barun-saha--slide-deck-ai"]=11410
REPO_PORT_MAP["666ghj--BettaFish"]=11370
REPO_PORT_MAP["assafelovic--gpt-researcher"]=11250
REPO_PORT_MAP["shibing624--pycorrector"]=11000

# Container names (based on repo name with -- converted to --)
get_container_name() {
    local repo_name="$1"
    echo "$repo_name"
}

get_repo_dir() {
    local repo_name="$1"
    echo "$REPO_BASE_DIR/$repo_name"
}

# Wait for service to be healthy (HTTP check)
wait_for_service() {
    local repo_name="$1"
    local port="$2"
    local max_wait="$3"
    local wait_count=0
    local interval=2
    
    while [ $wait_count -lt $max_wait ]; do
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port" 2>/dev/null | grep -q "200\|301\|302"; then
            return 0
        fi
        sleep $interval
        wait_count=$((wait_count + interval))
    done
    return 1
}

# Check if container is running
check_container_running() {
    local container_name="$1"
    docker ps --filter "name=$container_name" --format "{{.ID}},{{.Status}},{{.Names}}" 2>/dev/null | grep "$container_name"
}

# Start container with docker-compose
start_container() {
    local repo_name="$1"
    local repo_dir=$(get_repo_dir "$repo_name")
    
    if [ -f "$repo_dir/docker-compose.yml" ]; then
        echo "  Starting container with docker-compose up -d..."
        docker-compose -f "$repo_dir/docker-compose.yml" up -d 2>&1
        return $?
    elif [ -f "$repo_dir/Dockerfile" ]; then
        echo "  Building and starting with docker-compose..."
        # Create minimal docker-compose if not exists
        if [ ! -f "$repo_dir/docker-compose.yml" ]; then
            cat > "$repo_dir/docker-compose.yml" << EOF
version: '3'
services:
  $repo_name:
    build: .
    ports:
      - "11000:11000"
EOF
        fi
        docker-compose -f "$repo_dir/docker-compose.yml" up -d 2>&1
        return $?
    else
        echo "  No docker-compose.yml or Dockerfile found!"
        return 1
    fi
}

# Get container port from docker-compose
get_container_port() {
    local repo_name="$1"
    local repo_dir=$(get_repo_dir "$repo_name")
    local host_port="$2"
    
    if [ -f "$repo_dir/docker-compose.yml" ]; then
        # Extract port mapping from docker-compose
        local port_map=$(grep -A5 "ports:" "$repo_dir/docker-compose.yml" 2>/dev/null | head -20)
        echo "$port_map"
    fi
}

# Main verification loop
echo "Starting verification of all 10 repos..."
echo ""

# Status tracking
declare -A REPO_STATUS

for repo_name in "${!REPO_PORT_MAP[@]}"; do
    port=${REPO_PORT_MAP[$repo_name]}
    container_name=$(get_container_name "$repo_name")
    repo_dir=$(get_repo_dir "$repo_name")
    
    echo "=== Checking $repo_name (port $port) ===" | tee -a "$LOG_FILE"
    echo "Repo directory: $repo_dir" | tee -a "$LOG_FILE"
    
    # Check if container is running
    container_info=$(check_container_running "$container_name")
    
    if [ -n "$container_info" ]; then
        echo "  Container found: $container_info" | tee -a "$LOG_FILE"
        
        # Check if healthy
        if echo "$container_info" | grep -q "(healthy)"; then
            echo "  STATUS: HEALTHY - Container is running and healthy" | tee -a "$LOG_FILE"
            REPO_STATUS[$repo_name]="healthy"
        else
            echo "  Container is running but may not be healthy. Waiting for service..." | tee -a "$LOG_FILE"
            
            # Wait for service to respond
            if wait_for_service "$repo_name" "$port" 30; then
                echo "  Service is responding! Marking as healthy." | tee -a "$LOG_FILE"
                REPO_STATUS[$repo_name]="healthy"
            else
                echo "  Service not responding. Checking logs..." | tee -a "$LOG_FILE"
                
                # Check logs
                container_id=$(echo "$container_info" | cut -d',' -f1)
                echo "  Container logs (last 20 lines):" | tee -a "$LOG_FILE"
                docker logs --tail 20 "$container_id" 2>&1 | tee -a "$LOG_FILE" || true
                
                REPO_STATUS[$repo_name]="unhealthy"
            fi
        fi
    else
        echo "  Container not running. Attempting to start..." | tee -a "$LOG_FILE"
        
        # Try to start container
        start_container "$repo_name"
        start_result=$?
        
        if [ $start_result -eq 0 ]; then
            echo "  Container started successfully. Waiting for service..." | tee -a "$LOG_FILE"
            
            # Wait for service to become healthy
            if wait_for_service "$repo_name" "$port" 30; then
                echo "  Service is responding! Marking as healthy." | tee -a "$LOG_FILE"
                REPO_STATUS[$repo_name]="healthy"
            else
                echo "  Service still not responding. Checking logs..." | tee -a "$LOG_FILE"
                REPO_STATUS[$repo_name]="retrying"
            fi
        else
            echo "  Failed to start container. Check logs." | tee -a "$LOG_FILE"
            REPO_STATUS[$repo_name]="unhealthy"
        fi
    fi
    
    echo "" | tee -a "$LOG_FILE"
done

# Retry failed services
echo "========================================" | tee -a "$LOG_FILE"
echo "Retry Phase" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

for repo_name in "${!REPO_STATUS[@]}"; do
    if [ "${REPO_STATUS[$repo_name]}" == "retrying" ]; then
        port=${REPO_PORT_MAP[$repo_name]}
        container_name=$(get_container_name "$repo_name")
        repo_dir=$(get_repo_dir "$repo_name")
        
        echo "" | tee -a "$LOG_FILE"
        echo "=== Retry: $repo_name ===" | tee -a "$LOG_FILE"
        
        # Start again
        start_container "$repo_name"
        
        # Wait and check
        if wait_for_service "$repo_name" "$port" 30; then
            echo "  SUCCESS: Service is now healthy!" | tee -a "$LOG_FILE"
            REPO_STATUS[$repo_name]="fixed"
        else
            echo "  FAILED: Service still not responding" | tee -a "$LOG_FILE"
            
            # Get logs
            container_id=$(docker ps --filter "name=$container_name" --format "{{.ID}}" 2>/dev/null | head -1)
            if [ -n "$container_id" ]; then
                echo "  Container logs:" | tee -a "$LOG_FILE"
                docker logs --tail 30 "$container_id" 2>&1 | tee -a "$LOG_FILE" || true
            fi
            REPO_STATUS[$repo_name]="unhealthy"
        fi
    fi
done

# Final Report
echo "" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "FINAL STATUS REPORT" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

for repo_name in "${!REPO_PORT_MAP[@]}"; do
    status=${REPO_STATUS[$repo_name]:-"not_found"}
    port=${REPO_PORT_MAP[$repo_name]}
    printf "%-40s Port: %s Status: %s\n" "$repo_name ($port)" "$port" "$status" | tee -a "$LOG_FILE"
done

echo "" | tee -a "$LOG_FILE"
echo "Report completed at: $(date)" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

# Output final summary to stdout
echo ""
echo "=== Final Summary ==="
for repo_name in "${!REPO_PORT_MAP[@]}"; do
    status=${REPO_STATUS[$repo_name]:-"not_found"}
    port=${REPO_PORT_MAP[$repo_name]}
    printf "%-40s Port: %s Status: %s\n" "$repo_name ($port)" "$port" "$status"
done
