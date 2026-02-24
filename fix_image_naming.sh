#!/bin/bash
# Fix image naming to follow convention: Images should end with _image (lowercase)

set -e

echo "=== Retagging images to follow _image convention (lowercase) ==="

# Array of old_name:new_name pairs (new names must be lowercase)
declare -A renames=(
    ["barun-saha--slide-deck-ai:latest"]="barun-saha-slide-deck-ai_image:latest"
    ["local-deep-researcher:latest"]="langchain-ai-local-deep-researcher_image:latest"
    ["snap-stanford-biomni-image:latest"]="snap-stanford-biomni_image:latest"
    ["tradingagents:latest"]="tauricresearch-tradingagents_image:latest"
    ["yihong0618--bilingual_book_maker:latest"]="yihong0618-bilingual-book-maker_image:latest"
    ["assafelovic-gpt-researcher:latest"]="assafelovic-gpt-researcher_image:latest"
    ["shroominic--codeinterpreter-api:latest"]="shroominic-codeinterpreter-api_image:latest"
    ["automate:latest"]="yuruotong1-automate_image:latest"
    ["dataflow:latest"]="opendcai-dataflow_image:latest"
    ["promtengineer-localgpt-image:latest"]="promtengineer-localgpt_image:latest"
    ["plasma-umass-chatdbg-image:latest"]="plasma-umass-chatdbg_image:latest"
    ["internlm-huixiangdou-image:latest"]="internlm-huixiangdou_image:latest"
    ["modelscope-funclip-image:latest"]="modelscope-funclip_image:latest"
    ["internlm-huixiangdou:latest"]="internlm-huixiangdou_image:latest"
    ["chenfei-wu-taskmatrix-image:latest"]="chenfei-wu-taskmatrix_image:latest"
    ["taskmatrix:latest"]="chenfei-wu-taskmatrix_image:latest"
    ["codeinterpreter-api-image:latest"]="shroominic-codeinterpreter-api_image:latest"
    ["gpt-researcher-image:latest"]="assafelovic-gpt-researcher_image:latest"
    ["swe-agent-image:latest"]="swe-agent-image:latest"
    ["django-ai-assistant-image:latest"]="vintasoftware-django-ai-assistant_image:latest"
    ["vintasoftware-django-ai-assistant-image:latest"]="vintasoftware-django-ai-assistant_image:latest"
    ["stride-gpt-image:latest"]="mrwadams-stride-gpt_image:latest"
    ["devika:latest"]="stitionai-devika_image:latest"
)

for old_name in "${!renames[@]}"; do
    new_name="${renames[$old_name]}"

    # Check if old image exists
    if docker image inspect "$old_name" &>/dev/null; then
        echo "Retagging: $old_name -> $new_name"
        docker tag "$old_name" "$new_name"

        # Remove old tag (not the image itself if it's the same)
        if [ "$old_name" != "$new_name" ]; then
            docker rmi "$old_name" 2>/dev/null || true
        fi
    else
        echo "SKIP (not found): $old_name"
    fi
done

echo ""
echo "=== Retagging complete ==="
