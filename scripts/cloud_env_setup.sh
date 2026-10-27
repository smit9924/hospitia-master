#!/usr/bin/env bash
#######################################################################
# cloud_env_setup.sh
#
# !!! THIS SCRIPT IS NOT RUN FROM THE REPOSITORY !!!
# Paste its entire contents into the "Setup script" field of the
# Claude Code cloud environment (claude.ai/code → environment settings).
# It is kept in the repo only so it is versioned and reviewable.
#
# Description:
#   Pre-installs the tools and Docker images the Hospitia cloud sessions
#   need, so that scripts/cloud_bootstrap.sh starts quickly in each
#   session.
#
# Constraints of the "Setup script" field:
#   - Runs as root on the Ubuntu 24.04 cloud VM.
#   - Runs BEFORE the repositories are available, so it must not use any
#     repository paths.
#   - Must finish in under ~5 minutes, which is why image pulls run in
#     parallel.
#
# What it does:
#   1. Removes the preinstalled PostgreSQL server, which would otherwise
#      hold port 5432 needed by the Postgres container.
#   2. Installs iproute2, which provides 'ss' for the bootstrap's port
#      check (the base image does not include it).
#   3. Installs Python 3.13 via uv (the backend requires >=3.13).
#   4. Starts the Docker daemon if it is not running.
#   5. Pulls the images used by .devcontainer/docker-compose.yml and
#      .devcontainer/docker-compose.cloud.yml.
#   6. Writes ~/.claude/CLAUDE.md, telling Claude to run the bootstrap
#      script at the start of every session.
#
# Any failure exits non-zero, which (by design) stops the session from
# starting, so a broken environment is noticed immediately.
#
# nginx is intentionally NOT installed on the VM. In the cloud it runs as
# the "nginx" container from docker-compose.cloud.yml.
#######################################################################

set -euo pipefail

log() {
    # -------------------------------------------------------------
    # log
    # Description: Prints a message prefixed with the script tag.
    # Arguments: $* → message text
    # Output: Message on stdout
    # -------------------------------------------------------------
    echo "[cloud-env-setup] $*"
}


# ***************************************************************
# ***************** 1. Remove preinstalled PostgreSQL server ****
# ***************************************************************
# The cloud base image ships PostgreSQL 16, and there is no setting to
# get a VM without it. If its server runs, it holds port 5432 and the
# Postgres container (the project's real database) cannot start.
# Removing it here means every cached session starts without it.
#
# Only server packages are removed:
#   "postgresql"           metapackage that pulls in the server
#   "postgresql-<digit>*"  versioned server (e.g. postgresql-16) and
#                          its server-side extensions
# The client ("postgresql-client-*", which provides psql) does not match
# "postgresql-<digit>*", so it stays, and Claude can still use psql
# against the Postgres container.
#
# dpkg-query lists matching packages with their status; awk keeps only
# the ones actually installed (status ends in "installed"). dpkg-query
# exits non-zero when a pattern matches nothing, so "|| true" keeps
# that normal case from stopping the script.
mapfile -t postgresServerPackages < <(
    { dpkg-query -W -f='${Package} ${Status}\n' 'postgresql' 'postgresql-[0-9]*' 2>/dev/null || true; } \
        | awk '$NF == "installed" { print $1 }'
)

if (( ${#postgresServerPackages[@]} > 0 )); then
    log "Removing preinstalled PostgreSQL server: ${postgresServerPackages[*]}"
    # Purging stops the running server (via the package's prerm script)
    # and removes its configuration, so it cannot start again. No network
    # access is needed to remove packages.
    DEBIAN_FRONTEND=noninteractive apt-get purge -y -qq "${postgresServerPackages[@]}"
else
    log "No PostgreSQL server package installed. Nothing to remove."
fi


# ***************************************************************
# ***************** 2. System packages **************************
# ***************************************************************
# scripts/cloud_bootstrap.sh checks for port conflicts with 'ss', which
# comes from iproute2. The cloud base image does not include it, so
# install it here; the environment cache keeps it for every session.
# The package index may be stale on a fresh VM, so refresh it first.
log "Installing iproute2 (provides ss)"
DEBIAN_FRONTEND=noninteractive apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq iproute2


# ***************************************************************
# ***************** 3. Python ***********************************
# ***************************************************************
# uv is preinstalled on the VM. The backend services require Python >=3.13.
log "Installing Python 3.13 via uv"
uv python install 3.13


# ***************************************************************
# ***************** 4. Docker daemon ****************************
# ***************************************************************
# Same guard as scripts/cloud_bootstrap.sh: start dockerd only if it is
# not reachable, then wait up to 60s for it.
if ! docker info >/dev/null 2>&1; then
    log "Starting Docker daemon (logs: /var/log/dockerd.log)"
    nohup dockerd >/var/log/dockerd.log 2>&1 &

    waited=0
    until docker info >/dev/null 2>&1; do
        if (( waited >= 60 )); then
            echo "[cloud-env-setup] ERROR: Docker daemon did not start within 60s. See /var/log/dockerd.log" >&2
            exit 1
        fi
        sleep 1
        waited=$(( waited + 1 ))
    done
fi


# ***************************************************************
# ***************** 5. Docker images ****************************
# ***************************************************************
# Keep these tags in sync with .devcontainer/docker-compose.yml and
# .devcontainer/docker-compose.cloud.yml (nginx).
images=(
    "postgres:17.0-bullseye"
    "dpage/pgadmin4:latest"
    "rabbitmq:3.13-management"
    "axllent/mailpit:v1.31"
    "nginx:1.27-alpine"
)

# Each pull runs in the background (&), and its PID is recorded. A plain
# "wait" would always return 0, so wait for each PID separately to
# detect a failed pull.
log "Pulling ${#images[@]} Docker images in parallel"
pids=()
for image in "${images[@]}"; do
    docker pull --quiet "$image" &
    pids+=("$!")
done

failed=0
for i in "${!pids[@]}"; do
    if ! wait "${pids[$i]}"; then
        echo "[cloud-env-setup] ERROR: failed to pull ${images[$i]}" >&2
        failed=1
    fi
done

if (( failed )); then
    exit 1
fi


# ***************************************************************
# ***************** 6. Session instructions for Claude **********
# ***************************************************************
# Cloud sessions start in the parent folder of the cloned repositories,
# so hospitia-master/CLAUDE.md is not loaded at startup. Hooks can't run
# the bootstrap either, because multi-repo sessions skip repository
# hooks. ~/.claude/CLAUDE.md is loaded as user instructions in every
# session, and the environment cache keeps it, so it reliably tells
# Claude to run the bootstrap first.
# Only plain text is written here, so this step does not depend on the
# repositories being present.
log "Writing ~/.claude/CLAUDE.md"
mkdir -p "$HOME/.claude"
cat > "$HOME/.claude/CLAUDE.md" <<'EOF'
# Hospitia cloud session

- At the start of every session, before any other work, run
  `bash hospitia-master/scripts/cloud_bootstrap.sh` from the session's
  starting folder (the parent of `hospitia-master/`). It links the repos,
  creates `.env` files and starts Postgres, PgAdmin, RabbitMQ, Mailpit and
  nginx. It's safe to re-run.
- Run it again whenever the session is reopened after it expired. A reopened
  session gets a fresh VM, so dockerd and the containers are no longer running.
- Then read `hospitia-master/CLAUDE.md` for project rules, service endpoints
  and dev-server commands. Work through the `hospitia-master/frontend` and
  `hospitia-master/backend` paths so the project instructions apply.
EOF

log "Done"
