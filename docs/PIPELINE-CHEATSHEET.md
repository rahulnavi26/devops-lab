# Pipeline cheat-sheet

All three CI tools run the same six scripts in this order:

| Step | Script | What it does | Fails when |
|---|---|---|---|
| 1 | `scripts/ci/test.sh` | pytest + coverage | a test fails or coverage < 80% |
| 2 | `scripts/ci/sonar.sh` | SonarQube analysis, waits for quality gate | gate fails (skipped if no server configured) |
| 3 | `scripts/ci/build.sh` | `docker build`, tag = short git SHA | build error |
| 4 | `scripts/ci/scan.sh` | Trivy image scan | fixable HIGH/CRITICAL vulnerability |
| 5 | `scripts/ci/push.sh` | login + push to ECR / ACR / Docker Hub | auth or network error |
| 6 | `scripts/ci/deploy.sh` | Ansible: pull secret, `kubectl apply`, wait for rollout, smoke test | rollout not ready in 180 s |

Environment variables the scripts read: `CLOUD` (aws|azure|dockerhub), `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `ACR_LOGIN_SERVER`, `ACR_USERNAME`, `ACR_PASSWORD`, `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `SONAR_HOST_URL`, `SONAR_TOKEN`, `DEPLOY_HOST`, `SSH_KEY_FILE`.

You can run any step from your laptop, e.g. `CLOUD=aws AWS_REGION=ap-south-1 scripts/ci/push.sh`. If a pipeline step fails, reproduce it locally first.

| Concept | GitHub Actions | Jenkins | Azure Pipelines |
|---|---|---|---|
| Pipeline file | `.github/workflows/ci-cd.yml` | `Jenkinsfile` | `azure-pipelines.yml` |
| Secrets | repo secrets / variables | Credentials store | variable group + secure files |
| Manual approval | environment reviewers | `input` step | environment checks |
| Runs on | GitHub-hosted runner | your Jenkins container | Microsoft-hosted agent |
