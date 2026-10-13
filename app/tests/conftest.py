import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import main  # noqa: E402


@pytest.fixture(autouse=True)
def clean_state():
    main._tasks.clear()
    main._next_id = 1
    main.TASK_COUNT.set(0)
    yield


@pytest.fixture
def client():
    return main.app.test_client()
