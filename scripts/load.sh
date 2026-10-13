#!/usr/bin/env bash
# Generate traffic so the Grafana panels have data.  Usage: scripts/load.sh http://localhost:8000 [seconds]
BASE="${1:-http://localhost:8000}"
END=$(( $(date +%s) + ${2:-120} ))
while [ "$(date +%s)" -lt "$END" ]; do
  curl -s -o /dev/null -X POST -H 'Content-Type: application/json' -d '{"title":"load test"}' "$BASE/api/tasks"
  curl -s -o /dev/null "$BASE/api/tasks"
  curl -s -o /dev/null "$BASE/api/slow"
  [ $((RANDOM % 5)) -eq 0 ] && curl -s -o /dev/null "$BASE/api/error"
  sleep 0.2
done
echo "done"
