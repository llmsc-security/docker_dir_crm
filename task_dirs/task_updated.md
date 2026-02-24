# Multi-Repo Dockerization + HTTP Service + Automation + Standardized Logging

## Objective

For **every repository** listed in `port_mapping_50_gap10.json`, make the repo **buildable and runnable via Docker (or Docker Compose)**, ensure it exposes a **long-running HTTP service** reachable from the host on an assigned port range, and generate **two automation scripts** per repo under `invoke_scripts_50/<repo>/` with **complete stdout/stderr logging**, plus a **central build log** under `build_logs/`.

> **No interaction required.** You are authorized to execute, install, verify, and test as needed.
> **Final deliverable:** a **table** reporting results for **all repos** in the port mapping JSON.

---

## Scope & Inputs

### Repository layout

* Each repo lives at:
  * `repo_dirs/<org>--<repo_name>`
* Repo identifier format:
  * `<repo>` = `<org>--<repo_name>` (e.g., `camel-ai--owl`)
* `<repo_dir>` = absolute path of `repo_dirs/<repo>`

### Port allocation

* Port mapping file:
  * `port_mapping_50_gap10.json`
* It maps `<repo>` → `<base_port>` (integer)
* Allowed published host ports for that repo:
  * `<host_port>` must be in **[base_port, base_port + 10]** (inclusive; exactly 11 ports)

### Logging locations

* Per-repo script logs (must be created/updated by scripts):
  * `invoke_scripts_50/<repo>/invoke.log`
  * `invoke_scripts_50/<repo>/tutorial_poc.log`
* Central build log (global convention):
  * `build_logs/<repo>.build.log`

### Python venv (informational)

* If needed by tooling:
  * `/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/depoy_auto/.venv/bin/activate`

---

## Definitions

* `<container_port>`: port the service listens on inside the container
* `<host_port>`: selected port within `[base_port, base_port + 10]`
* Service must be reachable at:
  * `http://127.0.0.1:<host_port>/...`

---

## Mandatory Requirements (Per Repo)

### 1) Git Remote Rewrite (Optional; **do not push**)

If applicable, update `origin` remote:

* From: existing remote (e.g., `given_repo/<repo>` or equivalent)
* To: `llmsc-security/<repo>`

**Acceptance**

* `git remote -v` shows `origin` pointing to `llmsc-security/<repo>` for fetch/push.

---

### 2) Discover Existing Docker Artifacts and Decide Applicability

Recursively search `<repo_dir>` for:

* `Dockerfile`
* `docker-compose.yml`
* `docker-compose.yaml`

For each candidate, classify as:

* **Root-service Docker config (usable)**, or
* **Subproject-only Docker config (not usable for root deployment)**

**Required heuristics**

* Inspect context around the candidate path and parents:
  * `README.md` (local and repo root)
  * dependency descriptors (`pyproject.toml`, `requirements.txt`, `setup.py`, `package.json`, etc.)
* Determine whether the folder is:
  * the **primary runnable application/service**, or
  * an example/benchmark/secondary project

**Rule example**

* If `folder_B/README.md` indicates `folder_B` is a benchmark/example, then `folder_B/Dockerfile` must **not** be used for root deployment.

**If no valid root Docker setup exists**

* Create **repo-root** `./Dockerfile` (and Compose only if needed), based on:
  * root `README.md` run/install instructions
  * dependency descriptors
* You may leverage useful build hints from:
  * `.container/`, `.github/workflows/`, etc.

**Acceptance**

* A clear decision is documented and applied:
  * "use existing root Docker setup" OR "create new root Dockerfile"
* Subproject Dockerfiles are not mistakenly used.

---

### 3) Build–Fix–Run Loop Until HTTP Works

Iterate until:

* image builds successfully
* container runs successfully
* HTTP endpoint responds from host on the correct port

**Loop**

1. Build:
   * `docker build …` or `docker compose build`
2. If build fails:
   * identify root cause
   * modify Dockerfile and/or repo files (deps, entrypoint, paths, commands)
   * rebuild
3. Run:
   * `docker run …` or `docker compose up`
4. If runtime fails:
   * diagnose crash/missing env/command issues
   * fix and rerun

---

### 3.1 Port Publishing (Strict)

* Choose `<host_port>` within:
  * `[base_port, base_port + 10]`
* Map host→container:
  * `<host_port>:<container_port>`
* Do **not** publish ports outside that range.

---

### 3.2 Naming Conventions (Strict)

**IMPORTANT: All container and image names MUST follow this convention**

* Docker image name:
  * `<repo>_image` (e.g., `shibing624--pycorrector_image:latest`)
* Docker container name:
  * `<repo>_container` (e.g., `shibing624--pycorrector_container`)

**Acceptance**

* `docker images` shows `<repo>_image`
* container runs as `<repo>_container`
* host can reach `127.0.0.1:<host_port>` (within allocated range)

**Note on image naming:**
- Image names must be **lowercase** to comply with Docker naming requirements
- Example: `shibing624-pycorrector_image:latest` (lowercase with underscores)

---

### 4) `entry_point.sh` Must Launch a Long-Running HTTP Service

Ensure container startup runs an HTTP server and does **not** exit immediately.

**Requirements**

* Provide/update `repo_dirs/<repo>/entry_point.sh` (or equivalent entry mechanism)
* If multiple modes exist (e.g., CLI vs. UI):
  * prefer **Gradio** mode as the served HTTP UI/API
* If the repo has no HTTP service:
  * wrap/adapt CLI with a simple HTTP layer (minimal viable server)

**Acceptance**

* container remains running
* HTTP requests return valid responses

---

### 5) Create PoC Script: `tutorial_<repo>_poc.sh`

A runnable proof-of-concept script that calls the deployed service.

**Requirements**

* Path:
  * `invoke_scripts_50/<repo>/tutorial_<repo>_poc.sh`
* Uses `curl` to call:
  * `http://127.0.0.1:<host_port>/...`
* Must match the real endpoint and payload (no placeholders)

**Acceptance**

* With container running, script returns meaningful output without manual edits

---

### 6) Create Automation Script: `invoke_<repo>.sh`

One script to build and (re)run reliably and idempotently.

**Requirements**

* Path:
  * `invoke_scripts_50/<repo>/invoke_<repo>.sh`
* Must:
  1. Build `<repo>_image`
  2. Stop/remove existing `<repo>_container` if present
  3. Run a new `<repo>_container` with correct port mapping derived from JSON
* Must be safe to run multiple times

**Acceptance**

* Running it results in:
  * a running `<repo>_container`
  * correct host port mapping in range
  * reachable HTTP service

---

### 7) Absolute Path Rules (Strict)

Both scripts must:

* use **absolute paths** for:
  * `<repo_dir>`
  * log file targets
* not rely on caller working directory

**Acceptance**

* scripts work when run from any directory

---

### 8) Logging Requirements (Strict)

#### 8.1 Per-repo script logs

* Capture **stdout + stderr** into:
  * `invoke_scripts_50/<repo>/invoke.log`
  * `invoke_scripts_50/<repo>/tutorial_poc.log`
* Choose one logging mode and apply consistently:
  * **overwrite** OR **append**
* Preserve correct exit codes even with redirection

#### 8.2 Central build log

* Also create/update:
  * `build_logs/<repo>.build.log`
* Intended to capture build output consistent with existing convention

**Acceptance**

* Running invoke script updates:
  * `invoke_scripts_50/<repo>/invoke.log`
  * `build_logs/<repo>.build.log`
* Running tutorial script updates:
  * `invoke_scripts_50/<repo>/tutorial_poc.log`

---

## Docker Optimization (Recommended)

Where feasible, optimize builds by mapping dependency caches, e.g.:

* pip cache / poetry cache mounts during build (BuildKit) or runtime caches when appropriate
  (Implement only if it does not break reproducibility.)

---

## Required Output Artifacts (Per Repo)

| Artifact                     | Required Location                                               |
| ---------------------------- | --------------------------------------------------------------- |
| Dockerfile                   | `repo_dirs/<org>--<repo>/Dockerfile`                            |
| entry_point.sh               | `repo_dirs/<org>--<repo>/entry_point.sh`                        |
| docker-compose.yml (if used) | `repo_dirs/<org>--<repo>/docker-compose.yml`                    |
| invoke script                | `invoke_scripts_50/<org>--<repo>/invoke_<org>--<repo>.sh`       |
| tutorial PoC                 | `invoke_scripts_50/<org>--<repo>/tutorial_<org>--<repo>_poc.sh` |

---

## Final Deliverable: One Table Covering All Repos in `port_mapping_50_gap10.json`

Provide a single consolidated table with **one row per repo**, including at least:

* `<repo>`
* `<base_port>` from JSON
* chosen `<host_port>` (must be within base..base+10)
* `<container_port>`
* Docker strategy (existing root Dockerfile / created new / compose)
* HTTP endpoint tested (path + method)
* PoC script result (success/failure + brief output snippet)
* Invoke script result (success/failure)
* Log files created (paths)
* Notes (any required env vars, special steps, known limitations)

You should complete **all repos** listed in the JSON—no partials in random shuffle order.

---

## LLM API Configuration

For any LLM API call, configure the following environment variables:

* `OPENAI_API_KEY` — your API key
* `OPENAI_API_BASE_URL` — the API base URL
* `GPT_MODEL` — the model name

Example values:

```bash
export OPENAI_API_KEY="11"
export OPENAI_API_BASE_URL="http://157.10.162.82:443/v1/"
export GPT_MODEL="gpt-5.1"
```

> Make sure **all three** are set: `OPENAI_API_KEY`, `OPENAI_API_BASE_URL`, and `GPT_MODEL`.

---

## Example (LangChain)

```python
import os
from langchain_openai import ChatOpenAI

model = os.environ.get("GPT_MODEL", "gpt-5.1")
base_url = os.environ.get("OPENAI_API_BASE_URL", "http://157.10.162.82:443/v1/")
api_key = os.environ.get("OPENAI_API_KEY")

llm = ChatOpenAI(
    model=model,
    temperature=1,
    base_url=base_url,
    api_key=api_key,
)
```

**Notes**

* Use `os.environ.get(...)` (not `os.env.get(...)`).
* `api_key` should come from `OPENAI_API_KEY` (not `OPENAI_API_BASE_URL`).

---

## Lessons Learned & Best Practices

### Container Naming Convention

**CRITICAL:** All containers MUST use the `_container` suffix and images MUST use `_image` suffix.

```bash
# Correct naming:
docker run -d --name shibing624--pycorrector_container -p 11000:5001 shibing624--pycorrector_image:latest

# Image naming (lowercase required by Docker):
docker build -t shibing624-pycorrector_image:latest .
```

### Common Issues & Solutions

#### 1. Container Exits Immediately

**Symptom:** Container exits with code 0 or 1 right after start

**Causes:**
- CLI tool without HTTP server mode
- Missing required environment variables (e.g., `OPENAI_API_KEY`)
- Missing configuration files

**Solutions:**
- Wrap CLI with simple HTTP server (Flask/FastAPI)
- Add required environment variables to docker run command
- Create default configuration files

#### 2. Port Mapping Issues

**Symptom:** Container running but HTTP connection refused

**Causes:**
- Container port doesn't match host port mapping
- Service listening on wrong port inside container

**Solutions:**
- Verify container listens on expected port
- Use matching port mapping: `-p <host_port>:<container_port>`
- Check entry_point.sh sets correct PORT environment variable

#### 3. Build Failures - Dependency Issues

**Symptom:** Docker build fails with package dependency errors

**Common causes:**
- Google Chrome installation conflicts (common in Ubuntu-based images)
- Python package version conflicts
- Missing system libraries

**Solutions:**
- Use alternative package installation methods
- Pin specific working versions
- Use multi-stage builds to isolate dependencies

#### 4. Connection Reset / No Response

**Symptom:** HTTP returns "connection reset by peer"

**Causes:**
- Service needs GPU for hardware acceleration
- Service takes too long to start
- Memory/CPU resource constraints

**Solutions:**
- Add GPU support if needed (`--gpus all`)
- Increase startup timeout
- Add health checks with appropriate start period

### HTTP Service Verification

Use this pattern to verify all containers:

```bash
# Quick HTTP check for all ports
for port in 11000 11020 11030 ...; do
    response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "http://127.0.0.1:$port/")
    echo "Port $port: HTTP $response"
done
```

### POC Script Best Practices

1. **Use absolute paths** - scripts may be run from any directory
2. **Include logging** - capture stdout/stderr to log files
3. **Handle container state** - check if running before testing
4. **Test actual functionality** - not just HTTP 200, but meaningful responses

### Automated Testing

Create reusable test scripts:

```bash
# invoke_scripts_50/run_http_poc_test.sh
#!/bin/bash
for port in <all_ports>; do
    curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:$port/"
done
```

### Documentation

Maintain comprehensive reports:
- `FINAL_POC_REPORT.md` - Test results for all containers
- `CONTAINER_NAMING_REPORT.md` - Naming convention compliance
- `final_deliverable_table.md` - Summary table with all repos

---

## Existing Infrastructure Reuse

**IMPORTANT:** Before starting work, check if containers already exist:

```bash
# Check existing containers
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check if container naming follows convention
docker ps --format "{{.Names}}" | grep -v "_container"

# Check existing images
docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "_image"
```

If containers exist and are working:
1. Verify naming convention compliance
2. Test HTTP endpoints
3. Only rebuild/fix if necessary

---

## Known Issues Summary (From Previous Work)

| Repository | Issue | Status |
|------------|-------|--------|
| plasma-umass--ChatDBG | CLI debugger - no HTTP interface | Expected behavior |
| jianchang512--pyvideotrans | Video processing - needs GPU | Requires GPU |
| AntonOsika--gpt-engineer | Needs OPENAI_API_KEY | Requires config |
| joshpxyne--gpt-migrate | CLI tool - exits after start | Expected behavior |
| Fosowl--agenticSeek | Chrome dependency build failure | Needs Dockerfile fix |
| reworkd--AgentGPT | Next.js compilation errors | Running with warnings |
| vintasoftware--django-ai-assistant | Django config needed | Running with 500 |

---

## Final Status Tracking

After completing all work, update:
1. `final_deliverable_table.md` - Complete summary table
2. `FINAL_POC_REPORT.md` - Detailed test results
3. `CONTAINER_NAMING_REPORT.md` - Naming convention status
4. Commit all changes to git

```bash
git add .
git commit -m "Complete Dockerization for all repos with HTTP verification"
git push origin main
```
