# Multistage Dockerfile for API service
# - small runtime image
# - use slim python, install only required packages

FROM python:3.11-slim AS build
WORKDIR /app

# Install build dependencies then install packages to /opt/venv
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

ENV VENV_PATH=/opt/venv
RUN python -m venv $VENV_PATH
ENV PATH="$VENV_PATH/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

COPY . /app

# Final minimal image
FROM python:3.11-slim
ENV VENV_PATH=/opt/venv
COPY --from=build $VENV_PATH $VENV_PATH
ENV PATH="$VENV_PATH/bin:$PATH"

WORKDIR /app
COPY --from=build /app /app

# Use non-root user
RUN addgroup --system app && adduser --system --ingroup app app
USER app

EXPOSE 8080
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8080", "app:app"]
