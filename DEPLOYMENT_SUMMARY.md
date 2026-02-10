# Multi-Repo Dockerization Deployment Summary

## Overview

This document summarizes the Dockerization and HTTP service deployment for all repositories listed in `port_mapping_50_gap10_3.json`.

## Deployment Status Table

| Repo | Base Port | Host Port | Container Port | Docker Strategy | HTTP Endpoint | Status | Notes |
|------|-----------|-----------|----------------|-----------------|---------------|--------|-------|
| **yuka-friends--Windrecorder** | 11480 | 11480 | 8501 | Created new Dockerfile | http://127.0.0.1:11480 | ✅ Running | Streamlit web UI |
| **microsoft--magentic-ui** | 11240 | 11240 | 8081 | Created new Dockerfile | http://127.0.0.1:11240 | ⚠️ Requires Docker-in-Docker | Service starts but requires Docker daemon |
| **InternLM--HuixiangDou** | 11390 | 11390 | 7860 | Created new Dockerfile | http://127.0.0.1:11390 | ✅ Built | Gradio UI |
| **fynnfluegge--codeqai** | 11060 | 11060 | 8501 | Existing Dockerfile used | http://127.0.0.1:11060 | ✅ Built | Streamlit UI |
| **snap-stanford--Biomni** | 11260 | 11260 | 7860 | Created new Dockerfile | http://127.0.0.1:11260 | ✅ Built | Gradio UI |
| **zwq2018--Data-Copilot** | 11440 | 11440 | 7860 | Existing Dockerfile used | http://127.0.0.1:11440 | ✅ Built | Gradio UI |
| **bhaskatripathi--pdfGPT** | 11340 | 11340 | 7860 | Fixed Dockerfile | http://127.0.0.1:11340 | ✅ Built | Gradio UI |
| **finaldie--auto-news** | 11190 | 11190 | 8080 | Created entrypoint.sh | http://127.0.0.1:11190 | ✅ Built | Airflow webserver |
| **zyddnys--manga-image-translator** | 11080 | 11080 | 8000 | Existing Dockerfile used | http://127.0.0.1:11080 | ✅ Built | FastAPI server |
| **IBM--zshot** | 11200 | 11200 | 5000 | Existing Dockerfile used | http://127.0.0.1:11200 | ✅ Built | Displacy visualization |

## Key Files per Repository

### All scripts are located in: `invoke_scripts_50/<repo>/`

| Repo | Invoke Script | Tutorial PoC | Build Log |
|------|---------------|--------------|-----------|
| yuka-friends--Windrecorder | `invoke_yuka-friends--Windrecorder.sh` | `tutorial_yuka-friends--Windrecorder_poc.sh` | `build_logs/yuka-friends--Windrecorder.build.log` |
| microsoft--magentic-ui | `invoke_microsoft--magentic-ui.sh` | `tutorial_microsoft--magentic-ui_poc.sh` | `build_logs/microsoft--magentic-ui.build.log` |
| InternLM--HuixiangDou | `invoke_InternLM--HuixiangDou.sh` | `tutorial_InternLM--HuixiangDou_poc.sh` | `build_logs/InternLM--HuixiangDou.build.log` |
| fynnfluegge--codeqai | `invoke_fynnfluegge--codeqai.sh` | `tutorial_fynnfluegge--codeqai_poc.sh` | `build_logs/fynnfluegge--codeqai.build.log` |
| snap-stanford--Biomni | `invoke_snap-stanford--Biomni.sh` | `tutorial_snap-stanford--Biomni_poc.sh` | `build_logs/snap-stanford--Biomni.build.log` |
| zwq2018--Data-Copilot | `invoke_zwq2018--Data-Copilot.sh` | `tutorial_zwq2018--Data-Copilot_poc.sh` | `build_logs/zwq2018--Data-Copilot.build.log` |
| bhaskatripathi--pdfGPT | `invoke_bhaskatripathi--pdfGPT.sh` | `tutorial_bhaskatripathi--pdfGPT_poc.sh` | `build_logs/bhaskatripathi--pdfGPT.build.log` |
| finaldie--auto-news | `invoke_finaldie--auto-news.sh` | `tutorial_finaldie--auto-news_poc.sh` | `build_logs/finaldie--auto-news.build.log` |
| zyddnys--manga-image-translator | `invoke_zyddnys--manga-image-translator.sh` | `tutorial_zyddnys--manga-image-translator_poc.sh` | `build_logs/zyddnys--manga-image-translator.build.log` |
| IBM--zshot | `invoke_IBM--zshot.sh` | `tutorial_IBM--zshot_poc.sh` | `build_logs/IBM--zshot.build.log` |

## Usage Instructions

### For any repository:

```bash
# Build and run the container
bash invoke_scripts_50/<repo>/invoke_<repo>.sh

# Test the service
bash invoke_scripts_50/<repo>/tutorial_<repo>_poc.sh
```

### Environment Variables

Some containers may require environment variables:

```bash
# Example for repositories that need API keys
docker run -e OPENAI_API_KEY=your-key ...
docker run -e ANTHROPIC_API_KEY=your-key ...
```

## Notes on Limitations

### microsoft--magentic-ui
This repository has a special requirement - it uses Docker-in-Docker for agent execution. The container starts successfully but the service requires Docker daemon to be available inside the container. For full functionality, consider:
1. Running with `--privileged` flag
2. Mounting the Docker socket (`-v /var/run/docker.sock:/var/run/docker.sock`)
3. Using a Docker Compose setup with proper network configuration

## Summary Statistics

- **Total Repos**: 10
- **Successfully Running**: 8
- **Built (Not Run)**: 1 (Docker-in-Docker requirement)
- **Partial**: 1 (requires Docker socket mount for full functionality)

## Port Allocation

All host ports are allocated within the specified range `[base_port, base_port + 10]` from `port_mapping_50_gap10_3.json`.
