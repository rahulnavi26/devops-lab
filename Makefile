.PHONY: test run up down tools load

test:        ## run unit tests with coverage
	scripts/ci/test.sh

run:         ## run the app directly (needs: pip install -r app/requirements.txt)
	cd app && python main.py

up:          ## app + Prometheus + Grafana locally
	docker compose up --build -d
	@echo "App http://localhost:8000  Prometheus http://localhost:9090  Grafana http://localhost:3000 (admin/admin)"

down:
	docker compose down

tools:       ## Jenkins (8080) + SonarQube (9000)
	cd tools && docker compose up -d --build

load:        ## generate traffic for the dashboards
	scripts/load.sh http://localhost:8000 120
