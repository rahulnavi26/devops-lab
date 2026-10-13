"""Tiny task-list API used as the demo workload for the DevOps lab."""
import os
import random
import threading
import time

from flask import Flask, Response, g, jsonify, request
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    Counter,
    Gauge,
    Histogram,
    generate_latest,
)

app = Flask(__name__)

VERSION = os.getenv("APP_VERSION", "dev")

REQUESTS = Counter(
    "http_requests_total", "Total HTTP requests", ["method", "endpoint", "status"]
)
LATENCY = Histogram(
    "http_request_duration_seconds", "HTTP request latency in seconds", ["endpoint"]
)
TASK_COUNT = Gauge("tasks_total", "Number of tasks currently stored")
APP_INFO = Gauge("app_info", "Application version", ["version"])
APP_INFO.labels(version=VERSION).set(1)

_tasks = {}
_next_id = 1
_lock = threading.Lock()


@app.before_request
def _start_timer():
    g.start = time.perf_counter()


@app.after_request
def _record_metrics(response):
    endpoint = request.url_rule.rule if request.url_rule else "unmatched"
    if endpoint != "/metrics":
        LATENCY.labels(endpoint).observe(time.perf_counter() - g.start)
        REQUESTS.labels(request.method, endpoint, response.status_code).inc()
    return response


@app.get("/")
def index():
    return jsonify(
        service="devops-lab",
        version=VERSION,
        endpoints=["/health", "/api/tasks", "/api/slow", "/api/error", "/metrics"],
    )


@app.get("/health")
def health():
    return jsonify(status="healthy", version=VERSION)


@app.get("/api/tasks")
def list_tasks():
    with _lock:
        return jsonify(list(_tasks.values()))


@app.post("/api/tasks")
def create_task():
    global _next_id
    data = request.get_json(silent=True) or {}
    title = str(data.get("title", "")).strip()
    if not title or len(title) > 200:
        return jsonify(error="title is required (max 200 characters)"), 400
    with _lock:
        task = {"id": _next_id, "title": title, "done": False}
        _tasks[_next_id] = task
        _next_id += 1
        TASK_COUNT.set(len(_tasks))
    return jsonify(task), 201


@app.delete("/api/tasks/<int:task_id>")
def delete_task(task_id):
    with _lock:
        if task_id not in _tasks:
            return jsonify(error="task not found"), 404
        del _tasks[task_id]
        TASK_COUNT.set(len(_tasks))
    return "", 204


@app.get("/api/slow")
def slow():
    """Adds artificial latency so the latency panel has something to show."""
    ms = min(request.args.get("ms", default=random.randint(100, 800), type=int), 2000)
    time.sleep(max(ms, 0) / 1000)
    return jsonify(slept_ms=ms)


@app.get("/api/error")
def error():
    """Always fails, to practise with the error-rate panel and alert."""
    return jsonify(error="simulated failure"), 500


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
