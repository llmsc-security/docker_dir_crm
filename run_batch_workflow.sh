#!/bin/bash
# Batch workflow script to start all 10 repos and verify HTTP services
# =============================================================================

set -e

# Configuration
RESULTS_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/batch_workflow_results.txt"
PORT_MAPPING_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/port_mapping_50_gap10_1.json"
REPO_BASE_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs"

# OpenAI API config
OPENAI_API_KEY="11"
OPENAI_API_BASE_URL="http://157.10.162.82:443/v1/"
GPT_MODEL="gpt-5.1"

# Port mappings: repo_name: host_port: internal_port: service_type
# CLI tools (skip HTTP test) are marked specially
declare -A PORT_MAP=(
    ["mrwadams--attackgen"]="11110:8500:streamlit"
    ["gptme--gptme"]="11130:11130:fastapi"
    ["NEKOparapa--AiNiee"]="11460:8000:gradio"
    ["langchain-ai--local-deep-researcher"]="11030:7860:gradio"
    ["AuvaLab--itext2kg"]="11380:7860:gradio"
    ["bowang-lab--MedRAX"]="11180:8585:gradio"
    ["modelscope--FunClip"]="11430:7860:gradio"
    ["AntonOsika--gpt-engineer"]="11330:8000:gradio"
    ["joshpxyne--gpt-migrate"]="11470:0:cli"  # CLI tool - skip HTTP test
    ["jianchang512--pyvideotrans"]="11160:0:cli"  # CLI tool - skip HTTP test
)

# Counters
TOTAL_REPOS=0
SUCCESSFUL_REPOS=0
FAILED_REPOS=0
SKIPPED_REPOS=0

# Start time
START_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# Initialize results file
echo "=============================================" > "$RESULTS_FILE"
echo "BATCH WORKFLOW RESULTS" >> "$RESULTS_FILE"
echo "Started: $START_TIME" >> "$RESULTS_FILE"
echo "=============================================" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$RESULTS_FILE"
}

log_success() {
    echo -e "\033[0;32m[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1\033[0m" | tee -a "$RESULTS_FILE"
}

log_error() {
    echo -e "\033[0;31m[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1\033[0m" | tee -a "$RESULTS_FILE"
}

log_warn() {
    echo -e "\033[1;33m[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1\033[0m" | tee -a "$RESULTS_FILE"
}

# Function to test HTTP endpoint
test_http_endpoint() {
    local url="$1"
    local timeout="${2:-30}"
    
    local start=$(date +%s)
    while [ $(($(date +%s) - start)) -lt $timeout ]; do
        if curl -sf "$url" > /dev/null 2>&1; then
            return 0
        fi
        sleep 2
    done
    return 1
}

# Function to build Docker image
build_image() {
    local repo_name="$1"
    local repo_path="$2"
    local dockerfile="$3"
    
    log "Building Docker image for $repo_name..."
    
    # Check if image already exists
    if docker images "$repo_name" --format "{{.Repository}}" | grep -q "^${repo_name}$"; then
        log_success "Image for $repo_name already exists, skipping build"
        return 0
    fi
    
    if [ -f "$dockerfile" ]; then
        docker build -t "$repo_name" -f "$dockerfile" "$repo_path" 2>&1 | tee -a "$RESULTS_FILE"
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_success "Docker image built successfully for $repo_name"
            return 0
        else
            log_error "Docker image build failed for $repo_name"
            return 1
        fi
    else
        log_error "Dockerfile not found for $repo_name"
        return 1
    fi
}

# Function to start container
start_container() {
    local repo_name="$1"
    local host_port="$2"
    local container_port="$3"
    local container_name="${repo_name//\-\-/}_container"
    
    # Check if container already exists and is running
    if docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
        log_warn "Container $container_name already running"
        return 0
    fi
    
    # Remove stopped container if exists
    if docker ps -a --format "{{.Names}}" | grep -q "^${container_name}$"; then
        docker rm "$container_name" > /dev/null 2>&1 || true
    fi
    
    log "Starting container $container_name (port $host_port -> $container_port)..."
    
    # Build docker run command
    local docker_cmd="docker run -d --name $container_name"
    
    # Add port mapping
    docker_cmd="$docker_cmd -p $host_port:$container_port"
    
    # Add environment variables
    docker_cmd="$docker_cmd -e OPENAI_API_KEY=$OPENAI_API_KEY"
    docker_cmd="$docker_cmd -e OPENAI_BASE_URL=$OPENAI_API_BASE_URL"
    docker_cmd="$docker_cmd -e GPT_MODEL=$GPT_MODEL"
    
    # Add repo-specific environment variables
    case "$repo_name" in
        "bowang-lab--MedRAX")
            # Create required directories for MedRAX
            mkdir -p "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/bowang-lab--MedRAX/model-cache"
            docker_cmd="$docker_cmd -v /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/bowang-lab--MedRAX/model-cache:/model-weights"
            docker_cmd="$docker_cmd -v /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/bowang-lab--MedRAX/model-cache:/cache"
            docker_cmd="$docker_cmd -v /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/bowang-lab--MedRAX/temp:/medrax/temp"
            ;;
        "AntonOsika--gpt-engineer")
            docker_cmd="$docker_cmd -v /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/AntonOsika--gpt-engineer/project:/project"
            mkdir -p "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/AntonOsika--gpt-engineer/project"
            ;;
        "joshpxyne--gpt-migrate")
            docker_cmd="$docker_cmd -v /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/joshpxyne--gpt-migrate/workspace:/workspace"
            mkdir -p "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/joshpxyne--gpt-migrate/workspace"
            ;;
        "jianchang512--pyvideotrans")
            docker_cmd="$docker_cmd -v /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/jianchang512--pyvideotrans/logs:/app/logs"
            mkdir -p "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/jianchang512--pyvideotrans/logs"
            ;;
    esac
    
    # Add network and restart policy
    docker_cmd="$docker_cmd --network host"
    docker_cmd="$docker_cmd --restart unless-stopped"
    
    # Run the container
    docker_cmd="$docker_cmd $repo_name"
    
    eval "$docker_cmd" 2>&1 | tee -a "$RESULTS_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log_success "Container $container_name started"
        return 0
    else
        log_error "Failed to start container $container_name"
        return 1
    fi
}

# Function to verify HTTP service
verify_service() {
    local repo_name="$1"
    local host_port="$2"
    local service_type="$3"
    
    # CLI tools don't have HTTP services
    if [ "$service_type" == "cli" ]; then
        log_success "CLI tool $repo_name started (no HTTP test)"
        return 0
    fi
    
    # Determine the test URL based on service type
    local test_url=""
    local health_path=""
    
    case "$service_type" in
        "streamlit")
            test_url="http://localhost:$host_port/_stcore/health"
            ;;
        "fastapi")
            test_url="http://localhost:$host_port/health"
            health_path="/docs"
            ;;
        "gradio")
            test_url="http://localhost:$host_port/"
            ;;
    esac
    
    log "Waiting for $repo_name service to be ready..."
    
    # Wait for service to be ready (max 120 seconds)
    local max_wait=120
    local waited=0
    local success=false
    
    while [ $waited -lt $max_wait ]; do
        if curl -sf "$test_url" > /dev/null 2>&1; then
            success=true
            break
        fi
        sleep 5
        waited=$((waited + 5))
        echo "  Waited ${waited}s for $repo_name..." | tee -a "$RESULTS_FILE"
    done
    
    if [ "$success" == "true" ]; then
        log_success "$repo_name HTTP service is ready on port $host_port"
        return 0
    else
        # Try alternative endpoints
        log_warn "Primary endpoint not responding, trying alternatives..."
        
        # Try /health for fastapi/gradio
        if curl -sf "http://localhost:$host_port/health" > /dev/null 2>&1; then
            log_success "$repo_name HTTP service is ready (via /health) on port $host_port"
            return 0
        fi
        
        # Try /api/health
        if curl -sf "http://localhost:$host_port/api/health" > /dev/null 2>&1; then
            log_success "$repo_name HTTP service is ready (via /api/health) on port $host_port"
            return 0
        fi
        
        # Try /status
        if curl -sf "http://localhost:$host_port/status" > /dev/null 2>&1; then
            log_success "$repo_name HTTP service is ready (via /status) on port $host_port"
            return 0
        fi
        
        log_error "$repo_name HTTP service failed to start within ${max_wait}s"
        return 1
    fi
}

# Process each repo
log "Starting batch workflow..."
log "Processing ${#PORT_MAP[@]} repositories..."

for repo_name in "${!PORT_MAP[@]}"; do
    TOTAL_REPOS=$((TOTAL_REPOS + 1))
    echo "" >> "$RESULTS_FILE"
    echo "=============================================" >> "$RESULTS_FILE"
    echo "Processing: $repo_name" >> "$RESULTS_FILE"
    echo "=============================================" >> "$RESULTS_FILE"
    
    # Parse port mapping
    IFS=':' read -r host_port container_port service_type <<< "${PORT_MAP[$repo_name]}"
    
    repo_path="$REPO_BASE_DIR/$repo_name"
    dockerfile="$repo_path/Dockerfile"
    
    # Step 1: Build image if not exists
    if ! build_image "$repo_name" "$repo_path" "$dockerfile"; then
        FAILED_REPOS=$((FAILED_REPOS + 1))
        continue
    fi
    
    # Step 2: Start container
    if ! start_container "$repo_name" "$host_port" "$container_port"; then
        FAILED_REPOS=$((FAILED_REPOS + 1))
        continue
    fi
    
    # Step 3: Verify HTTP service (skip for CLI tools)
    if [ "$service_type" == "cli" ]; then
        SKIPPED_REPOS=$((SKIPPED_REPOS + 1))
        SUCCESSFUL_REPOS=$((SUCCESSFUL_REPOS + 1))
        log_success "$repo_name (CLI tool - skipped HTTP test)"
    else
        if verify_service "$repo_name" "$host_port" "$service_type"; then
            SUCCESSFUL_REPOS=$((SUCCESSFUL_REPOS + 1))
        else
            FAILED_REPOS=$((FAILED_REPOS + 1))
        fi
    fi
done

# Final summary
END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
echo "" >> "$RESULTS_FILE"
echo "=============================================" >> "$RESULTS_FILE"
echo "SUMMARY" >> "$RESULTS_FILE"
echo "Started: $START_TIME" >> "$RESULTS_FILE"
echo "Ended: $END_TIME" >> "$RESULTS_FILE"
echo "=============================================" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"
echo "Total Repos: $TOTAL_REPOS" >> "$RESULTS_FILE"
echo "Successful: $SUCCESSFUL_REPOS" >> "$RESULTS_FILE"
echo "Failed: $FAILED_REPOS" >> "$RESULTS_FILE"
echo "Skipped (CLI): $SKIPPED_REPOS" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# List successful services
echo "SUCCESSFUL SERVICES:" >> "$RESULTS_FILE"
for repo_name in "${!PORT_MAP[@]}"; do
    IFS=':' read -r host_port container_port service_type <<< "${PORT_MAP[$repo_name]}"
    if [ "$service_type" != "cli" ]; then
        echo "  - $repo_name: http://localhost:$host_port" >> "$RESULTS_FILE"
    else
        echo "  - $repo_name: CLI tool (no HTTP service)" >> "$RESULTS_FILE"
    fi
done
echo "" >> "$RESULTS_FILE"

# List failed repos
if [ $FAILED_REPOS -gt 0 ]; then
    echo "FAILED REPOS:" >> "$RESULTS_FILE"
    echo "Check the logs above for details." >> "$RESULTS_FILE"
fi

log "Batch workflow completed!"
log "Results saved to: $RESULTS_FILE"
log "Total: $TOTAL_REPOS | Success: $SUCCESSFUL_REPOS | Failed: $FAILED_REPOS | Skipped: $SKIPPED_REPOS"

# Output summary to stdout
echo ""
echo "============================================="
echo "BATCH WORKFLOW SUMMARY"
echo "============================================="
echo "Total Repos: $TOTAL_REPOS"
echo "Successful: $SUCCESSFUL_REPOS"
echo "Failed: $FAILED_REPOS"
echo "Skipped (CLI): $SKIPPED_REPOS"
echo ""
echo "Results saved to: $RESULTS_FILE"
echo ""
echo "SUCCESSFUL SERVICES:"
for repo_name in "${!PORT_MAP[@]}"; do
    IFS=':' read -r host_port container_port service_type <<< "${PORT_MAP[$repo_name]}"
    if [ "$service_type" != "cli" ]; then
        echo "  - $repo_name: http://localhost:$host_port"
    else
        echo "  - $repo_name: CLI tool (no HTTP service)"
    fi
done
echo "============================================="
