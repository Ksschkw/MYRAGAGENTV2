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

# Set environment variables - Groq provider (env var names are UPPERCASE, not camelCase)
ENV PROVIDER=groq
ENV GROQ_API_KEY=$[GROQ_API_KEY]
ENV DEFAULT_MODEL=openai/gpt-oss-20b
ENV FALLBACK_MODELS=qwen/qwen3.6-27b,groq/compound-mini
ENV VECTOR_STORE_TYPE=hybrid_offline
ENV CACHE_DIR=/tmp

# Create a non-root user to run the application
RUN useradd --create-home --shell /bin/bash appuser
USER appuser

# Command to run the application
# Secret files will be mounted by Northflank at /run/secrets/
# Clear the cache directory to force kssarg to rebuild the b2s5s index from the latest secrets, then start the server
CMD ["/bin/bash", "-c", "rm -rf /tmp/* && python -m kssrag.cil server --host 0.0.0.0 --file /run/secrets/info.txt --system-run/secrets/custom_prompt.txt --port 8000 --vector-store-bms25"]
