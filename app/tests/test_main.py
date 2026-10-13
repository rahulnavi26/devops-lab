def test_index(client):
    body = client.get("/").get_json()
    assert body["service"] == "devops-lab"


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json()["status"] == "healthy"


def test_create_and_list_task(client):
    created = client.post("/api/tasks", json={"title": "learn terraform"})
    assert created.status_code == 201
    tasks = client.get("/api/tasks").get_json()
    assert [t["title"] for t in tasks] == ["learn terraform"]


def test_title_is_required(client):
    assert client.post("/api/tasks", json={"title": "  "}).status_code == 400
    assert client.post("/api/tasks", data="not json").status_code == 400


def test_title_too_long(client):
    assert client.post("/api/tasks", json={"title": "x" * 201}).status_code == 400


def test_delete_task(client):
    task_id = client.post("/api/tasks", json={"title": "temp"}).get_json()["id"]
    assert client.delete(f"/api/tasks/{task_id}").status_code == 204
    assert client.delete(f"/api/tasks/{task_id}").status_code == 404


def test_slow_endpoint_is_capped(client):
    assert client.get("/api/slow?ms=1").get_json()["slept_ms"] == 1


def test_error_endpoint(client):
    assert client.get("/api/error").status_code == 500


def test_metrics_exposed(client):
    client.get("/health")
    text = client.get("/metrics").get_data(as_text=True)
    assert "http_requests_total" in text
    assert "tasks_total" in text
