#!/bin/bash
# Batch workflow script to start all 10 repos and verify HTTP services
# =============================================================================

set -e

# Configuration
RESULTS_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/batch_workflow_results.txt"
DOCKER_REPO_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs"

# OpenAI API config (to be added to Dockerfiles)
OPENAI_API_KEY="11"
OPENAI_API_BASE_URL="http://157.10.162.82:443/v1/"
GPT_MODEL="gpt-5.1"

# Port mapping (host_port: internal_port)
declare -A PORT_DETAILS=(
    ["mrwadams--attackgen"]="11110:8500"
    ["gptme--gptme"]="11130:11130"
    ["NEKOparapa--AiNiee"]="11460:8000"
    ["langchain-ai--local-deep-researcher"]="11030:7860"
    ["AuvaLab--itext2kg"]="11380:7860"
    ["bowang-lab--MedRAX"]="11180:8585"
    ["modelscope--FunClip"]="11430:7860"
    ["AntonOsika--gpt-engineer"]="11330:8000"
    ["joshpxyne--gpt-migrate"]="11470:0"
    ["jianchang512--pyvideotrans"]="11160:0"
)

# Service types for HTTP detection
declare -A SERVICE_TYPES=(
    ["mrwadams--attackgen"]="streamlit"
    ["gptme--gptme"]="fastapi"
    ["NEKOparapa--AiNiee"]="gradio"
    ["langchain-ai--local-deep-researcher"]="gradio"
    ["AuvaLab--itext2kg"]="gradio"
    ["bowang-lab--MedRAX"]="gradio"
    ["modelscope--FunClip"]="gradio"
    ["AntonOsika--gpt-engineer"]="gradio"
    ["joshpxyne--gpt-migrate"]="cli"
    ["jianchang512--pyvideotrans"]="cli"
)

# Results tracking
declare -A REPO_STATUS
declare -A HTTP_STATUS
declare -A ERRORS

TOTAL_REPOS=10
SUCCESS_COUNT=0
HTTP_SUCCESS_COUNT=0
HTTP_SKIP_COUNT=0
ERROR_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Initialize results file
echo "============================================================" > "$RESULTS_FILE"
echo "Batch Workflow Results" >> "$RESULTS_FILE"
echo "Generated: $(date)" >> "$RESULTS_FILE"
echo "============================================================" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

log_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

# Function to test HTTP endpoint
test_http_endpoint() {
    local host_port=$1
    local repo_name=$2
    local service_type=$3
    
    log_info "Testing HTTP endpoint for $repo_name on port $host_port..."
    
    if [ "$service_type" == "cli" ]; then
        log_info "Skipping HTTP test for CLI-only tool: $repo_name"
        return 2
    fi
    
    local max_attempts=30
    local attempt=1
    local success=0
    
    while [ $attempt -le $max_attempts ]; do
        if curl -sf "http://localhost:$host_port" > /dev/null 2>&1; then
            log "HTTP service is UP on port $host_port"
            success=1
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            log_warn "HTTP service NOT responding after $max_attempts attempts on port $host_port"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts: Waiting for $repo_name service on port $host_port..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [ $success -eq 1 ]; then
        return 1
    fi
    
    return 0
}

# Function to update Dockerfile with OpenAI config
update_dockerfile() {
    local repo_name=$1
    local dockerfile_path="$DOCKER_REPO_DIR/$repo_name/Dockerfile"
    
    if [ ! -f "$dockerfile_path" ]; then
        log_warn "Dockerfile not found: $dockerfile_path"
        return 1
    fi
    
    # Update OPENAI_API_KEY if it exists
    if grep -q "OPENAI_API_KEY" "$dockerfile_path"; then
        sed -i 's/OPENAI_API_KEY="[^"]*"/OPENAI_API_KEY="11"/' "$dockerfile_path"
        sed -i 's|OPENAI_API_BASE_URL="[^"]*"|OPENAI_API_BASE_URL="http://157.10.162.82:443/v1/"|' "$dockerfile_path"
        sed -i 's/GPT_MODEL="[^"]*"/GPT_MODEL="gpt-5.1"/' "$dockerfile_path"
        log "Updated Dockerfile with OpenAI config: $repo_name"
    else
        log "No OPENAI_API_KEY found in Dockerfile, skipping update: $repo_name"
    fi
}

# Function to build Docker image
build_docker_image() {
    local repo_name=$1
    local dockerfile_path="$DOCKER_REPO_DIR/$repo_name/Dockerfile"
    
    if [ ! -f "$dockerfile_path" ]; then
        log_error "Dockerfile not found for $repo_name"
        ERRORS[$repo_name]="Dockerfile not found"
        return 1
    fi
    
    local image_name="medrax:$repo_name"
    
    log_info "Building Docker image for $repo_name..."
    
    if docker images "$image_name" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "^${image_name}$"; then
        log "Docker image already exists for $repo_name, skipping build"
        return 0
    fi
    
    if docker build -t "$image_name" "$DOCKER_REPO_DIR/$repo_name" 2>&1 | tee /tmp/build_${repo_name//\//_}.log; then
        log "Successfully built image for $repo_name"
        return 0
    else
        log_error "Failed to build image for $repo_name"
        ERRORS[$repo_name]="Docker build failed"
        return 1
    fi
}

# Function to start container
start_container() {
    local repo_name=$1
    local port_mapping=$2
    local service_type=$3
    local container_name="medrax_${repo_name//\//_}"
    
    log_info "Starting container for $repo_name..."
    
    if docker ps -a --format "{{.Names}}" 2>/dev/null | grep -q "^${container_name}$"; then
        log "Stopping existing container: $container_name"
        docker stop "$container_name" 2>/dev/null || true
        docker rm "$container_name" 2>/dev/null || true
    fi
    
    # For CLI tools, no port mapping needed
    if [ "$service_type" == "cli" ]; then
        docker run -d --name "$container_name" \
            -e OPENAI_API_KEY="$OPENAI_API_KEY" \
            -e OPENAI_API_BASE_URL="$OPENAI_API_BASE_URL" \
            -e GPT_MODEL="$GPT_MODEL" \
            "medrax:$repo_name"
    else
        docker run -d --name "$container_name" -p "$port_mapping" \
            -e OPENAI_API_KEY="$OPENAI_API_KEY" \
            -e OPENAI_API_BASE_URL="$OPENAI_API_BASE_URL" \
            -e GPT_MODEL="$GPT_MODEL" \
            "medrax:$repo_name"
    fi
    
    if [ $? -eq 0 ]; then
        log "Successfully started container for $repo_name"
        return 0
    else
        log_error "Failed to start container for $repo_name"
        ERRORS[$repo_name]="Failed to start container"
        return 1
    fi
}

# Main workflow
main() {
    echo "============================================================" >> "$RESULTS_FILE"
    echo "Starting Batch Workflow" >> "$RESULTS_FILE"
    echo "Timestamp: $(date)" >> "$RESULTS_FILE"
    echo "============================================================" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    for repo_name in "${!PORT_DETAILS[@]}"; do
        echo "============================================================" >> "$RESULTS_FILE"
        echo "Processing: $repo_name" >> "$RESULTS_FILE"
        echo "============================================================" >> "$RESULTS_FILE"
        
        port_detail=${PORT_DETAILS[$repo_name]}
        service_type=${SERVICE_TYPES[$repo_name]}
        
        IFS=':' read -r host_port internal_port <<< "$port_detail"
        
        if [ "$service_type" == "cli" ]; then
            echo "Service type: CLI-only (no HTTP test)" >> "$RESULTS_FILE"
            is_cli=1
        else
            echo "Service type: $service_type" >> "$RESULTS_FILE"
            echo "Internal port: $internal_port" >> "$RESULTS_FILE"
            echo "Host port: $host_port" >> "$RESULTS_FILE"
            is_cli=0
        fi
        echo "" >> "$RESULTS_FILE"
        
        # Step 1: Build Docker image
        echo "Step 1: Building Docker image..." >> "$RESULTS_FILE"
        if build_docker_image "$repo_name"; then
            REPO_STATUS[$repo_name]="IMAGE_BUILT"
            echo "Status: IMAGE_BUILT" >> "$RESULTS_FILE"
        else
            REPO_STATUS[$repo_name]="IMAGE_BUILD_FAILED"
            echo "Status: IMAGE_BUILD_FAILED" >> "$RESULTS_FILE"
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo "" >> "$RESULTS_FILE"
            continue
        fi
        echo "" >> "$RESULTS_FILE"
        
        # Step 2: Start container
        echo "Step 2: Starting container..." >> "$RESULTS_FILE"
        if start_container "$repo_name" "$port_detail" "$service_type"; then
            REPO_STATUS[$repo_name]="CONTAINER_STARTED"
            echo "Status: CONTAINER_STARTED" >> "$RESULTS_FILE"
        else
            REPO_STATUS[$repo_name]="CONTAINER_START_FAILED"
            echo "Status: CONTAINER_START_FAILED" >> "$RESULTS_FILE"
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo "" >> "$RESULTS_FILE"
            continue
        fi
        echo "" >> "$RESULTS_FILE"
        
        # Step 3: Wait and test HTTP endpoint
        if [ $is_cli -eq 0 ]; then
            echo "Step 3: Testing HTTP endpoint..." >> "$RESULTS_FILE"
            if test_http_endpoint "$host_port" "$repo_name" "$service_type"; then
                HTTP_STATUS[$repo_name]="HTTP_UP"
                HTTP_SUCCESS_COUNT=$((HTTP_SUCCESS_COUNT + 1))
                echo "Status: HTTP_UP" >> "$RESULTS_FILE"
                echo "HTTP endpoint verified: http://localhost:$host_port" >> "$RESULTS_FILE"
            else
                HTTP_STATUS[$repo_name]="HTTP_DOWN"
                echo "Status: HTTP_DOWN" >> "$RESULTS_FILE"
                echo "HTTP endpoint NOT verified: http://localhost:$host_port" >> "$RESULTS_FILE"
            fi
            echo "" >> "$RESULTS_FILE"
        else
            HTTP_STATUS[$repo_name]="SKIP_HTTP"
            HTTP_SKIP_COUNT=$((HTTP_SKIP_COUNT + 1))
            echo "Step 3: Skipped HTTP test (CLI tool)" >> "$RESULTS_FILE"
            echo "" >> "$RESULTS_FILE"
        fi
        
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        
        echo "" >> "$RESULTS_FILE"
        echo "============================================================" >> "$RESULTS_FILE"
        echo "Completed: $repo_name" >> "$RESULTS_FILE"
        echo "============================================================" >> "$RESULTS_FILE"
        echo "" >> "$RESULTS_FILE"
        
        sleep 1
    done
    
    generate_summary
}

generate_summary() {
    echo "" >> "$RESULTS_FILE"
    echo "============================================================" >> "$RESULTS_FILE"
    echo "SUMMARY" >> "$RESULTS_FILE"
    echo "============================================================" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "Total repositories: $TOTAL_REPOS" >> "$RESULTS_FILE"
    echo "Successfully started: $SUCCESS_COUNT" >> "$RESULTS_FILE"
    echo "Failed to start: $ERROR_COUNT" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "HTTP Service Status:" >> "$RESULTS_FILE"
    echo "  - Verified UP: $HTTP_SUCCESS_COUNT" >> "$RESULTS_FILE"
    echo "  - CLI-only (skipped): $HTTP_SKIP_COUNT" >> "$RESULTS_FILE"
    echo "  - Failed/Not verified: $((TOTAL_REPOS - HTTP_SUCCESS_COUNT - HTTP_SKIP_COUNT))" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "Repository Details:" >> "$RESULTS_FILE"
    echo "-------------------" >> "$RESULTS_FILE"
    for repo_name in "${!PORT_DETAILS[@]}"; do
        status="${REPO_STATUS[$repo_name]:-UNKNOWN}"
        http="${HTTP_STATUS[$repo_name]:-UNKNOWN}"
        error="${ERRORS[$repo_name]:-None}"
        printf "  %-40s | %-25s | %-15s | %s\n" "$repo_name" "$status" "$http" "$error" >> "$RESULTS_FILE"
    done
    echo "" >> "$RESULTS_FILE"
    echo "Recommendations:" >> "$RESULTS_FILE"
    echo "----------------" >> "$RESULTS_FILE"
    
    if [ $ERROR_COUNT -gt 0 ]; then
        echo "  - Review failed builds/starts above" >> "$RESULTS_FILE"
        echo "  - Check Docker logs: docker logs <container_name>" >> "$RESULTS_FILE"
    fi
    
    if [ $HTTP_SUCCESS_COUNT -lt $((TOTAL_REPOS - HTTP_SKIP_COUNT)) ]; then
        echo "  - Some HTTP services are not responding" >> "$RESULTS_FILE"
        echo "  - Check service logs and firewall rules" >> "$RESULTS_FILE"
    fi
    
    echo "  - All containers can be stopped with: docker stop \$(docker ps -q --filter name=medrax_)" >> "$RESULTS_FILE"
    echo "  - All containers can be removed with: docker rm \$(docker ps -aq --filter name=medrax_)" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "Completed: $(date)" >> "$RESULTS_FILE"
    echo "============================================================" >> "$RESULTS_FILE"
    
    echo ""
    echo "============================================================"
    echo "BATCH WORKFLOW SUMMARY"
    echo "============================================================"
    echo ""
    echo "Total repositories: $TOTAL_REPOS"
    echo "Successfully started: $SUCCESS_COUNT"
    echo "Failed to start: $ERROR_COUNT"
    echo ""
    echo "HTTP Service Status:"
    echo "  - Verified UP: $HTTP_SUCCESS_COUNT"
    echo "  - CLI-only (skipped): $HTTP_SKIP_COUNT"
    echo "  - Failed/Not verified: $((TOTAL_REPOS - HTTP_SUCCESS_COUNT - HTTP_SKIP_COUNT))"
    echo ""
    echo "Results saved to: $RESULTS_FILE"
    echo "============================================================"
}

main
