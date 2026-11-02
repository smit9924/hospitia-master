# Scripts

Every helper script in the workspace. Run them from the root of the repository they live in unless stated otherwise.

## hospitia-master

| Script | Purpose | Usage |
|---|---|---|
| `scripts/initial_setup.sh` | One-time local setup: creates the `dev-net` Docker network and installs the VS Code Dev Containers and WSL extensions. | `bash ./scripts/initial_setup.sh` |
| `scripts/cloud_env_setup.sh` | **Not run from the repository.** Pasted into the Claude Code cloud environment's setup script field; prepares the VM (removes the preinstalled PostgreSQL, installs tools, pre-pulls images, writes `~/.claude/CLAUDE.md`). | See [Claude Code cloud sessions](../getting-started/cloud-sessions.md) |
| `scripts/cloud_bootstrap.sh` | Prepares a cloud session: links the repositories, creates `.env` files, starts the infrastructure, installs dependencies, migrates databases, maps hostnames. Does nothing outside cloud sessions. Safe to re-run. | `bash hospitia-master/scripts/cloud_bootstrap.sh` (from the parent folder) |
| `scripts/check_docs.sh` | Strict MkDocs build of these docs (fails on broken links or pages missing from the nav), plus the agent rule and skill drift checks. | `bash ./scripts/check_docs.sh` |
| `scripts/export_openapi.sh` | Regenerates `docs/reference/api/<service>.openapi.json` from the FastAPI apps without starting them or needing Postgres/RabbitMQ. | `bash ./scripts/export_openapi.sh [service]` |
| `scripts/sync_agent_rules.sh` | Generates `.claude/rules/`, `.cursor/rules/` and the `CLAUDE.md` rules table from `.agents/rules/` (source of truth). `--check` reports drift and exits 1. | `bash ./scripts/sync_agent_rules.sh [--check]` |
| `scripts/sync_agent_skills.sh` | Copies agent skills from `.agents/skills/` (source of truth) to `.claude/skills/`. `--check` reports drift and exits 1. | `bash ./scripts/sync_agent_skills.sh [--check]` |
| `jenkins/agents/build-agents.sh` | Builds and pushes a Jenkins agent image (`node` or `python`) with a version tag and a moving `-latest` tag. | See [CI/CD with Jenkins](../operations/ci-cd.md#build-jenkins-agent-images) |
| `.devcontainer/devcontainer-init.sh` | Runs automatically before the dev container starts: creates the `dev-net` network and marks the repositories as safe Git directories. | automatic |

## hospitia-backend

| Script | Purpose | Usage |
|---|---|---|
| `scripts/create_migration.sh` | Autogenerates an Alembic migration for `auth`, `booking`, `payment` or `dashboard`, asking for a message. Uses dev container paths (`/workspace/backend/services`). Sources `scripts/utils.sh`. | `cd backend/scripts && bash create_migration.sh <service>`, or the **Make migrations** VS Code task |
| `scripts/utils.sh` | Coloured output helpers (`printInfoText`, `printSuccessText`, …) for other scripts. | `source ./utils.sh` |
| `services/<service>/jenkins/scripts/validate-repo.sh` | CI: checks that the service's required files and folders exist before the Docker build. | Run by the Jenkinsfile |
| `services/<service>/jenkins/scripts/update-db.sh` | Docker entrypoint: runs `alembic upgrade head`, then starts the app. (Not in notification, which has no database.) | Image entrypoint |

## hospitia-frontend

| Script | Purpose | Usage |
|---|---|---|
| `clients/main/jenkins/scripts/validate-repo.sh` | CI: checks the app's required files before the Docker build. | Run by the Jenkinsfile |
| npm scripts in `clients/main/package.json` | `start`, `build`, `build-production`, `watch`, `test`, `lint`, `lint-fix`, `format`, `jit` | `npm run <script>` |
