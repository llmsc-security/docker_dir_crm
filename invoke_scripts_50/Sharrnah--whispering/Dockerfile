# Multi-stage Dockerfile for Whispering Tiger
# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /build

# Install system dependencies for building Python packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        python3-dev \
        libssl-dev \
        libffi-dev \
        libportaudio2 \
        libportaudiocpp0 \
        portaudio19-dev \
        libasound2-dev \
        libpulse-dev \
        libsdl2-dev \
        libswscale-ffmpeg5 \
        libavcodec-ffmpeg58 \
        libavformat-ffmpeg58 \
        libavutil-ffmpeg56 \
        libswresample-ffmpeg3 \
        libavfilter-ffmpeg7 \
        libavdevice-ffmpeg58 \
        cmake \
        pkg-config \
        && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements first for caching
COPY requirements.txt .

# Install Python dependencies with Chinese mirror
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

# Copy application source
COPY . .

# Pre-download models to avoid runtime issues
RUN python downloader.py --quiet 2>/dev/null || true

# Stage 2: Runtime
FROM python:3.11-slim

ARG APP_UID=1000
ARG APP_GID=1000

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gcc \
        libssl-dev \
        libffi-dev \
        libportaudio2 \
        libportaudiocpp0 \
        libasound2 \
        libpulse0 \
        libswscale5 \
        libavcodec58 \
        libavformat58 \
        libavutil56 \
        libswresample3 \
        libavfilter7 \
        libavdevice58 \
        && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --gid ${APP_GID} appuser 2>/dev/null || true && \
    useradd --uid ${APP_UID} --gid ${APP_GID} -ms /bin/bash appuser 2>/dev/null || true

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

# Copy application source
COPY --chown=appuser:appuser . .

# Create necessary directories
RUN mkdir -p /app/.cache/nltk/tokenizers && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose WebSocket port
EXPOSE 8765

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl --fail http://localhost:8765/ || exit 1

# Entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
