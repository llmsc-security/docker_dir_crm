FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY custom_components ./custom_components/
COPY http_server.py .

# Create data directory
RUN mkdir -p /app/data

# Create non-root user
RUN groupadd -r home_llm && \
    useradd -r -g home_llm -u 1000 -m -d /home/home_llm home_llm && \
    chown -R home_llm:home_llm /app

USER home_llm

EXPOSE 11310
ENV PYTHONUNBUFFERED=1
CMD ["python", "http_server.py"]
