#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python3 -m venv .venv
# shellcheck disable=SC1091
. .venv/bin/activate
pip install --quiet -r app/requirements-dev.txt
mkdir -p reports
python -m pytest app/tests -v \
  --cov --cov-report=xml:coverage.xml --cov-report=term-missing \
  --cov-fail-under=80 --junitxml=reports/junit.xml
