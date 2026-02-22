# HTTP Verification Report for 10 Repositories

**Generated:** 2026-02-22
**Port Mapping:** port_mapping_50_gap10_1.json

## Summary

| Status | Count | Repositories |
|--------|-------|--------------|
| ✅ PASS | 7 | mrwadams--attackgen, gptme--gptme, langchain-ai--local-deep-researcher, AuvaLab--itext2kg, bowang-lab--MedRAX, modelscope--FunClip, NEKOparapa--AiNiee |
| ❌ FAIL (Not Web Services) | 3 | AntonOsika--gpt-engineer, joshpxyne--gpt-migrate, jianchang512--pyvideotrans |

## Detailed Results

### ✅ PASS - HTTP Services Working

| Repository | Port | Type | Endpoint | Notes |
|------------|------|------|----------|-------|
| mrwadams--attackgen | 11110 | Streamlit | / | Working |
| gptme--gptme | 11130 | API Server | / | Working |
| langchain-ai--local-deep-researcher | 11030 | LangGraph | / | Working |
| AuvaLab--itext2kg | 11380 | FastAPI | /health, /docs | Working |
| bowang-lab--MedRAX | 11180 | Gradio | / | Working |
| modelscope--FunClip | 11430 | Web App | / | Working |
| NEKOparapa--AiNiee | 11460 | Qt GUI (HTTP API) | /api/status | HTTP API enabled via Dockerfile patch |

### ❌ FAIL - Not Web Services (Expected)

These applications are fundamentally NOT web services and cannot be verified via HTTP:

| Repository | Port | Type | Reason |
|------------|------|------|--------|
| AntonOsika--gpt-engineer | 11330 | CLI Tool | Typer-based CLI, not a web server |
| joshpxyne--gpt-migrate | 11470 | CLI Tool | Code migration CLI tool |
| jianchang512--pyvideotrans | 11160 | Qt GUI | Video translation GUI app (Xvfb headless) |

## Dockerfile Modifications

### NEKOparapa--AiNiee
- Added `entrypoint.sh` that enables HTTP API server at runtime
- Configures `http_server_enable: true` and `http_listen_address: 0.0.0.0:3388`
- Exposes port 3388 for HTTP API access
- API endpoints: `/api/translate`, `/api/stop`, `/api/status`

### AuvaLab--itext2kg
- No modifications needed - FastAPI server working out of the box
- Endpoints: `/health`, `/docs`, `/openapi.json`

### langchain-ai--local-deep-researcher
- Multi-stage Dockerfile with uv tool isolation
- Installs langchain-ollama in tool environment
- Working on port 11030 (container port 2024)

## Verification Commands

```bash
# Run full verification
bash invoke_scripts_50/verify_all_10_repos.sh

# Test individual endpoints
curl -f http://localhost:11110/  # attackgen
curl -f http://localhost:11130/  # gptme
curl -f http://localhost:11030/  # local-deep-researcher
curl -f http://localhost:11380/health  # itext2kg
curl -f http://localhost:11180/  # MedRAX
curl -f http://localhost:11430/  # FunClip
curl -f http://localhost:11460/api/status  # AiNiee
```

## Conclusion

**7 out of 10 repositories** are successfully running HTTP services that can be verified via POC scripts.

**3 out of 10** are CLI/GUI applications that do not expose HTTP endpoints by design - these cannot be tested via HTTP verification as requested.
