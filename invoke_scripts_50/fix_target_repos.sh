#!/bin/bash

# Fix script for all unhealthy/down/crashed target repos
# Runs in a continuous loop until all 10 repos are working
# Updated version with correct lowercase naming and specific fixes

set -e

LOG_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/fix_target_repos.log"
REPO_BASE_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs"

# Initialize log
echo "========================================" > "$LOG_FILE"
echo "Fix Target Repos Script - $(date)" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# Function to log messages
log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" | tee -a "$LOG_FILE"
}

# Function to check HTTP endpoint
check_http() {
    local port=$1
    local max_attempts=5
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        sleep 2
        local status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port" 2>/dev/null || echo "000")
        if [ "$status" = "200" ] || [ "$status" = "301" ] || [ "$status" = "302" ]; then
            return 0
        fi
        attempt=$((attempt + 1))
    done
    return 1
}

# Function to get container logs
get_container_logs() {
    local container_name=$1
    docker logs "$container_name" --tail 50 2>/dev/null || echo "No logs available"
}

# Function to check if container is running
is_container_running() {
    local container_name=$1
    docker ps --format '{{.Names}}' | grep -q "^${container_name}$"
}

# Function to stop and remove container
stop_container() {
    local container_name=$1
    if is_container_running "$container_name"; then
        log "Stopping container $container_name..."
        docker stop "$container_name" 2>/dev/null || true
    fi
    docker rm "$container_name" 2>/dev/null || true
}

# ============================================
# SPECIFIC FIXES FOR EACH REPO
# ============================================

# 1. Fix gptme--gptme (11130)
# Container exits with code 1 - likely a server startup issue
fix_gptme() {
    local repo_name="gptme--gptme"
    local port=11130
    local container_name="gptme--gptme_container"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="gptme--gptme_image"

    log "=== Fixing $repo_name (port $port) ==="

    stop_container "$container_name"

    # Check if image exists
    if ! docker images -q "$image_name" > /dev/null 2>&1; then
        log "Image not found, building..."
        docker build -t "$image_name" "$repo_dir" 2>&1 | tee -a "$LOG_FILE"
    fi

    log "Starting container..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:11130 \
        -e GPTME_SERVER_HOST=0.0.0.0 \
        -e GPTME_SERVER_PORT=11130 \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 15
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        get_container_logs "$container_name" >> "$LOG_FILE"
        return 1
    fi
}

# 2. Fix NEKOparapa--AiNiee (11460)
# HTTP service needs to be enabled in config
fix_ainenie() {
    local repo_name="NEKOparapa--AiNiee"
    local port=11460
    local container_name="nekoparapa--ainenie_container"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="nekoparapa--ainenie_image"

    log "=== Fixing $repo_name (port $port) ==="

    stop_container "$container_name"

    # Enable HTTP service in config
    local config_file="$repo_dir/Resource/config.json"
    if [ -f "$config_file" ]; then
        log "Found config file, enabling HTTP service..."
        sed -i 's/"http_server_enable": false/"http_server_enable": true/g' "$config_file" 2>/dev/null || true
        sed -i 's/"http_listen_address": "127.0.0.1:3388"|"http_listen_address": "0.0.0.0:3388"/g' "$config_file" 2>/dev/null || true
    fi

    if ! docker images -q "$image_name" > /dev/null 2>&1; then
        log "Building image..."
        docker build -t "$image_name" "$repo_dir" 2>&1 | tee -a "$LOG_FILE"
    fi

    log "Starting container with port 3388 mapped to $port..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:3388 \
        -e PYTHONUNBUFFERED=1 \
        -e QT_QPA_PLATFORM=offscreen \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 15
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        get_container_logs "$container_name" >> "$LOG_FILE"
        return 1
    fi
}

# 3. Fix langchain-ai--local-deep-researcher (11030 -> 2024)
# Missing langchain_ollama module
fix_local_deep_researcher() {
    local repo_name="langchain-ai--local-deep-researcher"
    local port=11030
    local container_name="langchain-ai--local-deep-researcher_container"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="langchain-ai--local-deep-researcher_image"
    local container_port=2024

    log "=== Fixing $repo_name (host port $port -> container port $container_port) ==="

    stop_container "$container_name"

    if ! docker images -q "$image_name" > /dev/null 2>&1; then
        log "Image not found..."
    fi

    log "Starting container with correct port mapping..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:${container_port} \
        -e LANGGRAPH_HOST=0.0.0.0 \
        -e LANGGRAPH_PORT=${container_port} \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 15
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        get_container_logs "$container_name" >> "$LOG_FILE"
        return 1
    fi
}

# 4. Fix AuvaLab--itext2kg (11380)
# Needs __main__.py in package
fix_itext2kg() {
    local repo_name="AuvaLab--itext2kg"
    local port=11380
    local container_name="auvalab--itext2kg_container"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="auvalab--itext2kg_image"

    log "=== Fixing $repo_name (port $port) ==="

    stop_container "$container_name"

    if ! docker images -q "$image_name" > /dev/null 2>&1; then
        log "Building image..."
        docker build -t "$image_name" "$repo_dir" 2>&1 | tee -a "$LOG_FILE"
    fi

    log "Starting container..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:11380 \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 15
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        get_container_logs "$container_name" >> "$LOG_FILE"
        return 1
    fi
}

# 5. Fix bowang-lab--MedRAX (11180 -> 8585)
# CUDA/GPU required - skip with appropriate logging
fix_medrax() {
    local repo_name="bowang-lab--MedRAX"
    local port=11180
    local container_name="bowang-lab--medrax_container"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="bowang-lab--medrax_image"
    local container_port=8585

    log "=== Fixing $repo_name (host port $port -> container port $container_port) ==="

    stop_container "$container_name"

    if ! docker images -q "$image_name" > /dev/null 2>&1; then
        log "Building image..."
        docker build -t "$image_name" "$repo_dir" 2>&1 | tee -a "$LOG_FILE"
    fi

    log "Starting container (note: requires CUDA/GPU)..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:${container_port} \
        --gpus all \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 15
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED (GPU/CUDA required or container failed)"
        get_container_logs "$container_name" >> "$LOG_FILE"
        return 1
    fi
}

# 6. Fix AntonOsika--gpt-engineer (11330)
# Requires OPENAI_API_KEY
fix_gpt_engineer() {
    local repo_name="AntonOsika--gpt-engineer"
    local port=11330
    local container_name="antonosika--gpt-engineer_container"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="antonosika--gpt-engineer_image"

    log "=== Fixing $repo_name (port $port) ==="

    stop_container "$container_name"

    # Check for API key
    local api_key="${OPENAI_API_KEY:-}"
    if [ -z "$api_key" ]; then
        log "WARNING: OPENAI_API_KEY not set. Container may fail."
    fi

    if ! docker images -q "$image_name" > /dev/null 2>&1; then
        log "Building image..."
        docker build -t "$image_name" "$repo_dir" 2>&1 | tee -a "$LOG_FILE"
    fi

    log "Starting container..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:8000 \
        -e OPENAI_API_KEY="$api_key" \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 15
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        get_container_logs "$container_name" >> "$LOG_FILE"
        return 1
    fi
}

# 7. Fix jianchang512--pyvideotrans (11160)
# Qt library issue
fix_pyvideotrans() {
    local repo_name="jianchang512--pyvideotrans"
    local port=11160
    local container_name="jianchang512--pyvideotrans_container"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="jianchang512--pyvideotrans_image"

    log "=== Fixing $repo_name (port $port) ==="

    stop_container "$container_name"

    if ! docker images -q "$image_name" > /dev/null 2>&1; then
        log "Building image..."
        docker build -t "$image_name" "$repo_dir" 2>&1 | tee -a "$LOG_FILE"
    fi

    log "Starting container with Qt headless mode..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:8000 \
        -e QT_QPA_PLATFORM=offscreen \
        -e DISPLAY=:99 \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 15
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        get_container_logs "$container_name" >> "$LOG_FILE"
        return 1
    fi
}

# Check healthy count
check_healthy_count() {
    local count=0
    
    log "Checking healthy repos..."
    
    # mrwadams--attackgen (11110) - should be healthy
    if check_http 11110; then
        log "mrwadams--attackgen (11110): HEALTHY"
        count=$((count + 1))
    fi
    
    # modelscope--FunClip (11430) - should be healthy
    if check_http 11430; then
        log "modelscope--FunClip (11430): HEALTHY"
        count=$((count + 1))
    fi
    
    # joshpxyne--gpt-migrate (11470) - CLI tool, skip
    log "joshpxyne--gpt-migrate (11470): SKIPPED (CLI tool)"
    
    # gptme--gptme (11130)
    if check_http 11130; then
        log "gptme--gptme (11130): HEALTHY"
        count=$((count + 1))
    else
        log "gptme--gptme (11130): UNHEALTHY"
    fi
    
    # NEKOparapa--AiNiee (11460)
    if check_http 11460; then
        log "NEKOparapa--AiNiee (11460): HEALTHY"
        count=$((count + 1))
    else
        log "NEKOparapa--AiNiee (11460): UNHEALTHY"
    fi
    
    # langchain-ai--local-deep-researcher (11030)
    if check_http 11030; then
        log "langchain-ai--local-deep-researcher (11030): HEALTHY"
        count=$((count + 1))
    else
        log "langchain-ai--local-deep-researcher (11030): UNHEALTHY"
    fi
    
    # AuvaLab--itext2kg (11380)
    if check_http 11380; then
        log "AuvaLab--itext2kg (11380): HEALTHY"
        count=$((count + 1))
    else
        log "AuvaLab--itext2kg (11380): UNHEALTHY"
    fi
    
    # bowang-lab--MedRAX (11180)
    if check_http 11180; then
        log "bowang-lab--MedRAX (11180): HEALTHY"
        count=$((count + 1))
    else
        log "bowang-lab--MedRAX (11180): UNHEALTHY"
    fi
    
    # AntonOsika--gpt-engineer (11330)
    if check_http 11330; then
        log "AntonOsika--gpt-engineer (11330): HEALTHY"
        count=$((count + 1))
    else
        log "AntonOsika--gpt-engineer (11330): UNHEALTHY"
    fi
    
    # jianchang512--pyvideotrans (11160)
    if check_http 11160; then
        log "jianchang512--pyvideotrans (11160): HEALTHY"
        count=$((count + 1))
    else
        log "jianchang512--pyvideotrans (11160): UNHEALTHY"
    fi
    
    log "Healthy count: $count / 10"
    return $((count == 10 ? 0 : 1))
}

# ============================================
# MAIN LOOP
# ============================================

log "Starting continuous fix loop for target repos..."
log "Target repos:"
log "  - mrwadams--attackgen (11110) - healthy"
log "  - gptme--gptme (11130) - requires API key setup"
log "  - NEKOparapa--AiNiee (11460) - HTTP server needs config fix"
log "  - langchain-ai--local-deep-researcher (11030 -> 2024) - needs langchain_ollama module"
log "  - AuvaLab--itext2kg (11380) - needs __main__.py in package"
log "  - bowang-lab--MedRAX (11180 -> 8585) - requires CUDA/GPU"
log "  - modelscope--FunClip (11430) - healthy"
log "  - AntonOsika--gpt-engineer (11330) - requires OPENAI_API_KEY"
log "  - joshpxyne--gpt-migrate (11470) - CLI tool, skip"
log "  - jianchang512--pyvideotrans (11160) - Qt library issue"
log ""

iteration=0
while true; do
    iteration=$((iteration + 1))
    log ""
    log "============================================"
    log "ITERATION $iteration"
    log "============================================"

    # Run fixes for each repo
    fix_gptme || true
    fix_ainenie || true
    fix_local_deep_researcher || true
    fix_itext2kg || true
    fix_medrax || true
    fix_gpt_engineer || true
    fix_pyvideotrans || true

    # Check all repos
    log ""
    log "Checking all repos after fixes..."
    
    if check_healthy_count; then
        log ""
        log "============================================"
        log "SUCCESS! All 10 repos are now healthy!"
        log "============================================"
        break
    fi

    log ""
    log "Waiting 30 seconds before next iteration..."
    sleep 30
done

log ""
log "Fix script completed at: $(date)"
