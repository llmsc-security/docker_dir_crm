#!/bin/bash
# Tutorial PoC script for IBM--zshot
# This script demonstrates Zshot usage via Docker

set -e

echo "=============================================="
echo "  IBM Zshot Tutorial PoC - Docker Demo"
echo "=============================================="
echo ""

# Configuration
PORT=11200
CONTAINER_NAME="IBM--zshot"
REPO_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/IBM--zshot"
IMAGE_NAME="IBM--zshot:latest"

print_section() {
    echo ""
    echo "=============================================="
    echo "  $1"
    echo "=============================================="
}

# Step 1: Check Docker
print_section "Step 1: Docker Environment Check"
if command -v docker &> /dev/null; then
    echo "[OK] Docker is installed"
    docker --version
else
    echo "[ERROR] Docker is not installed"
    exit 1
fi

# Step 2: Verify repository
print_section "Step 2: Repository Verification"
if [ -d "$REPO_DIR" ]; then
    echo "[OK] Repository directory exists: $REPO_DIR"
    echo "Contents:"
    ls -la "$REPO_DIR"
else
    echo "[ERROR] Repository directory not found: $REPO_DIR"
    exit 1
fi

# Step 3: Show existing Docker artifacts
print_section "Step 3: Existing Docker Artifacts"
echo "Dockerfile location: $REPO_DIR/Dockerfile"
if [ -f "$REPO_DIR/Dockerfile" ]; then
    echo "[OK] Dockerfile found"
    head -20 "$REPO_DIR/Dockerfile"
else
    echo "[WARNING] Dockerfile not found"
fi

echo ""
echo "Entry point location: $REPO_DIR/entrypoint.sh"
if [ -f "$REPO_DIR/entrypoint.sh" ]; then
    echo "[OK] entrypoint.sh found"
fi

# Step 4: Show Zshot features
print_section "Step 4: Zshot Features Overview"

cat << 'FEATURES'
Zshot is a Zero-Shot Named Entity Recognition framework from IBM.

Key Features:
1. Mentions Extraction
   - SMXM: Zero-shot NERC using language description
   - TARS: Few-shot learning with TARS model
   - GLiNER: Generalist model for NER
   - Spacy-based extractors
   - Flair-based extractors

2. Linkers
   - Blink: Wikification using Blink
   - GENRE: Entity linking with GENRE
   - SMXM: Zero-shot NERC
   - TARS: End-to-end linking
   - GLiNER: Generalist NER model
   - RELIK: Knowledge extraction

3. Relations Extraction
   - ZS-Bert: Zero-shot relation extraction

4. Knowledge Extractor
   - KnowGL: Knowledge graph extraction
   - Relik: Joint entity and relation extraction

5. Visualization
   - spaCy displaCy integration
   - Interactive entity highlighting
   - Serves on port 5000
FEATURES

# Step 5: Docker Usage Examples
print_section "Step 5: Docker Usage Examples"

cat << 'DOCKER_EXAMPLES'
# Build the Docker image
cd /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/IBM--zshot
docker build -t IBM--zshot:latest .

# Start container with invoke script
/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/IBM--zshot/invoke_IBM--zshot.sh start

# Or manually run
docker run -d \\
    --name IBM--zshot \\
    -p 11200:5000 \\
    -v /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/IBM--zshot:/zshot:ro \\
    IBM--zshot:latest

# View logs
docker logs -f IBM--zshot

# Execute command inside container
docker exec -it IBM--zshot python -c "import spacy; nlp = spacy.load('en'); print('OK')"

# Stop container
docker stop IBM--zshot
DOCKER_EXAMPLES

# Step 6: Python API Example
print_section "Step 6: Python API Example"

cat << 'PYTHON_EXAMPLE'
import spacy
from zshot import PipelineConfig, displacy
from zshot.linker import LinkerRegen
from zshot.mentions_extractor import MentionsExtractorSpacy
from zshot.utils.data_models import Entity

# Load spaCy model
nlp = spacy.load("en_core_web_sm")

# Configure Zshot pipeline
nlp_config = PipelineConfig(
    mentions_extractor=MentionsExtractorSpacy(),
    linker=LinkerRegen(),
    entities=[
        Entity(
            name="IBM",
            description="International Business Machines Corporation (IBM) is an American multinational technology corporation"
        ),
        Entity(
            name="Paris",
            description="Paris is located in northern central France, in a north-bending arc of the river Seine"
        ),
        Entity(
            name="New York",
            description="New York is a city in U.S. state"
        ),
    ]
)

# Add Zshot to the pipeline
nlp.add_pipe("zshot", config=nlp_config, last=True)

# Process text
text = "International Business Machines Corporation (IBM) is an American multinational technology corporation headquartered in Armonk, New York."

doc = nlp(text)

# View detected entities
print("Detected entities:")
for ent in doc.ents:
    print(f"  - {ent.text} ({ent.label_})")

# Visualize with displaCy (serves on http://0.0.0.0:5000)
displacy.serve(doc, style="ent")
PYTHON_EXAMPLE

# Step 7: Summary
print_section "Step 7: Summary"

cat << 'SUMMARY'
Quick Start Checklist:
[ ] Docker installed and running
[ ] Repository cloned: /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/IBM--zshot
[ ] Docker image built: docker build -t IBM--zshot:latest .
[ ] Container started with invoke script or manual docker run
[ ] Access visualization at http://localhost:11200

For more information:
- Documentation: https://ibm.github.io/zshot/
- Source Code: https://github.com/IBM/zshot
- Paper: https://aclanthology.org/2023.acl-demo.34/
SUMMARY

echo ""
echo "=============================================="
echo "  Tutorial Complete!"
echo "=============================================="
echo ""
echo "Run the invoke script to start:"
echo "  /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/IBM--zshot/invoke_IBM--zshot.sh start"
echo ""
