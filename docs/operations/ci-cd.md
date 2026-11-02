# CI/CD with Jenkins

Hospitia builds and deploys with Jenkins, configured entirely in code. This page explains the setup in `hospitia-master/jenkins/` and the pipelines in each service and client.

## Overview

| Part | Where | What it does |
|---|---|---|
| Controller image | `jenkins/Dockerfile`, `jenkins/plugins.txt` | Jenkins `2.568.1-jdk21` with the Docker CLI and the plugins in `plugins.txt` |
| Configuration as Code (JCasC) | `jenkins/casc/` | Security (local admin, no sign-up), credentials, Docker cloud, location, jobs |
| Jobs (Job DSL) | `jenkins/job-dsl/` | Folders `Frontend` and `Backend`; one pipeline job per client and service |
| Agents | `jenkins/agents/` | Docker images `hospitia-jenkins-agent:node-latest` and `:python-latest`, started on demand by the Docker cloud |
| Pipelines | `services/<service>/jenkins/Jenkinsfile` (backend), `clients/main/jenkins/Jenkinsfile` (frontend) | Build, push and deploy one app |

Jobs are managed by Job DSL: don't edit them in the Jenkins UI, change the Groovy files instead.

## Prerequisites

- Docker and Docker Compose on the host.
- Any machine hosting Jenkins agent containers must also have Docker, since agents build and publish Docker images.

## Set up Jenkins

### Get the configuration

Clone only the `jenkins` directory:

```bash
mkdir hospitia-jenkins && cd hospitia-jenkins
git clone --depth 1 --filter=blob:none --sparse git@github.com:smit9924/hospitia-master.git .
git sparse-checkout set jenkins
cd jenkins
```

### Configure environment variables

```bash
cp .sample.env .env
```

Fill in `.env`:

| Variable | Purpose |
|---|---|
| `CASC_JENKINS_CONFIG` | Path of the JCasC configuration inside the container (`/var/jenkins_home/casc`). |
| `JENKINS_ADMIN_USERNAME`, `JENKINS_ADMIN_PASSWORD` | The Jenkins administrator account. |
| `JENKINS_ADMIN_EMAIL` | Administrator email address. |
| `JENKINS_URL` | Public URL of Jenkins. |
| `JAVA_OPTS` | `-Djenkins.install.runSetupWizard=false`: disables the setup wizard, since JCasC configures Jenkins. |
| `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` | Docker Hub account and personal access token with **Read & Write** permission, used to push images. |
| `GITHUB_USERNAME`, `GITHUB_ACCESS_TOKEN` | GitHub account and personal access token used to clone the private repositories. Give the token the minimum permissions needed. |
| `DEPLOYMENT_SERVER_USERNAME` | SSH user on the production server. |
| `DEPLOYMENT_SERVER_SSH_KEY_FILE_PATH` | Path (inside the container) of the SSH private key for the production server. The host's `~/.ssh` is mounted read-only at `/root/.ssh`. |
| `DEPLOYMENT_SERVER_PUBLIC_IP` | Address of the production server. |

These become the Jenkins credentials `dockerhub`, `github-token`, `deploy-ssh` and `deployment-server-ip` (`jenkins/casc/credentials.yaml`).

!!! tip
    Use a dedicated GitHub account (for example **jenkins**) rather than a personal one, so commits and other activity by CI/CD are easy to identify.

### Start Jenkins

```bash
docker compose -f docker-compose.yml up -d --build
```

Jenkins listens on [http://localhost:9000](http://localhost:9000) (container port 8080; agents connect on 50000). Sign in with the administrator account from `.env`. No manual configuration is needed.

!!! warning
    The Jenkins container runs as root and mounts the Docker socket so that it can run Docker commands. Treat the Jenkins host as a sensitive machine.

### Verify

After signing in, check that Jenkins loads, the credentials exist, the Docker cloud is available, the agent templates are configured, and the `Frontend` and `Backend` folders contain the jobs.

### Useful commands

```bash
docker compose up -d        # start
docker compose down         # stop
docker compose logs -f      # follow logs
```

## Build Jenkins agent images

Agent Dockerfiles are `jenkins/agents/Dockerfile.node` (Node.js 22) and `jenkins/agents/Dockerfile.python`. Build and publish an agent with:

```bash
cd jenkins/agents
bash ./build-agents.sh <dockerhub-username> <dockerhub-access-token> <agent-name> <version>
# example
bash ./build-agents.sh smit9924 <token> node v1
```

`<agent-name>` is `node` or `python`. The script logs in to Docker Hub, builds `<user>/hospitia-jenkins-agent` and pushes two tags.

### Agent image versioning

Each build publishes an immutable version tag and moves the `latest` tag:

```text
node-v1, node-latest      # first release
node-v2, node-latest      # after a change
```

- **Version tags** keep the full history of agent images and make rollbacks simple.
- **Latest tags** let Jenkins always use the newest image without configuration changes. Agent templates in `jenkins/casc/docker-cloud.yaml` must reference the `*-latest` tags (`node-latest` with label `docker-agent-node`, `python-latest` with label `docker-agent-python`).

## Jobs

`jenkins/casc/jobs.yaml` loads these Job DSL scripts:

| Job | Script | Pipeline file |
|---|---|---|
| `Frontend/main-client` | `job-dsl/frontend/main-client.groovy` | `clients/main/jenkins/Jenkinsfile` |
| `Backend/auth` | `job-dsl/backend/auth.groovy` | `services/auth/jenkins/Jenkinsfile` |
| `Backend/booking`, `Backend/dashboard`, `Backend/payment`, `Backend/notification` | `job-dsl/backend/<service>.groovy` | `services/<service>/jenkins/Jenkinsfile` |

Each job has a `SOURCE_BRANCH` choice parameter (currently only `main`), keeps two builds for one day, and is started manually.

!!! note "TODO"
    The Job DSL scripts clone `smit9924/angular-fastapi-template-backend` and `smit9924/angular-fastapi-template-frontend`. Owner to confirm whether these should point to `hospitia-backend` and `hospitia-frontend`.

## Pipeline stages

Backend pipelines run on the `docker-agent-python` agent; the frontend pipeline runs on `docker-agent-node`.

1. **Initialize:** validate `SOURCE_BRANCH`.
2. **Checkout source** of the selected branch.
3. **Capture build metadata:** commit SHA; the image tag is the 12-character short SHA.
4. **Validate repository:** `jenkins/scripts/validate-repo.sh` checks the required files.
5. *(frontend only)* **Install dependencies** and **build Angular** (`npm run build-production`).
6. **Build Docker image** from `jenkins/Dockerfile`.
7. **Push** the image with its SHA tag and `latest` to Docker Hub (`smit9924/hospitia-<service>-service`, `smit9924/hospitia-frontend-main-client`).
8. **Deploy** over SSH: pull `latest`, stop and remove the running container, and start the new one on `hospitia-network` with `--restart on-failure`; then prune old images.
    - Backend services additionally get JSON-file log rotation (20 MB × 3), the label `com.hospitia.service=<container>` (used by Alloy to collect logs) and the env file `/opt/hospitia/<container>/.env`.
    - The frontend container (`main-client`, port 9001) needs no env file: its settings are compiled in from `environment.prod.ts`.
9. **Build summary.**

Pipelines don't run linters or tests; run them before merging (see [Testing and linting](../guides/testing-and-linting.md)).

## Images

- **Backend:** `python:3.13-slim`, non-root `app` user, dependencies installed with uv from `pyproject.toml`. The entrypoint `update-db.sh` runs `alembic upgrade head`, then `uvicorn <service>.main:app --host 0.0.0.0 --port <port>`. (notification has no migrations.)
- **Frontend:** multi-stage build with Node.js (`node:24.12.0-alpine`), then `nginx-unprivileged` serving the build on port 9001 with `jenkins/nginx.conf` (redirects `/` to `/en-US/`, caching and security headers).

## Project structure

```text
jenkins/
├── agents/            # Dockerfile.node, Dockerfile.python, build-agents.sh
├── casc/              # credentials, docker-cloud, jenkins, jobs, location, security
├── job-dsl/           # folders.groovy, frontend/, backend/
├── Dockerfile         # controller image
├── docker-compose.yml
├── plugins.txt
└── .sample.env
```
