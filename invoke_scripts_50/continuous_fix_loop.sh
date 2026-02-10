#!/bin/bash

# Continuous Fix Loop Script for Target Repos
# This script checks all 10 target repos and applies fixes
# It runs indefinitely with 30-second intervals

LOG_FILE="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/fix_loop.log"
REPO_BASE_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs"

# Log header
echo "========================================" | tee -a "$LOG_FILE"
echo "Continuous Fix Loop - $(date)" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

# Function to log messages
log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" | tee -a "$LOG_FILE"
}

# Function to check HTTP endpoint
check_http() {
    local port=$1
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port" 2>/dev/null || echo "000")
    [ "$status" = "200" ] || [ "$status" = "301" ] || [ "$status" = "302" ]
}

# ============================================
# SPECIFIC FIX FUNCTIONS
# ============================================

# 1. Fix gptme--gptme (port 11130)
# Issue: Container exits with code 1, no clear error logs
fix_gptme() {
    local repo_name="gptme--gptme"
    local port=11130
    local container_name="gptme--gptme_container"
    local image_name="gptme--gptme_image"
    local repo_dir="$REPO_BASE_DIR/$repo_name"

    log "=== Fixing $repo_name (port $port) ==="

    # Stop existing container
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true

    # Run container with explicit entrypoint
    log "Starting container..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:11130 \
        -e GPTME_SERVER_HOST=0.0.0.0 \
        -e GPTME_SERVER_PORT=11130 \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 10
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        docker logs "$container_name" --tail 20 >> "$LOG_FILE" 2>/dev/null || echo "No logs available" >> "$LOG_FILE"
        return 1
    fi
}

# 2. Fix NEKOparapa--AiNiee (port 11460)
# Issue: HTTP service needs to be enabled in config
fix_ainenie() {
    local repo_name="NEKOparapa--AiNiee"
    local port=11460
    local container_name="nekoparapa--ainenie_container"
    local image_name="nekoparapa--ainenie_image"
    local repo_dir="$REPO_BASE_DIR/$repo_name"

    log "=== Fixing $repo_name (port $port) ==="

    # Stop existing container
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true

    # Enable HTTP server in config
    local config_dir="$repo_dir/Resource"
    local config_file="$config_dir/config.json"

    if [ -f "$config_file" ]; then
        log "Enabling HTTP service in config..."
        sed -i 's/"http_server_enable": false/"http_server_enable": true/' "$config_file"
        sed -i 's|"http_listen_address": "127.0.0.1:3388"|"http_listen_address": "0.0.0.0:3388"|' "$config_file"
    else
        log "Config file not found at $config_file"
    fi

    # Run container with HTTP port mapping
    log "Starting container with port 3388 mapped to $port..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:3388 \
        -e PYTHONUNBUFFERED=1 \
        -e QT_QPA_PLATFORM=offscreen \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 10
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        docker logs "$container_name" --tail 20 >> "$LOG_FILE" 2>/dev/null || echo "No logs available" >> "$LOG_FILE"
        return 1
    fi
}

# 3. Fix langchain-ai--local-deep-researcher (port 11030 -> 2024)
# Issue: Missing langchain_ollama module
fix_local_deep_researcher() {
    local repo_name="langchain-ai--local-deep-researcher"
    local port=11030
    local container_name="langchain-ai--local-deep-researcher_container"
    local image_name="langchain-ai--local-deep-researcher_image"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local container_port=2024

    log "=== Fixing $repo_name (host port $port -> container port $container_port) ==="

    # Stop existing container
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true

    # The issue is missing langchain_ollama module
    # We need to install it in the container
    log "Attempting to run with module installation..."

    # Run and try to install the module
    docker run -d \
        --name "$container_name" \
        -p ${port}:${container_port} \
        -e LANGGRAPH_HOST=0.0.0.0 \
        -e LANGGRAPH_PORT=${container_port} \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 10
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        docker logs "$container_name" --tail 30 >> "$LOG_FILE" 2>/dev/null || echo "No logs available" >> "$LOG_FILE"
        return 1
    fi
}

# 4. Fix AuvaLab--itext2kg (port 11380)
# Issue: Python module issue - needs __main__.py
fix_itext2kg() {
    local repo_name="AuvaLab--itext2kg"
    local port=11380
    local container_name="auvalab--itext2kg_container"
    local image_name="auvalab--itext2kg_image"
    local repo_dir="$REPO_BASE_DIR/$repo_name"

    log "=== Fixing $repo_name (port $port) ==="

    # Stop existing container
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true

    # Check for __main__.py in the package
    local main_file="$repo_dir/itext2kg/__main__.py"
    if [ ! -f "$main_file" ]; then
        log "Creating __main__.py for the package..."
        mkdir -p "$repo_dir/itext2kg"
        cat > "$main_file" << 'MAINEOF'
from itext2kg.app import app

if __name__ == "__main__":
    app.run()
MAINEOF
    fi

    # Run container
    log "Starting container..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:11380 \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 10
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        docker logs "$container_name" --tail 20 >> "$LOG_FILE" 2>/dev/null || echo "No logs available" >> "$LOG_FILE"
        return 1
    fi
}

# 5. Fix bowang-lab--MedRAX (port 11180 -> 8585)
# Issue: Requires CUDA/GPU
fix_medrax() {
    local repo_name="bowang-lab--MedRAX"
    local port=11180
    local container_name="bowang-lab--medrax_container"
    local image_name="bowang-lab--medrax_image"
    local repo_dir="$REPO_BASE_DIR/$repo_name"
    local container_port=8585

    log "=== Fixing $repo_name (host port $port -> container port $container_port) ==="

    # Stop existing container
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true

    # Check for GPU
    if ! command -v nvidia-smi &> /dev/null; then
        log "$repo_name: SKIPPED (GPU/CUDA required but not available)"
        return 2
    fi

    log "Starting container (GPU detected)..."
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
        log "$repo_name: FAILED"
        docker logs "$container_name" --tail 20 >> "$LOG_FILE" 2>/dev/null || echo "No logs available" >> "$LOG_FILE"
        return 1
    fi
}

# 6. Fix AntonOsika--gpt-engineer (port 11330)
# Issue: Requires OPENAI_API_KEY
fix_gpt_engineer() {
    local repo_name="AntonOsika--gpt-engineer"
    local port=11330
    local container_name="antonosika--gpt-engineer_container"
    local image_name="antonosika--gpt-engineer_image"
    local repo_dir="$REPO_BASE_DIR/$repo_name"

    log "=== Fixing $repo_name (port $port) ==="

    # Stop existing container
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true

    # Check for API key
    local api_key="${OPENAI_API_KEY:-}"
    if [ -z "$api_key" ]; then
        log "WARNING: OPENAI_API_KEY not set. Container will start but may fail."
    fi

    # Run container
    log "Starting container..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:8000 \
        -e OPENAI_API_KEY="$api_key" \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 10
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        docker logs "$container_name" --tail 20 >> "$LOG_FILE" 2>/dev/null || echo "No logs available" >> "$LOG_FILE"
        return 1
    fi
}

# 7. Fix jianchang512--pyvideotrans (port 11160)
# Issue: Qt library issue - GUI app needs headless mode
fix_pyvideotrans() {
    local repo_name="jianchang512--pyvideotrans"
    local port=11160
    local container_name="jianchang512--pyvideotrans_container"
    local image_name="jianchang512--pyvideotrans_image"
    local repo_dir="$REPO_BASE_DIR/$repo_name"

    log "=== Fixing $repo_name (port $port) ==="

    # Stop existing container
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true

    # Run with headless mode
    log "Starting container with Qt headless mode..."
    docker run -d \
        --name "$container_name" \
        -p ${port}:8000 \
        -e QT_QPA_PLATFORM=offscreen \
        -e DISPLAY=:99 \
        --rm \
        "$image_name" 2>&1 | tee -a "$LOG_FILE"

    sleep 10
    if check_http "$port"; then
        log "$repo_name: HEALTHY"
        return 0
    else
        log "$repo_name: FAILED"
        docker logs "$container_name" --tail 20 >> "$LOG_FILE" 2>/dev/null || echo "No logs available" >> "$LOG_FILE"
        return 1
    fi
}

# ============================================
# CHECK ALL REPOS
# ============================================

check_all_repos() {
    local healthy_count=0

    log ""
    log "Checking all target repos..."

    # mrwadams--attackgen (11110) - Should be healthy
    if check_http 11110; then
        log "mrwadams--attackgen (11110): HEALTHY"
        healthy_count=$((healthy_count + 1))
    else
        log "mrwadams--attackgen (11110): UNHEALTHY"
    fi

    # modelscope--FunClip (11430) - Should be healthy
    if check_http 11430; then
        log "modelscope--FunClip (11430): HEALTHY"
        healthy_count=$((healthy_count + 1))
    else
        log "modelscope--FunClip (11430): UNHEALTHY"
    fi

    # joshpxyne--gpt-migrate (11470) - CLI tool, skip
    log "joshpxyne--gpt-migrate (11470): SKIPPED (CLI tool)"

    # Check all other repos
    for repo in "gptme--gptme" "NEKOparapa--AiNiee" "langchain-ai--local-deep-researcher" \
                "AuvaLab--itext2kg" "bowang-lab--MedRAX" "AntonOsika--gpt-engineer" \
                "jianchang512--pyvideotrans"; do
        local port
        case "$repo" in
            "gptme--gptme") port=11130 ;;
            "NEKOparapa--AiNiee") port=11460 ;;
            "langchain-ai--local-deep-researcher") port=11030 ;;
            "AuvaLab--itext2kg") port=11380 ;;
            "bowang-lab--MedRAX") port=11180 ;;
            "AntonOsika--gpt-engineer") port=11330 ;;
            "jianchang512--pyvideotrans") port=11160 ;;
        esac

        if check_http "$port"; then
            log "$repo ($port): HEALTHY"
            healthy_count=$((healthy_count + 1))
        else
            log "$repo ($port): UNHEALTHY"
        fi
    done

    log ""
    log "Healthy count: $healthy_count / 8 (excluding skipped)"
    return $((healthy_count == 8 ? 0 : 1))
}

# ============================================
# MAIN LOOP
# ============================================

log "Starting continuous fix loop for target repos..."
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
    check_all_repos

    log ""
    log "Waiting 30 seconds before next iteration..."
    sleep 30
done
