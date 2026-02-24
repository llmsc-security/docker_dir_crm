#!/bin/bash
# Fix container and image naming to follow convention:
# - Containers should end with _container
# - Images should end with _image

set -e

echo "=== Stopping and removing containers without _container suffix ==="

# List of containers that need renaming (stop and remove, will recreate)
containers_to_fix=(
    "auvalab--itext2kg"
    "jianchang512--pyvideotrans"
)

for container in "${containers_to_fix[@]}"; do
    echo "Processing $container..."
    docker stop "$container" 2>/dev/null || true
    docker rm "$container" 2>/dev/null || true
done

echo ""
echo "=== Cleaning up stray images ==="

# Remove stray images that don't follow naming convention
stray_images=(
    "medrax:AntonOsika--gpt-engineer"
    "medrax:mrwadams--attackgen"
    "medrax:modelscope--FunClip"
    "medrax:joshpxyne--gpt-migrate"
    "medrax:gptme--gptme"
    "langchain-ai:local-deep-researcher_image"
    "langchain_ai:local_deep_researcher_image"
    "jianchang512_pyvideotrans_image"
    "joshpxyne_gpt-migrate_image"
)

for image in "${stray_images[@]}"; do
    echo "Removing stray image: $image"
    docker rmi "$image" 2>/dev/null || true
done

echo ""
echo "=== Cleanup complete ==="
echo "Containers will be recreated with proper _container suffix when invoke scripts are run"
