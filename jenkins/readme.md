# Hospitia Jenkins Setup Guide

This guide explains how to set up the Jenkins infrastructure used by the Hospitia project.

---

# Prerequisites

Before starting, ensure the following software is installed on the host machine:

- Docker
- Docker Compose

> **Note:** Any machine hosting Jenkins agent containers must also have Docker installed, as agents build and publish Docker images.

---

# Clone the Jenkins Infrastructure Repository

Clone the Jenkins infrastructure repository.

```bash
mkdir server-setup && cd server-setup
git clone --depth 1 --filter=blob:none --sparse git@github.com:smit9924/angular-fastapi-template-master.git .
git sparse-checkout set jenkins
```

---

# Configure Environment Variables

A sample environment file is provided.

Create your own `.env` file using:

```bash
cp .sample.env .env
```

Update the variables inside `.env`.

| Variable | Description |
|----------|-------------|
| `CASC_JENKINS_CONFIG` | Path to the Jenkins Configuration as Code (JCasC) YAML configuration file. |
| `JENKINS_ADMIN_USERNAME` | Username for the Jenkins administrator account. |
| `JENKINS_ADMIN_PASSWORD` | Password for the Jenkins administrator account. |
| `DOCKERHUB_USERNAME` | Docker Hub username used by Jenkins to push Docker images. |
| `DOCKERHUB_TOKEN` | Docker Hub Personal Access Token with **Read & Write** permissions. |
| `GITHUB_ACCESS_TOKEN` | GitHub Personal Access Token used by Jenkins to clone private repositories. |
| `JENKINS_URL` | Public URL where Jenkins is accessible. |
| `JENKINS_ADMIN_EMAIL` | Administrator email address used by Jenkins. |
| `JAVA_OPTS=-Djenkins.install.runSetupWizard=false` | Disables the Jenkins setup wizard because Jenkins is configured automatically using JCasC. |

> **Recommended:** Use a dedicated GitHub account (for example, **jenkins**) instead of your personal account. This makes commits and other GitHub activities performed by CI/CD easy to identify.

---

# Start Jenkins

Start Jenkins using Docker Compose.

```bash
docker compose -f docker-compose.yml up -d --build
```

---

# Access Jenkins

Hospitia uses **Jenkins Configuration as Code (JCasC)**, so Jenkins is fully configured during startup.

No manual configuration is required.

Open Jenkins in your browser:

```
http://localhost:9000
```

or

```
http(s)://<your-jenkins-server>
```

Log in using the administrator username and password configured in your `.env` file.

---

# Verify Jenkins Configuration

After logging in, verify that:

- Jenkins loads successfully.
- Credentials are configured.
- Docker Cloud is available.
- Jenkins agents are configured.
- Pipelines are ready to execute.

---

# Build Jenkins Agent Images

All Jenkins agent Dockerfiles are located under:

```
jenkins/agents/
```

A helper script is provided to build and publish agent images.

Run:

```bash
cd jenkins/agents

bash ./build-agents.sh \
    <dockerhub-username> \
    <dockerhub-access-token> \
    <agent-name> \
    <version>
```

Example:

```bash
bash ./build-agents.sh \
    smit9924 \
    dckr_pat_xxxxxxxxx \
    node22 \
    v1
```

The script authenticates with Docker Hub, builds the Docker image, and pushes it to Docker Hub.

---

# Agent Image Versioning Strategy

Hospitia maintains both immutable version tags and a moving `latest` tag.

Example:

Initial release:

```
node22-v1
node22-latest
```

After making changes:

```
node22-v2
node22-latest
```

Later:

```
node22-v3
node22-latest
```

This strategy provides two benefits:

- **Versioned tags** preserve the complete history of agent images and simplify rollbacks.
- **Latest tags** ensure Jenkins always provisions the newest agent image without requiring any configuration changes.

Jenkins agent definitions should always reference the `*-latest` tag.

---

# Useful Commands

Create `.env`

```bash
cp .sample.env .env
```

Start Jenkins

```bash
docker compose up -d
```

Stop Jenkins

```bash
docker compose down
```

View Jenkins logs

```bash
docker compose logs -f
```

Build a Jenkins agent image

```bash
bash ./build-agents.sh \
    <dockerhub-username> \
    <dockerhub-access-token> \
    <agent-name> \
    <version>
```

---

# Project Structure

```
jenkins/
├── agents/
│   ├── node/
│   ├── python/
│   ├── build-agents.sh
│   └── ...
├── casc/
├── docker-compose.yml
├── .sample.env
└── README.md
```

---

# Notes

- Jenkins is configured entirely using **Jenkins Configuration as Code (JCasC)**.
- No manual plugin installation or credential configuration is required after startup.
- Docker must be installed on:
  - The machine hosting the Jenkins controller.
  - Any machine hosting Jenkins agent containers.
- Docker Hub access tokens should have **Read & Write** permissions.
- GitHub access tokens should have the minimum permissions required to clone and access your repositories.