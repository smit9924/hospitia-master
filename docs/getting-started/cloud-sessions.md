# Claude Code cloud sessions

This page explains how to work on Hospitia with Claude Code on [claude.ai/code](https://claude.ai/code), where sessions run in a cloud VM instead of on your machine. It's for maintainers who set up the environment and for anyone who wants to know what happens in a session.

## How it differs from the dev container

Cloud sessions can't use the dev container. Instead:

- The cloud VM itself is the workspace. Only the infrastructure (Postgres, PgAdmin, RabbitMQ, Mailpit and nginx) runs in Docker.
- The three repositories are cloned **side by side** (`hospitia-master/`, `hospitia-frontend/`, `hospitia-backend/`) instead of nested. The bootstrap script links them into `hospitia-master/frontend` and `hospitia-master/backend`, so paths are the same as locally.
- Backend services reach Postgres, RabbitMQ and SMTP on `localhost` instead of Docker hostnames.

## One-time environment setup

1. **Install the Claude GitHub App** on all three repositories: `hospitia-master`, `hospitia-frontend` and `hospitia-backend`.
2. **Create a cloud environment** on claude.ai/code:
    - Network access: **Trusted**.
    - Setup script: paste the full contents of `scripts/cloud_env_setup.sh`. The script is kept in the repository only so it's versioned; it isn't run from there.
    - Environment variables: none needed.
3. **Start a session** with all three repositories selected.

`cloud_env_setup.sh` runs before the repositories are available. It removes the VM's preinstalled PostgreSQL server (which would hold port 5432), installs `iproute2` and Python 3.13 (via uv), starts Docker, pre-pulls the container images, and writes `~/.claude/CLAUDE.md`, which tells Claude to run the bootstrap script at the start of every session.

## What happens in each session

Claude runs the bootstrap script from the session's starting folder (the parent of `hospitia-master/`):

```bash
bash hospitia-master/scripts/cloud_bootstrap.sh
```

It:

1. Symlinks `hospitia-master/frontend` and `hospitia-master/backend` to the sibling repositories.
2. Creates missing `.env` files (in `.devcontainer/` and each backend service) from `.sample.cloud-dev.env`.
3. Starts Docker and the containers from `.devcontainer/docker-compose.yml` plus the cloud override `.devcontainer/docker-compose.cloud.yml` (which adds nginx and cloud-only settings).
4. Waits until every service responds.
5. Runs `uv sync --locked` and the Alembic migrations (`upgrade head`) for every service that has `<service>/database/alembic.ini` (auth, booking, dashboard, payment).
6. Maps the `*.localhost` hostnames to `127.0.0.1` in `/etc/hosts`.

The script is safe to re-run. It fails loudly (exit 1, with container logs) when a required command is missing, a port is held by another process, a service crashes or doesn't respond, or a dependency install or migration fails. Treat any non-zero exit as a broken setup and fix the cause rather than working around it.

Run it again when a session is reopened after it expired: a reopened session gets a fresh VM, so Docker and the containers are no longer running. Locally (when `CLAUDE_CODE_REMOTE` isn't `true`) the script does nothing.

## Cloud environment files

`.sample.env` files are for local development only and aren't changed for the cloud. Cloud differences live in `.sample.cloud-dev.env` next to each `.sample.env`, which the bootstrap copies to `.env`:

- **Backend services:** Postgres, RabbitMQ and SMTP hosts are `localhost` instead of dev-net Docker hostnames.
- **`.devcontainer`:** Mailpit's `MP_DATABASE` and `MP_LOG_FILE` are absolute `/data/...` paths.

When you add or change a key in a `.sample.env`, make the same change in the `.sample.cloud-dev.env` next to it.

## Working in a session

- Node.js 20 is installed at `/opt/node20`. Run `export PATH=/opt/node20/bin:$PATH` before any `npm` or `ng` command.
- Python 3.13 runs through uv (`uv sync`, `uv run …`).
- Use the `docker exec webapp-postgres psql -U postgres …` form for SQL; the VM's own `psql` 16 doesn't fully work with server 17 (for example `\l` fails).
- Start the dev servers as described in [Running the app](running-the-app.md); the same `*.localhost` URLs work in the session.

Service URLs and credentials are on [Local services and credentials](local-services.md).
