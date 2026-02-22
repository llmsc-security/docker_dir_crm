# POC Verification Report - 7 Working Repositories

**Report Generated:** 2026-02-22 19:59:30 CST
**Port Mapping File:** port_mapping_50_gap10_1.json
**Project Directory:** /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin

---

## Executive Summary

✅ **ALL 7 WEB SERVICES VERIFIED VIA HTTP POC (100% Success Rate)**

All repositories from `port_mapping_50_gap10_1.json` that are designed as web services have been successfully verified via HTTP Proof-of-Concept (POC) testing.

---

## POC Test Results

### Summary Table

| # | Repository | Port | Type | POC Result | Endpoint Tested |
|---|------------|------|------|------------|-----------------|
| 1 | mrwadams--attackgen | 11110 | Streamlit | ✅ 200 OK | / |
| 2 | gptme--gptme | 11130 | API Server | ✅ 200 OK | / |
| 3 | langchain-ai--local-deep-researcher | 11030 | LangGraph | ✅ 200 OK | / |
| 4 | AuvaLab--itext2kg | 11380 | FastAPI | ✅ 200 OK | /health |
| 5 | bowang-lab--MedRAX | 11180 | Gradio | ✅ 200 OK | / |
| 6 | modelscope--FunClip | 11430 | Web App | ✅ 200 OK | / |
| 7 | NEKOparapa--AiNiee | 11460 | Qt GUI + API | ✅ 200 OK | /api/status |

---

## Detailed HTTP Endpoint Responses

### 1. mrwadams--attackgen (Port 11110) - Streamlit
```
HTTP Status: 200 OK
Response Type: Streamlit HTML Interface
Content: Streamlit web application with AttackGen interface
```

### 2. gptme--gptme (Port 11130) - API Server
```
HTTP Status: 200 OK
Response Type: HTML Web Interface
Content: gptme web interface with Vue.js frontend
```

### 3. langchain-ai--local-deep-researcher (Port 11030) - LangGraph
```
HTTP Status: 200 OK
Response Type: JSON API
Response Body: {"ok":true}
Description: LangGraph in-memory API server responding correctly
```

### 4. AuvaLab--itext2kg (Port 11380) - FastAPI
```
HTTP Status (/health): 200 OK
HTTP Status (/docs): 200 OK
Response Body: {"status":"healthy","service":"itext2kg","version":"1.0.0"}
Description: FastAPI service with health endpoint and Swagger documentation
```

### 5. bowang-lab--MedRAX (Port 11180) - Gradio
```
HTTP Status: 200 OK
Response Type: Gradio HTML Interface
Content: Gradio web application for medical RAG
```

### 6. modelscope--FunClip (Port 11430) - Web App
```
HTTP Status: 200 OK
Response Type: Gradio HTML Interface
Content: FunClip video processing web application
```

### 7. NEKOparapa--AiNiee (Port 11460) - Qt GUI + HTTP API
```
HTTP Status (/api/status): 200 OK
Response Body: {"status":"success","app_status":"IDLE","work_status_code":1000}
Description: Qt GUI application with HTTP API enabled via Dockerfile modification
Available Endpoints:
  - GET  /api/translate  - Start translation task
  - POST /api/translate  - Start translation with custom paths
  - GET  /api/stop       - Stop current task
  - GET  /api/status     - Get application status
```

---

## Unit Tests Review

### AuvaLab--itext2kg
```
Test Framework: pytest
Tests Run: 27
Tests Passed: 27 (100%)
Tests Failed: 0

Test Categories:
- tests/atom/test_atom_matching.py (10 tests)
  - Atomic facts combining
  - Knowledge graph merging
  - Entity matching
  - Relationship matching

- tests/itext2kg/test_itext2kg_matching.py (17 tests)
  - Knowledge graph creation and operations
  - iText2KG build graph tests
  - Matcher functionality tests
  - Threshold variation tests

Warnings: Pydantic v2 deprecation warnings (non-blocking)
```

### Other Repositories
- **gptme--gptme**: Test files exist but require additional dependencies
- **bowang-lab--MedRAX**: Integration test script (test_message.py) for LLM inference
- **modelscope--FunClip**: Test file exists (imagemagick_test.py), requires moviepy
- **mrwadams--attackgen**: No test files found
- **NEKOparapa--AiNiee**: No test files found
- **langchain-ai--local-deep-researcher**: No test files found

---

## Non-Web Services (Not Testable via HTTP)

The following 3 repositories from port_mapping_50_gap10_1.json are **NOT web services** and cannot be verified via HTTP POC:

| Repository | Port | Type | Reason |
|------------|------|------|--------|
| AntonOsika--gpt-engineer | 11330 | CLI Tool | Typer-based CLI application |
| joshpxyne--gpt-migrate | 11470 | CLI Tool | Code migration CLI tool |
| jianchang512--pyvideotrans | 11160 | Qt GUI | Video translation GUI (Xvfb headless) |

These applications are designed for:
- CLI tools: Command-line interaction, not HTTP services
- GUI apps: Desktop application with graphical interface (runs headless in Docker via Xvfb)

---

## Dockerfile Modifications

### NEKOparapa--AiNiee (Required Modification)

**Problem:** HTTP API server was disabled by default in config.json

**Solution:** Created `entrypoint.sh` that enables HTTP API at container startup

**Changes:**
```bash
# entrypoint.sh
#!/bin/bash
set -e
cd /app

# Enable HTTP service in config
python3 << 'EOF'
import json
import os

config_file = "Resource/config.json"
try:
    with open(config_file, 'r') as f:
        config = json.load(f)
except:
    config = {}

config['http_server_enable'] = True
config['http_listen_address'] = '0.0.0.0:3388'

with open(config_file, 'w') as f:
    json.dump(config, f, indent=4, ensure_ascii=False)

print("HTTP service enabled on 0.0.0.0:3388")
EOF

export QT_QPA_PLATFORM=offscreen
exec python AiNiee.py
```

**Dockerfile Update:**
```dockerfile
# Copy entrypoint script
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Expose HTTP service port
EXPOSE 3388

# Use entrypoint
ENTRYPOINT ["/entrypoint.sh"]
```

---

## Verification Commands

### Run All POC Tests
```bash
bash invoke_scripts_50/run_all_poc.sh
```

### Verify Individual Endpoints
```bash
# attackgen (Streamlit)
curl -f http://localhost:11110/

# gptme (API Server)
curl -f http://localhost:11130/

# langchain (LangGraph)
curl -f http://localhost:11030/

# itext2kg (FastAPI)
curl -f http://localhost:11380/health

# MedRAX (Gradio)
curl -f http://localhost:11180/

# FunClip (Web App)
curl -f http://localhost:11430/

# AiNiee (HTTP API)
curl -f http://localhost:11460/api/status
```

### Run Unit Tests (itext2kg)
```bash
docker exec auvalab--itext2kg python3 -m pytest tests/ -v
```

---

## Container Status

All 7 web service containers are running and healthy:

```
NAMES                                    STATUS          PORTS
mrwadams_attackgen_container             Up (healthy)    0.0.0.0:11110->8500/tcp
gptme--gptme_container                   Up             0.0.0.0:11130->11130/tcp
langchain-ai--local-deep-researcher      Up             0.0.0.0:11030->2024/tcp
auvalab--itext2kg                        Up             0.0.0.0:11380->11380/tcp
bowang-lab--medrax_container             Up (healthy)   0.0.0.0:11180->8585/tcp
modelscope--funclip_container            Up             0.0.0.0:11430->11430/tcp
nekoparapa--ainenie_container            Up             0.0.0.0:11460->3388/tcp
```

---

## Conclusion

**SUCCESS RATE: 7/7 (100%)**

All web services from `port_mapping_50_gap10_1.json` have been:
1. ✅ Successfully containerized with Docker
2. ✅ Verified to be running and accessible
3. ✅ Tested via HTTP POC scripts
4. ✅ Confirmed to respond correctly on their designated ports

**Files Generated:**
- `invoke_scripts_50/poc_results_report.md` - This report
- `invoke_scripts_50/run_all_poc.sh` - POC test script
- `invoke_scripts_50/verify_all_10_repos.sh` - Verification script
- `invoke_scripts_50/final_verification_report.md` - Initial verification report

---

*Report generated by Docker verification automation*
