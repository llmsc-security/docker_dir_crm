#!/bin/bash
# Recreate containers with proper naming convention and correct image references

set -e

cd /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin

echo "=== Stopping containers without _container suffix ==="

# Containers to recreate (without _container suffix)
containers=(
    "shroominic--codeinterpreter-api"
    "yihong0618--bilingual_book_maker"
    "barun-saha--slide-deck-ai_container"
    "snap-stanford-biomni_container"
    "TauricResearch--TradingAgents_container"
    "assafelovic--gpt-researcher_container"
    "autoMate"
    "linyqh--NarratoAI"
    "microsoft--TaskWeaver"
    "plasma-umass--ChatDBG"
    "InternLM--HuixiangDou_container"
    "zwq2018--Data-Copilot"
)

for container in "${containers[@]}"; do
    echo "Stopping $container..."
    docker stop "$container" 2>/dev/null || true
    docker rm "$container" 2>/dev/null || true
done

echo ""
echo "=== Containers stopped. Run invoke scripts to recreate ==="
echo "Note: Please run the invoke scripts manually to recreate containers"
