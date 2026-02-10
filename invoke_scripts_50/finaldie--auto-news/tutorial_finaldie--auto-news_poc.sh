#!/bin/bash
# Tutorial PoC script for Auto-News
# Usage: ./tutorial_finaldie--auto-news_poc.sh

set -e

echo "============================================================"
echo "  Auto-News (finaldie--auto-news) Tutorial PoC"
echo "  Repository: https://github.com/llmsc-security/finaldie--auto-news"
echo "============================================================"
echo ""

REPO_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/finaldie--auto-news"
PORT=11190

# Function to print section header
print_section() {
    echo ""
    echo "============================================================"
    echo "  $1"
    echo "============================================================"
    echo ""
}

# Step 1: Check Docker availability
print_section "Step 1: Checking Docker Availability"
if command -v docker &> /dev/null; then
    echo "Docker is installed: $(docker --version)"
    docker ps &> /dev/null && echo "Docker daemon is running" || { echo "ERROR: Docker daemon is not running"; exit 1; }
else
    echo "ERROR: Docker is not installed"
    exit 1
fi

# Step 2: Navigate to repo directory
print_section "Step 2: Navigating to Repository"
if [ -d "$REPO_DIR" ]; then
    echo "Repository found at: $REPO_DIR"
    cd "$REPO_DIR"
else
    echo "ERROR: Repository not found at $REPO_DIR"
    exit 1
fi

# Step 3: Check existing Docker artifacts
print_section "Step 3: Checking Docker Artifacts"
echo "Existing Docker files:"
ls -la "$REPO_DIR/Dockerfile" 2>/dev/null && echo "  - Dockerfile found"
ls -la "$REPO_DIR/docker-compose.yaml" 2>/dev/null && echo "  - docker-compose.yaml found"
ls -la "$REPO_DIR/docker-compose-deploy.yml" 2>/dev/null && echo "  - docker-compose-deploy.yml found"
ls -la "$REPO_DIR/entrypoint.sh" 2>/dev/null && echo "  - entrypoint.sh found"
ls -la "$REPO_DIR/entry_point.sh" 2>/dev/null && echo "  - entry_point.sh found"

# Step 4: Display service port information
print_section "Step 4: Service Port Configuration"
echo "Host Port: $PORT"
echo "Container Port: 8080 (Airflow webserver)"
echo "Port mapping: $PORT:8080"
echo ""
echo "This port is from port_mapping_50_gap10_3.json"
echo "Port range: 11190-11200"

# Step 5: Display available scripts
print_section "Step 5: Available Scripts"
echo "Invoke script: /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/invoke_finaldie--auto-news.sh"
echo "Tutorial PoC: $0"

# Step 6: Display usage examples
print_section "Step 6: Usage Examples"

cat << 'USAGE'
# Start the Auto-News container
/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/invoke_finaldie--auto-news.sh start

# Stop the container
/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/invoke_finaldie--auto-news.sh stop

# View logs
/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/invoke_finaldie--auto-news.sh logs

# Execute command in container
/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/invoke_finaldie--auto-news.sh exec airflow dags list

# Build the Docker image
cd /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/finaldie--auto-news
docker build -t auto-news:latest .

# Start with docker-compose
docker-compose up -d

# Access the Airflow web UI
open http://localhost:11190
USAGE

# Step 7: Display feature overview
print_section "Step 7: Auto-News Features"

cat << 'FEATURES'
Auto-News provides:

1. CONTENT AGGREGATION
   - RSS feed monitoring
   - Reddit post fetching
   - Twitter/X tweet collection
   - YouTube video processing

2. CONTENT PROCESSING
   - Article summarization using LLM
   - Insight generation
   - Content filtering
   - Duplicate detection

3. MULTIMODAL SUPPORT
   - Video transcript extraction
   - Video recap generation
   - Web article parsing

4. REPORTING
   - Weekly top-k recap
   - Daily insights summary
   - Notion-based integration

5. TASK AUTOMATION
   - Scheduled content collection
   - Automated insight generation
   - TODO list creation
   - Journal note organization

LLM BACKENDS SUPPORTED:
- OpenAI ChatGPT
- Google Gemini
- Ollama
FEATURES

# Step 8: Quick Start Summary
print_section "Step 8: Quick Start Summary"

cat << 'QUICKSTART'
1. PREREQUISITES
   - Docker installed and running
   - API keys for LLM provider (OpenAI/Anthropic/Gemini/Ollama)

2. CONFIGURATION
   cd /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/finaldie--auto-news
   cp .env.template .env
   # Edit .env with your API keys

3. BUILD IMAGE
   docker build -t auto-news:latest .

4. START CONTAINER
   /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/invoke_finaldie--auto-news.sh start

5. ACCESS APPLICATION
   Open http://localhost:11190 in your browser
   Default credentials: admin / admin
QUICKSTART

# Step 9: Verify invocation script
print_section "Step 9: Invocation Script Verification"
if [ -f "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/invoke_finaldie--auto-news.sh" ]; then
    echo "Invocation script exists"
    echo "Location: /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/invoke_finaldie--auto-news.sh"
    echo "Permissions: $(ls -l /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/invoke_finaldie--auto-news.sh | awk '{print $1}')"
else
    echo "ERROR: Invocation script not found"
fi

# Step 10: Tutorial POC Script Verification
print_section "Step 10: Tutorial POC Script"
if [ -f "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/tutorial_finaldie--auto-news_poc.sh" ]; then
    echo "Tutorial POC script exists"
    echo "Location: /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/tutorial_finaldie--auto-news_poc.sh"
else
    echo "ERROR: Tutorial POC script not found"
fi

echo ""
echo "============================================================"
echo "  Tutorial POC Complete!"
echo "============================================================"
echo ""
echo "For more information, visit:"
echo "  https://github.com/llmsc-security/finaldie--auto-news"
echo "  https://github.com/finaldie/auto-news/wiki"
echo ""
