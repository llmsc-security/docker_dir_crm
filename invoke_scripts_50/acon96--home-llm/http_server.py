#!/usr/bin/env python3
"""
HTTP Server wrapper for home-llm
Provides a simple HTTP API for the Home LLM Home Assistant integration.
"""
import os
import sys
from pathlib import Path
from typing import Optional, Dict, Any
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import uvicorn
import requests

APP_DIR = Path(__file__).parent
sys.path.insert(0, str(APP_DIR))

app = FastAPI(
    title="Home LLM HTTP API",
    description="HTTP API wrapper for Home LLM (Home Assistant Integration)",
    version="1.0.0"
)

# Configuration
HTTP_PORT = int(os.environ.get("HTTP_PORT", 11310))
OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
HOME_ASSISTANT_URL = os.environ.get("HOME_ASSISTANT_URL", "http://localhost:8123")


class GenerateRequest(BaseModel):
    prompt: str
    model: Optional[str] = "llama3"
    stream: Optional[bool] = False


@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "service": "home_llm",
        "version": "1.0.0",
        "description": "Home LLM HTTP API wrapper",
        "endpoints": {
            "/": "This info page",
            "/health": "Health check",
            "/api/generate": "Generate text from prompt",
            "/api/models": "List available models"
        }
    }


@app.get("/health")
async def health():
    """Health check endpoint."""
    health_status = {"status": "healthy", "ollama": False, "home_assistant": False}

    # Check Ollama
    try:
        response = requests.get(f"{OLLAMA_URL}/api/health", timeout=5)
        health_status["ollama"] = response.status_code == 200
    except Exception:
        pass

    # Check Home Assistant
    try:
        response = requests.get(f"{HOME_ASSISTANT_URL}/", timeout=5)
        health_status["home_assistant"] = response.status_code in [200, 401]
    except Exception:
        pass

    return health_status


@app.get("/api/models")
async def list_models():
    """List available Ollama models."""
    try:
        response = requests.get(f"{OLLAMA_URL}/api/tags", timeout=10)
        if response.status_code == 200:
            return response.json()
        else:
            raise HTTPException(status_code=response.status_code, detail="Failed to fetch models")
    except requests.exceptions.ConnectionError:
        raise HTTPException(status_code=503, detail="Ollama server not available")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/generate")
async def generate(req: GenerateRequest):
    """Generate text using Ollama."""
    try:
        response = requests.post(
            f"{OLLAMA_URL}/api/generate",
            json={
                "model": req.model,
                "prompt": req.prompt,
                "stream": req.stream
            },
            timeout=60
        )
        if response.status_code == 200:
            return response.json()
        else:
            raise HTTPException(status_code=response.status_code, detail=response.text)
    except requests.exceptions.ConnectionError:
        raise HTTPException(status_code=503, detail="Ollama server not available")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/status")
async def status():
    """Get service status."""
    return {
        "service": "home_llm",
        "status": "running",
        "http_port": HTTP_PORT,
        "ollama_url": OLLAMA_URL,
        "home_assistant_url": HOME_ASSISTANT_URL
    }


if __name__ == "__main__":
    print(f"Starting Home LLM HTTP server on port {HTTP_PORT}...")
    print(f"Ollama backend: {OLLAMA_URL}")
    print(f"Home Assistant: {HOME_ASSISTANT_URL}")
    uvicorn.run("http_server:app", host="0.0.0.0", port=HTTP_PORT, log_level="info")
