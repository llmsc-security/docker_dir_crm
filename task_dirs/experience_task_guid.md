# Experience-Based Guidance for Multi-Repo Dockerization Tasks

This document captures lessons learned from building and running 50+ repositories with Docker, distilled from the actual deployment process. Use this as your operational checklist when working with new repos.

---

## Critical Success Factors

### 1. Port Selection Strategy

**Rule**: Always use the EXACT port from your_port.json  - do NOT use base_port + 10 unless necessary.

| Repo | Base Port | Actual Host Port Used | Container Port |
|------|-----------|----------------------|----------------|
| shibing624--pycorrector | 11000 | 11000 | 5001 |
| mrwadams--stride-gpt | 11040 | 11040 | 8501 |
| fynnfluegge--codeqai | 11060 | 11060 | 8501 |
| Integuru-AI--Integuru | 11070 | 11070 | 11070 |
| zyddnys--manga-image-translator | 11080 | 11080 | 8000 |
| adithya-s-k--omniparse | 11090 | 11090 | 8000 |
| stitionai--devika | 11100 | 11100 | 11100 |
| mrwadams--attackgen | 11110 | 11110 | 8500 |
| assafelovic--gpt-researcher | 11250 | 11250 | 8000 |
| binary-husky--gpt_academic | 11270 | 11270 | 8000 |
| microsoft--TaskWeaver | 11280 | 11280 | 8000 |
| microsoft--RD-Agent | 11290 | 11290 | 8000 |
| shroominic--codeinterpreter-api | 11300 | 11300 | 8501 |
| acon96--home-llm | 11310 | 11310 | 8000 |
| Paper2Poster--Paper2Poster | 11320 | 11320 | 7860 |
| AntonOsika--gpt-engineer | 11330 | 11330 | 8000 |
| TauricResearch--TradingAgents | 11360 | 11360 | 11360 |
| barun-saha--slide-deck-ai | 11410 | 11410 | 8501 |
| yihong0618--bilingual_book_maker | 11450 | 11450 | 7860 |
| yuka-friends--Windrecorder | 11480 | 11480 | 8501 |

**Key Insight**: Most Streamlit apps use port 8501, Gradio apps use port 8000. Check the app's default before assigning.

---

### 2. Dockerfile Patterns That Work

#### Pattern A: Streamlit Application (Most Common)
```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies first
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source
COPY . .

# Streamlit apps typically run on 8501
EXPOSE 8501

# Important: Use absolute paths in entry_point.sh
ENTRYPOINT ["python", "-m", "streamlit", "run", "00_👋_Welcome.py", "--server.port=8501", "--server.address=0.0.0.0"]
```

#### Pattern B: Gradio Application
```dockerfile
FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Gradio typically uses 7860 or 8000
EXPOSE 8000

CMD ["python", "app.py"]
```

#### Pattern C: FastAPI/Application with Custom Port
```dockerfile
FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Match the port the app actually uses
EXPOSE 11070

CMD ["python", "main.py"]
```

---

### 3. entry_point.sh Template

```bash
#!/bin/bash
set -e

# Always use absolute paths
cd /path/to/app

# Log startup
echo "Starting service..."
echo "Current time: $(date)"
echo "Working directory: $(pwd)"

# Start the actual service
exec python -m streamlit run app.py --server.port=8501 --server.address=0.0.0.0
```

**Critical**:
1. Use `set -e` to fail fast on errors
2. Use `exec` to replace the shell process (proper signal handling)
3. Use absolute paths - containers don't inherit host cwd

---

### 4.invoke Script Template

```bash
#!/bin/bash
set -e

# Absolute paths for reproducibility
REPO_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/xxx"
INVOKE_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/xxx"
LOG_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs"
IMAGE_NAME="xxx_image"
CONTAINER_NAME="xxx_container"
HOST_PORT=11000
CONTAINER_PORT=8501

mkdir -p "$INVOKE_DIR"
mkdir -p "$LOG_DIR"

echo "=== Building $IMAGE_NAME ===" | tee "$INVOKE_DIR/invoke.log"
docker build "$REPO_DIR" -t "$IMAGE_NAME" 2>&1 | tee -a "$INVOKE_DIR/invoke.log"

echo "=== Stopping existing container ===" | tee -a "$INVOKE_DIR/invoke.log"
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

echo "=== Starting new container ===" | tee -a "$INVOKE_DIR/invoke.log"
docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$HOST_PORT:$CONTAINER_PORT" \
    -v "${REPO_DIR}:/app" \
    "$IMAGE_NAME" 2>&1 | tee -a "$INVOKE_DIR/invoke.log"

echo "=== Verifying service ===" | tee -a "$INVOKE_DIR/invoke.log"
curl -f "http://127.0.0.1:$HOST_PORT/" || echo "Service not ready yet"
```

---

### 5. Testing Strategy

**Three-tier verification**:

1. **Container Health**:
```bash
docker ps | grep "xxx_container"
docker inspect --format='{{.State.Status}}' xxx_container
```

2. **Port Binding**:
```bash
docker port xxx_container
# Should show: 8501/tcp -> 0.0.0.0:11000
```

3. **HTTP Response**:
```bash
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:11000/
# 200 = success
# 404 = may be OK (expected path)
# 000 = connection failed
```

---

### 6. Common Failure Modes and Fixes

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| Container exits immediately | No long-running process in CMD/ENTRYPOINT | Use `streamlit run` or `python -m uvicorn` with `--host 0.0.0.0` |
| Port already in use | Wrong port mapping or previous container not removed | Use `docker rm -f` before new run |
| Connection refused | App not listening on 0.0.0.0 | Add `--server.address=0.0.0.0` to command |
| 404 on root | App uses different entry point | Test `/health`, `/api`, or check app docs |
| Build fails on requirements | Missing system dependencies | Add `RUN apt-get install -y build-essential` before pip |

---

### 7. Working Repos Checklist

**For each repo, verify these artifacts exist**:

```
repo_dirs/<repo>/
├── Dockerfile                    (required)
├── entry_point.sh                (required)
├── docker-compose.yml (optional) (if using compose)
├── requirements.txt              (required for Python)
└── README.md                     (reference for port/entry)

invoke_scripts_50/<repo>/
├── invoke_<repo>.sh              (required)
├── tutorial_<repo>_poc.sh        (required)
├── invoke.log                    (generated)
└── tutorial_poc.log              (generated)
```

---

### 8. Port Mapping Reference (All 50 Repos)

```
11000: shibing624--pycorrector
11010: Sharrnah--whispering
11020: yuruotong1--autoMate
11030: langchain-ai--local-deep-researcher
11040: mrwadams--stride-gpt
11050: AbanteAI--rawdog
11060: fynnfluegge--codeqai
11070: Integuru-AI--Integuru
11080: zyddnys--manga-image-translator
11090: adithya-s-k--omniparse
11100: stitionai--devika
11110: mrwadams--attackgen
11120: ur-whitelab--chemcrow-public
11130: gptme--gptme
11140: vintasoftware--django-ai-assistant
11150: plasma-umass--ChatDBG
11160: jianchang512--pyvideotrans
11170: linyqh--NarratoAI
11180: bowang-lab--MedRAX
11190: finaldie--auto-news
11200: IBM--zshot
11210: OpenDCAI--DataFlow
11220: chenfei-wu--TaskMatrix
11230: reworkd--AgentGPT
11240: microsoft--magentic-ui
11250: assafelovic--gpt-researcher
11260: snap-stanford--Biomni
11270: binary-husky--gpt_academic
11280: microsoft--TaskWeaver
11290: microsoft--RD-Agent
11300: shroominic--codeinterpreter-api
11310: acon96--home-llm
11320: Paper2Poster--Paper2Poster
11330: AntonOsika--gpt-engineer
11340: bhaskatripathi--pdfGPT
11350: PromtEngineer--localGPT
11360: TauricResearch--TradingAgents
11370: 666ghj--BettaFish
11380: AuvaLab--itext2kg
11390: InternLM--HuixiangDou
11400: SWE-agent--SWE-agent
11410: barun-saha--slide-deck-ai
11420: Fosowl--agenticSeek
11430: modelscope--FunClip
11440: zwq2018--Data-Copilot
11450: yihong0618--bilingual_book_maker
11460: NEKOparapa--AiNiee
11470: joshpxyne--gpt-migrate
11480: yuka-friends--Windrecorder
```

---

### 9. LLM API Integration Pattern

```python
import os

# Always use os.environ.get() - never hardcode
model = os.environ.get("GPT_MODEL", "gpt-5.1")
base_url = os.environ.get("OPENAI_API_BASE_URL", "http://157.10.162.82:443/v1/")
api_key = os.environ.get("OPENAI_API_KEY")

from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    model=model,
    temperature=1,
    base_url=base_url,
    api_key=api_key,
)
```

---

### 10. Final Validation Steps

Before declaring a repo "complete":

```bash
# 1. Verify container is running
docker ps | grep "container_name"

# 2. Verify port binding
docker port container_name | grep "base_port"

# 3. Test HTTP endpoint
curl -s -o /tmp/status.txt http://127.0.0.1:base_port/
cat /tmp/status.txt  # Should show meaningful response

# 4. Verify log files exist
ls -la invoke_scripts_50/repo_name/
# Should show: invoke.log, tutorial_poc.log

# 5. Verify scripts are executable
ls -la invoke_scripts_50/repo_name/*.sh
# Should have -rwxr-xr-x permissions
```

---

### 11. Known Working Ports by Framework

| Framework | Default Port | Container Flag | Host Port Range |
|-----------|-------------|----------------|-----------------|
| Streamlit | 8501 | `--server.port=8501` | Any (mapped via -p) |
| Gradio | 7860 | N/A (configured in app) | Any (mapped via -p) |
| FastAPI | 8000 | `--host 0.0.0.0 --port 8000` | Any (mapped via -p) |
| Flask | 5000 | `host='0.0.0.0', port=5000` | Any (mapped via -p) |
| Custom | Varies | Check app code | Match to base_port |

---

### 12. Docker Optimization Tips

1. **Build Cache**: Always `COPY requirements.txt` first, then `pip install`
2. **Layer Reduction**: Combine apt-get update and install in single RUN
3. **Cleanup**: Remove apt lists after install: `rm -rf /var/lib/apt/lists/*`
4. **Smaller Images**: Use `python:3.10-slim` instead of full python image

---

## Summary

The key to successful multi-repo Dockerization:

1. **Consistency**: Use the same pattern across all repos
2. **Automation**: Scripts must work from any directory
3. **Logging**: Capture all output for debugging
4. **Validation**: Always test HTTP endpoints after deployment
5. **Documentation**: Update README with Docker instructions

Follow this guide, and you'll avoid 95% of common issues.

using the follow when need the openai API , OPENAI_API_KEY="11" OPENAI_API_BASE_URL="http://157.10.162.82:443/v1/" GPT_MODEL="gpt-5.1"
 
