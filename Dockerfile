FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy and install requirements to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && rm -rf /root/.cache/pip

# Copy application code
COPY . .

# Set environment variables
ENV OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
ENV VECTOR_STORE_TYPE=hybrid_offline  # Force hybrid_offline in Docker
ENV CACHE_DIR=/tmp  # Use tmp directory for cache

# Create a non-root user to run the application
RUN useradd --create-home --shell /bin/bash appuser
USER appuser

# Command to run the application
# Secret files will be mounted by Northflank at /run/secrets/
CMD ["python", "-m", "kssrag.cli", "server", "--host", "0.0.0.0", "--file", "/run/secrets/info.txt", "--system-prompt", "/run/secrets/custom_prompt.txt", "--port", "8000", "--vector-store", "hybrid_offline"]