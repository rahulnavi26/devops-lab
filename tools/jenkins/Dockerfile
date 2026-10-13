FROM jenkins/jenkins:lts-jdk17
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
      docker.io python3 python3-venv python3-pip git curl unzip gettext-base openssh-client \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI + Ansible in an isolated virtualenv
RUN python3 -m venv /opt/venv && /opt/venv/bin/pip install --no-cache-dir awscli ansible-core
ENV PATH="/opt/venv/bin:${PATH}"

ARG SONAR_SCANNER_VERSION=6.2.1.4610
RUN curl -fsSL -o /tmp/scanner.zip "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux-x64.zip" \
    && unzip -q /tmp/scanner.zip -d /opt \
    && ln -s "/opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux-x64/bin/sonar-scanner" /usr/local/bin/sonar-scanner \
    && rm /tmp/scanner.zip

ARG TRIVY_VERSION=0.58.1
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin "v${TRIVY_VERSION}"

USER jenkins
