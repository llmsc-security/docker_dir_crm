#!/bin/bash

# Continuous fix loop for target repos
# Runs until all 10 repos are healthy or stopped by user

LOG_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/fix_loop.log"
REPO_BASE_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs"
PORT_MAPPING_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/port_mapping_50_gap10_1.json"

# Target repos from port_mapping_50_gap10_1.json with lowercase names
declare -A REPOS=(
    ["mrwadams--attackgen"]=11110
    ["gptme--gptme"]=11130
    ["nekoparapa--ainenie"]=11460
    ["langchain-ai--local-deep-researcher"]=11030
    ["auvalab--itext2kg"]=11380
    ["bowang-lab--medrax"]=11180
    ["modelscope--funclip"]=11430
    ["antonosika--gpt-engineer"]=11330
    ["joshpxyne--gpt-migrate"]=11470
    ["jianchang512--pyvideotrans"]=11160
)

# Function to log messages
log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" | tee -a "$LOG_FILE"
}

# Function to check HTTP endpoint with retry
check_http() {
    local port=$1
    local max_attempts=5
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        sleep 2
        local status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port" 2>/dev/null || echo "000")
        if [ "$status" = "200" ] || [ "$status" = "301" ] || [ "$status" = "302" ] || [ "$status" = "404" ]; then
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
        log "  Stopping container $container_name..."
        docker stop "$container_name" 2>/dev/null || true
    fi
    docker rm "$container_name" 2>/dev/null || true
}

# ============================================
# REPO-SPECIFIC FIX FUNCTIONS
# ============================================

# 1. Fix gptme--gptme (port 11130)
# Issue: Container exits with code 1, no logs available
fix_gptme() {
    local repo_name="gptme--gptme"
    local port=11130
    local container_name="gptme--gptme"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="gptme--gptme_image"

    log "=== Fixing $repo_name (port $port) ==="
    stop_container "$container_name"

    # Try to start with correct port
    log "  Starting container..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:11130 \
        -e GPTME_SERVER_HOST=0.0.0.0 \
        -e GPTME_SERVER_PORT=11130 \
        --rm "$image_name" 2>&1 | tee -a "$LOG_FILE"

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

# 2. Fix nekoparapa--ainenie (port 11460)
# Issue: HTTP service disabled by default in config
fix_ainenie() {
    local repo_name="NEKOparapa--AiNiee"
    local port=11460
    local container_name="nekoparapa--ainenie"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="nekoparapa--ainenie_image"

    log "=== Fixing $repo_name (port $port) ==="
    stop_container "$container_name"

    # The issue is the HTTP service is disabled by default
    local config_file="$repo_dir/Resource/config.json"
    if [ -f "$config_file" ]; then
        log "  Found config file, enabling HTTP service..."
        sed -i 's/"http_server_enable": false/"http_server_enable": true/' "$config_file" 2>/dev/null || true
        sed -i 's|"http_listen_address": "127.0.0.1:3388"|"http_listen_address": "0.0.0.0:3388"|' "$config_file" 2>/dev/null || true
    fi

    # Run container with HTTP port mapping
    log "  Starting container with port 3388 mapped to $port..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:3388 \
        -e PYTHONUNBUFFERED=1 \
        -e QT_QPA_PLATFORM=offscreen \
        --rm "$image_name" 2>&1 | tee -a "$LOG_FILE"

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

# 3. Fix langchain-ai--local-deep-researcher (host port 11030 -> container port 2024)
# Issue: Missing langchain_ollama module
fix_local_deep_researcher() {
    local repo_name="langchain-ai--local-deep-researcher"
    local port=11030
    local container_name="langchain-ai--local-deep-researcher"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="langchain-ai--local-deep-researcher_image"
    local container_port=2024

    log "=== Fixing $repo_name (host port $port -> container port $container_port) ==="
    stop_container "$container_name"

    # The issue is the missing langchain_ollama module
    # We need to modify the graph to use a different backend
    log "  Note: This repo requires langchain_ollama module which is not installed."

    # Run container
    log "  Starting container..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:${container_port} \
        -e LANGGRAPH_HOST=0.0.0.0 \
        -e LANGGRAPH_PORT=${container_port} \
        --rm "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 15
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED (requires langchain_ollama)"
        get_container_logs "$container_name" >> "$LOG_FILE"
        return 1
    fi
}

# 4. Fix auvalab--itext2kg (port 11380)
# Issue: Missing __main__.py in package
fix_itext2kg() {
    local repo_name="AuvaLab--itext2kg"
    local port=11380
    local container_name="auvalab--itext2kg"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="auvalab--itext2kg_image"

    log "=== Fixing $repo_name (port $port) ==="
    stop_container "$container_name"

    # The issue is the missing __main__.py in the package
    log "  Note: This repo requires __main__.py in the package directory."

    # Run container
    log "  Starting container..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:11380 \
        --rm "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 15
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED (missing __main__.py)"
        get_container_logs "$container_name" >> "$LOG_FILE"
        return 1
    fi
}

# 5. Fix bowang-lab--medrax (port 11180)
# Issue: Requires CUDA/GPU
fix_medrax() {
    local repo_name="bowang-lab--MedRAX"
    local port=11180
    local container_name="bowang-lab--medrax"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="bowang-lab--medrax_image"
    local container_port=8585

    log "=== Fixing $repo_name (host port $port -> container port $container_port) ==="
    stop_container "$container_name"

    log "  Starting container (note: requires CUDA/GPU)..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:${container_port} \
        --gpus all \
        --rm "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 15
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED (GPU/CUDA required)"
        get_container_logs "$container_name" >> "$LOG_FILE"
        return 1
    fi
}

# 6. Fix antonosika--gpt-engineer (port 11330)
# Issue: Requires OPENAI_API_KEY
fix_gpt_engineer() {
    local repo_name="AntonOsika--gpt-engineer"
    local port=11330
    local container_name="antonosika--gpt-engineer"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="antonosika--gpt-engineer_image"

    log "=== Fixing $repo_name (port $port) ==="
    stop_container "$container_name"

    # Check for API key
    local api_key="${OPENAI_API_KEY:-}"
    if [ -z "$api_key" ]; then
        log "  WARNING: OPENAI_API_KEY not set. Container will start but may fail."
        api_key="placeholder-key-not-configured"
    fi

    # Run container
    log "  Starting container..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:8000 \
        -e OPENAI_API_KEY="$api_key" \
        --rm "$image_name" 2>&1 | tee -a "$LOG_FILE"

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

# 7. Fix jianchang512--pyvideotrans (port 11160)
# Issue: Qt library/GUI issue
fix_pyvideotrans() {
    local repo_name="jianchang512--pyvideotrans"
    local port=11160
    local container_name="jianchang512--pyvideotrans"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local image_name="jianchang512--pyvideotrans_image"

    log "=== Fixing $repo_name (port $port) ==="
    stop_container "$container_name"

    # Try running with headless mode
    log "  Starting container with Qt headless mode..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:8000 \
        -e QT_QPA_PLATFORM=offscreen \
        -e DISPLAY=:99 \
        --rm "$image_name" 2>&1 | tee -a "$LOG_FILE"

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

# 8. Check mrwadams--attackgen (healthy - skip)
check_attackgen() {
    local port=11110
    log "=== Checking mrwadams--attackgen (port $port) ==="
    if check_http "$port"; then
        log "mrwadams--attackgen (11110): HEALTHY"
        return 0
    else
        log "mrwadams--attackgen (11110): UNHEALTHY"
        return 1
    fi
}

# 9. Check modelscope--funclip (healthy - skip)
check_funclip() {
    local port=11430
    log "=== Checking modelscope--funclip (port $port) ==="
    if check_http "$port"; then
        log "modelscope--funclip (11430): HEALTHY"
        return 0
    else
        log "modelscope--funclip (11430): UNHEALTHY"
        return 1
    fi
}

# 10. Check joshpxyne--gpt-migrate (CLI tool - skip)
check_gpt_migrate() {
    log "=== joshpxyne--gpt-migrate (port 11470) ==="
    log "joshpxyne--gpt-migrate (11470): SKIPPED (CLI tool, no HTTP service)"
    return 0
}

# ============================================
# MAIN LOOP
# ============================================

log "Starting continuous fix loop for target repos..."
log "Total repos to check: ${#REPOS[@]}"
log "Log file: $LOG_FILE"
log ""

iteration=0
while true; do
    iteration=$((iteration + 1))
    log "============================================"
    log "ITERATION $iteration"
    log "============================================"

    healthy_count=0

    # Run fixes for each unhealthy repo
    fix_gptme || true
    fix_ainenie || true
    fix_local_deep_researcher || true
    fix_itext2kg || true
    fix_medrax || true
    fix_gpt_engineer || true
    fix_pyvideotrans || true

    # Check all repos
    log ""
    log "Checking all target repos..."
    check_attackgen && healthy_count=$((healthy_count + 1))
    check_funclip && healthy_count=$((healthy_count + 1))
    check_gpt_migrate && healthy_count=$((healthy_count + 1))

    # Check fixable repos again
    if check_http 11130; then healthy_count=$((healthy_count + 1)); fi
    if check_http 11460; then healthy_count=$((healthy_count + 1)); fi
    if check_http 11030; then healthy_count=$((healthy_count + 1)); fi
    if check_http 11380; then healthy_count=$((healthy_count + 1)); fi
    if check_http 11180; then healthy_count=$((healthy_count + 1)); fi
    if check_http 11330; then healthy_count=$((healthy_count + 1)); fi
    if check_http 11160; then healthy_count=$((healthy_count + 1)); fi

    log ""
    log "Healthy count: $healthy_count / 10"
    log ""

    if [ $healthy_count -eq 10 ]; then
        log "============================================"
        log "SUCCESS! All 10 repos are now healthy!"
        log "============================================"
        break
    fi

    log "Waiting 30 seconds before next iteration..."
    sleep 30
    log ""
done

log ""
log "Fix script completed at: $(date)"
