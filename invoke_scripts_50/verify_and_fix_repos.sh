#!/bin/bash

# Configuration
PORT_MAPPING_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/port_mapping_50_gap10_2.json"
REPO_BASE_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs"
LOG_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/verification_report.log"
MAX_RETRIES=3
HEALTH_CHECK_TIMEOUT=30

# Repository list from port_mapping_50_gap10_2.json
declare -A REPOS=(
    ["shroominic--codeinterpreter-api"]=11300
    ["SWE-agent--SWE-agent"]=11400
    ["mrwadams--stride-gpt"]=11040
    ["Integuru-AI--Integuru"]=11070
    ["vintasoftware--django-ai-assistant"]=11140
    ["Sharrnah--whispering"]=11010
    ["barun-saha--slide-deck-ai"]=11410
    ["666ghj--BettaFish"]=11370
    ["assafelovic--gpt-researcher"]=11250
    ["shibing624--pycorrector"]=11000
)

# Initialize log
echo "========================================" > "$LOG_FILE"
echo "Verification Report: $(date)" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Array to store final results
declare -A FINAL_STATUS

# Function to log messages
log_msg() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
}

# Function to check if container is running
check_container_running() {
    local repo_name="$1"
    local container_info
    
    container_info=$(docker ps --filter "name=$repo_name" --format "{{.ID}}|{{.Status}}|{{.Names}}")
    
    if [ -n "$container_info" ]; then
        echo "$container_info"
        return 0
    else
        return 1
    fi
}

# Function to check HTTP endpoint for health
check_health_endpoint() {
    local repo_name="$1"
    local port="$2"
    local max_attempts=$((HEALTH_CHECK_TIMEOUT / 2))
    local attempt=0
    local health_status="unhealthy"
    
    while [ $attempt -lt $max_attempts ]; do
        sleep 2
        attempt=$((attempt + 1))
        
        # Try to curl the health endpoint or root endpoint
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port" 2>/dev/null | grep -q "200\|301\|302"; then
            health_status="healthy"
            break
        fi
        
        # Check if container is still running
        if ! docker ps --filter "name=$repo_name" > /dev/null 2>&1; then
            health_status="container_stopped"
            break
        fi
    done
    
    echo "$health_status"
}

# Function to start docker-compose
start_docker_compose() {
    local repo_dir="$1"
    local repo_name="$2"
    
    log_msg "Starting docker-compose for $repo_name in $repo_dir"
    
    if [ -f "$repo_dir/docker-compose.yml" ]; then
        cd "$repo_dir" && docker-compose up -d
        return $?
    else
        log_msg "ERROR: No docker-compose.yml found in $repo_dir"
        return 1
    fi
}

# Function to get container logs
get_container_logs() {
    local repo_name="$1"
    docker logs "$repo_name" --tail 50 2>/dev/null
}

# Function to fix issues and restart
fix_and_restart() {
    local repo_name="$1"
    local repo_dir="$2"
    local port="$3"
    local retry_count=0
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        retry_count=$((retry_count + 1))
        log_msg "Retry attempt $retry_count for $repo_name"
        
        # Try to start docker-compose
        if start_docker_compose "$repo_dir" "$repo_name"; then
            sleep 5
            
            # Check if container is running
            local container_info
            container_info=$(check_container_running "$repo_name")
            
            if [ -n "$container_info" ]; then
                log_msg "Container $repo_name started successfully"
                
                # Wait for health check
                local health_status
                health_status=$(check_health_endpoint "$repo_name" "$port")
                log_msg "Health check result for $repo_name: $health_status"
                
                if [ "$health_status" == "healthy" ]; then
                    FINAL_STATUS["$repo_name"]="healthy"
                    return 0
                elif [ "$health_status" == "container_stopped" ]; then
                    log_msg "Container stopped unexpectedly for $repo_name"
                    FINAL_STATUS["$repo_name"]="unhealthy"
                    return 1
                fi
            else
                log_msg "Container failed to start for $repo_name"
                get_container_logs "$repo_name" >> "$LOG_FILE"
            fi
        fi
        
        if [ $retry_count -lt $MAX_RETRIES ]; then
            log_msg "Retrying $repo_name after failure..."
            # Stop any leftover containers
            docker-compose -f "$repo_dir/docker-compose.yml" down 2>/dev/null
            sleep 5
        fi
    done
    
    FINAL_STATUS["$repo_name"]="unhealthy"
    return 1
}

# Main verification loop
log_msg "Starting verification of all 10 repositories..."
log_msg ""

for repo_name in "${!REPOS[@]}"; do
    port="${REPOS[$repo_name]}"
    repo_dir="$REPO_BASE_DIR/$repo_name"
    
    log_msg "========================================"
    log_msg "Checking $repo_name (port $port)"
    log_msg "Repo directory: $repo_dir"
    log_msg "========================================"
    
    # Check if repo directory exists
    if [ ! -d "$repo_dir" ]; then
        log_msg "ERROR: Repository directory not found: $repo_dir"
        FINAL_STATUS["$repo_name"]="unhealthy"
        continue
    fi
    
    # Check if container is running
    container_info=$(check_container_running "$repo_name")
    
    if [ -n "$container_info" ]; then
        log_msg "Container is running"
        log_msg "Container info: $container_info"
        
        # Extract status from container info
        container_status=$(echo "$container_info" | cut -d'|' -f2)
        
        if [[ "$container_status" == *"healthy"* ]]; then
            log_msg "Container status: HEALTHY"
            FINAL_STATUS["$repo_name"]="healthy"
        else
            log_msg "Container status: Running but not healthy, checking endpoint..."
            
            # Check HTTP endpoint
            health_status=$(check_health_endpoint "$repo_name" "$port")
            log_msg "Health check result: $health_status"
            
            if [ "$health_status" == "healthy" ]; then
                FINAL_STATUS["$repo_name"]="healthy"
            else
                log_msg "Container is running but not responding, attempting restart..."
                FINAL_STATUS["$repo_name"]="retrying"
                fix_and_restart "$repo_name" "$repo_dir" "$port"
            fi
        fi
    else
        log_msg "Container not running, attempting to start..."
        
        # Check if docker-compose exists
        if [ ! -f "$repo_dir/docker-compose.yml" ]; then
            log_msg "ERROR: docker-compose.yml not found in $repo_dir"
            FINAL_STATUS["$repo_name"]="unhealthy"
            continue
        fi
        
        FINAL_STATUS["$repo_name"]="retrying"
        fix_and_restart "$repo_name" "$repo_dir" "$port"
    fi
    
    log_msg ""
done

# Final summary
log_msg "========================================"
log_msg "FINAL SUMMARY"
log_msg "========================================"

for repo_name in "${!FINAL_STATUS[@]}"; do
    status="${FINAL_STATUS[$repo_name]}"
    log_msg "$repo_name: $status"
done

log_msg ""
log_msg "Report completed at: $(date)"
log_msg "Log file: $LOG_FILE"
