FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy and install requirements to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && rm -rf /root/.cache/pip

# Set environment variable
ENV OPENROUTER_API_KEY=${OPENROUTER_API_KEY}

# Command to run the application
# Secret files will be mounted by Northflank at /run/secrets/
CMD ["python", "-m", "kssrag.cli", "server", "--host", "0.0.0.0", "--file", "/run/secrets/info.txt", "--system-prompt", "/run/secrets/custom_prompt.txt", "--port", "8000"]