FROM python:3.12-alpine
ARG APP_VERSION=dev
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 APP_VERSION=${APP_VERSION}
WORKDIR /app

RUN apk upgrade --no-cache \
    && addgroup -S -g 10001 app \
    && adduser -S -D -H -u 10001 -G app app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

USER 10001:10001
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)"

# One worker: tasks and Prometheus counters live in process memory.
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "1", "--threads", "4", "--worker-tmp-dir", "/dev/shm", "main:app"]
