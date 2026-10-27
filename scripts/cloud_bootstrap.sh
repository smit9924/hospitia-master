#!/usr/bin/env bash
#######################################################################
# cloud_bootstrap.sh
#
# Description:
#   Prepares the Hospitia multi-repo workspace inside a Claude Code
#   cloud session (claude.ai/code), starts the infrastructure
#   containers the backend services depend on, and starts nginx so the
#   *.localhost hostnames (main-client.localhost, auth.localhost, ...)
#   route to the dev servers like they do in the devcontainer.
#
# When it runs:
#   Once per cloud session, before any backend/frontend work.
#   Hooks in .claude/settings.json do not run in multi-repo cloud
#   sessions, so Claude (or you) must run this manually:
#       bash hospitia-master/scripts/cloud_bootstrap.sh
#
# Why it exists:
#   Locally, frontend/ and backend/ are nested clones inside the master
#   repo and everything runs inside the devcontainer. In the cloud:
#     - repositories are cloned side by side (siblings), not nested;
#     - devcontainers are not supported;
#     - the workspace image cannot be built (its Dockerfile fetches from
#       deb.nodesource.com and astral.sh, which are blocked by default).
#   So the cloud VM itself acts as the workspace. postgres, pgadmin,
#   rabbitmq and mailpit are started from docker-compose.yml, and nginx
#   from the docker-compose.cloud.yml override (locally nginx runs
#   inside the workspace container instead).
#
# Layout produced (PARENT is the folder the session starts in):
#   PARENT/hospitia-master/              <- ROOT (this repo)
#   PARENT/hospitia-master/frontend  ->  PARENT/hospitia-frontend
#   PARENT/hospitia-master/backend   ->  PARENT/hospitia-backend
#
# Backend .env files are created from each service's
# .sample.cloud-dev.env (localhost hosts), so the cloud environment
# needs no environment variables.
#
# Environment overrides:
#   FRONTEND_REPO   Sibling folder name of the frontend repo (default: hospitia-frontend)
#   BACKEND_REPO    Sibling folder name of the backend repo  (default: hospitia-backend)
#
# Locally (CLAUDE_CODE_REMOTE not "true") this script is a no-op, so it
# never interferes with the devcontainer workflow.
#
# The script is idempotent: running it again keeps existing symlinks,
# keeps existing .env files and leaves running containers untouched.
#######################################################################

set -euo pipefail


# ***************************************************************
# ***************** Guard: only run in the cloud ****************
# ***************************************************************
# Claude Code sets CLAUDE_CODE_REMOTE=true in cloud sessions. The ":-"
# default keeps "set -u" from failing when the variable is not defined.
if [[ "${CLAUDE_CODE_REMOTE:-}" != "true" ]]; then
    echo "[cloud-bootstrap] CLAUDE_CODE_REMOTE is not 'true'. Not a cloud session, nothing to do."
    exit 0
fi


# ***************************************************************
# ***************** Paths and configuration *********************
# ***************************************************************
# ROOT: the master repo. ${BASH_SOURCE[0]} is the path of this script
# file (even when invoked as "bash path/to/script"), so ROOT resolves
# correctly regardless of the current working directory.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# PARENT: the folder containing the master repo and its sibling repos
PARENT="$(dirname "$ROOT")"

# Real repository names (from "git remote get-url origin")
FRONTEND_REPO="${FRONTEND_REPO:-hospitia-frontend}"
BACKEND_REPO="${BACKEND_REPO:-hospitia-backend}"

DEVCONTAINER_DIR="$ROOT/.devcontainer"

# nginx site configs. Their server_name values are the hostnames that
# get mapped to 127.0.0.1 in /etc/hosts.
NGINX_CONF_DIR="$DEVCONTAINER_DIR/nginx/conf.d"

# Marker appended to the /etc/hosts lines this script adds, so they are
# easy to identify (and remove by hand if ever needed)
HOSTS_MARKER="# hospitia-cloud-dev"

# Maximum time to wait for the Docker daemon to come up
DOCKER_START_TIMEOUT_SECONDS=60

# Compose command used for every container operation. The cloud override
# (docker-compose.cloud.yml) only adds nginx, and is always merged on top
# of docker-compose.yml. Relative paths resolve against DEVCONTAINER_DIR,
# which the script cd's into before using this.
COMPOSE=(docker compose -f docker-compose.yml -f docker-compose.cloud.yml)

# Services started in the cloud and the VM ports each one listens on.
# Keep in sync with the "ports:" in docker-compose.yml (and port 80 of
# the host-network nginx in docker-compose.cloud.yml).
declare -A SERVICE_PORTS=(
    [postgres]="5432"
    [pgadmin]="8080"
    [rabbitmq]="5672 15672"
    [mailpit]="1025 8025"
    [nginx]="80"
)


# ***************************************************************
# ***************** Helper methods ******************************
# ***************************************************************
log() {
    # -------------------------------------------------------------
    # log
    # Description: Prints a message prefixed with the script tag.
    # Arguments: $* → message text
    # Output: Message on stdout
    # -------------------------------------------------------------
    echo "[cloud-bootstrap] $*"
}


fail() {
    # -------------------------------------------------------------
    # fail
    # Description: Prints an error message on stderr and exits.
    # Arguments: $* → error text
    # Output: Message on stderr, exit code 1
    # -------------------------------------------------------------
    echo "[cloud-bootstrap] ERROR: $*" >&2
    exit 1
}


linkSiblingRepository() {
    # -------------------------------------------------------------
    # linkSiblingRepository
    # Description: Creates ROOT/<link_name> as a symlink to the sibling
    #              repository PARENT/<repo_name>, so every path that
    #              assumes the local nested layout (frontend/, backend/)
    #              keeps working in the cloud.
    # Arguments: $1 → link name inside ROOT (e.g. "frontend")
    #            $2 → sibling repository folder name (e.g. "hospitia-frontend")
    # Output: None. Exits with an error if the sibling folder is missing.
    # -------------------------------------------------------------
    local link_name="$1"
    local repo_name="$2"
    local link_path="$ROOT/$link_name"
    local target_path="$PARENT/$repo_name"

    # "-e" is true for existing files/folders (and valid symlinks);
    # "-L" additionally catches broken symlinks. Either way, leave it alone.
    if [[ -e "$link_path" || -L "$link_path" ]]; then
        log "$link_name already exists in $ROOT. Skipping."
        return
    fi

    if [[ ! -d "$target_path" ]]; then
        fail "Sibling repository '$target_path' not found. Select the '$repo_name' repository when starting the session, or set ${link_name^^}_REPO to its folder name."
    fi

    ln -s "$target_path" "$link_path"
    log "Linked $link_path -> $target_path"
}


copySampleEnv() {
    # -------------------------------------------------------------
    # copySampleEnv
    # Description: Copies <dir>/<sample> to <dir>/.env if .env is
    #              missing. .env files are gitignored, so a fresh clone
    #              never has them.
    # Arguments: $1 → directory containing the sample file
    #            $2 → sample file name (optional, default: .sample.env)
    # Output: None
    # -------------------------------------------------------------
    local dir="$1"
    local sample="${2:-.sample.env}"

    if [[ -f "$dir/.env" ]]; then
        return
    fi

    if [[ ! -f "$dir/$sample" ]]; then
        log "No $sample in $dir. Skipping."
        return
    fi

    cp "$dir/$sample" "$dir/.env"
    log "Created $dir/.env from $sample"
}


startDockerDaemon() {
    # -------------------------------------------------------------
    # startDockerDaemon
    # Description: Starts dockerd in the background if the daemon is
    #              not reachable (cloud VMs do not keep it running), then
    #              waits until "docker info" succeeds.
    # Arguments: None
    # Output: None. Exits with an error after the timeout.
    # -------------------------------------------------------------
    if docker info >/dev/null 2>&1; then
        return
    fi

    log "Starting Docker daemon (logs: /var/log/dockerd.log)"
    # nohup + & detaches dockerd so it keeps running after this script ends
    nohup dockerd >/var/log/dockerd.log 2>&1 &

    local waited=0
    until docker info >/dev/null 2>&1; do
        if (( waited >= DOCKER_START_TIMEOUT_SECONDS )); then
            fail "Docker daemon did not start within ${DOCKER_START_TIMEOUT_SECONDS}s. See /var/log/dockerd.log"
        fi
        sleep 1
        waited=$(( waited + 1 ))
    done
    log "Docker daemon is running"
}


checkPortsAvailable() {
    # -------------------------------------------------------------
    # checkPortsAvailable
    # Description: Before starting the containers, verifies that no other
    #              process on the VM already listens on a port one of our
    #              services needs. Without this, "docker compose up" fails
    #              with an unclear "port is already allocated" error.
    #              Ports of services that are already running are skipped,
    #              since our own container is what holds them (normal on a
    #              second run). Nothing is stopped automatically: on a
    #              conflict the script fails with the port and the process
    #              holding it, so the cause is obvious.
    # Arguments: None (uses SERVICE_PORTS and COMPOSE; must run from
    #            DEVCONTAINER_DIR)
    # Output: None. Exits with an error listing every conflicting port.
    # -------------------------------------------------------------
    if ! command -v ss >/dev/null 2>&1; then
        log "WARNING: 'ss' not found. Skipping the port availability check."
        return
    fi

    # Services of this compose project that are already running
    local running_services
    running_services="$("${COMPOSE[@]}" ps --status running --services 2>/dev/null || true)"

    local service port listener
    local conflicts=()
    for service in "${!SERVICE_PORTS[@]}"; do
        # grep -x matches the whole line, so "postgres" doesn't match "pgadmin"
        if grep -qx "$service" <<<"$running_services"; then
            continue
        fi

        for port in ${SERVICE_PORTS[$service]}; do
            # -l listening, -t TCP, -n numeric, -p owning process, -H no header.
            # The filter limits the output to sockets bound to this port.
            listener="$(ss -ltnpH "sport = :$port" 2>/dev/null || true)"
            if [[ -n "$listener" ]]; then
                # The users:(("name",pid=N,fd=N)) part names the process
                conflicts+=("port $port ($service) is in use: ${listener##* }")
            fi
        done
    done

    if (( ${#conflicts[@]} > 0 )); then
        local conflict
        for conflict in "${conflicts[@]}"; do
            echo "[cloud-bootstrap] ERROR: $conflict" >&2
        done
        fail "Free the port(s) above, then run this script again. Inspect with: ss -ltnp"
    fi
}


addLocalHostnames() {
    # -------------------------------------------------------------
    # addLocalHostnames
    # Description: Maps every *.localhost server_name found in the nginx
    #              site configs to 127.0.0.1 in /etc/hosts.
    #              Browsers and recent curl resolve *.localhost to the
    #              loopback address on their own, but other tools (e.g.
    #              Python requests, which uses the system resolver) need
    #              an /etc/hosts entry.
    #              Hostnames are read from the configs instead of being
    #              hardcoded, so new sites are picked up automatically.
    #              Names that are already present are skipped, so running
    #              this again adds nothing.
    # Arguments: None
    # Output: None. Prints a warning (does not fail) if /etc/hosts is
    #         not writable, since routing via browsers/curl still works.
    # -------------------------------------------------------------
    if [[ ! -w /etc/hosts ]]; then
        log "WARNING: /etc/hosts is not writable. Skipping *.localhost entries."
        return
    fi

    local hostname
    # 1. sed prints what follows "server_name" up to ";" on each line
    # 2. tr puts each name on its own line
    # 3. grep keeps only *.localhost names (not e.g. *.localhost.com,
    #    which could shadow a real domain)
    # 4. sort -u removes duplicates
    while read -r hostname; do
        # Match the name as a whole word to avoid partial matches
        if grep -qE "[[:space:]]${hostname//./\\.}([[:space:]]|$)" /etc/hosts; then
            continue
        fi
        echo "127.0.0.1 $hostname $HOSTS_MARKER" >> /etc/hosts
        log "Added $hostname to /etc/hosts"
    done < <(
        sed -nE 's/^[[:space:]]*server_name[[:space:]]+([^;]*);.*/\1/p' "$NGINX_CONF_DIR"/*.conf \
            | tr -s '[:space:]' '\n' \
            | grep -E '\.localhost$' \
            | sort -u
    )
}


# ***************************************************************
# ***************** 1. Recreate the nested layout ***************
# ***************************************************************
log "Master repo: $ROOT"
linkSiblingRepository "frontend" "$FRONTEND_REPO"
linkSiblingRepository "backend" "$BACKEND_REPO"


# ***************************************************************
# ***************** 2. Environment files ************************
# ***************************************************************
# docker-compose.yml requires .devcontainer/.env (project_name, RabbitMQ
# and Mailpit credentials), same as the local setup.
copySampleEnv "$DEVCONTAINER_DIR"

# Each backend service loads its settings from services/<name>/.env and
# fails at startup if required values are missing. Use the service's
# .sample.cloud-dev.env, which matches .sample.env except that the
# Postgres/RabbitMQ/SMTP hosts are localhost instead of dev-net Docker
# hostnames. This way the cloud environment needs no env vars. Fall
# back to .sample.env for services that have no cloud-dev sample.
for service_dir in "$ROOT"/backend/services/*/; do
    # The glob stays literal when nothing matches. Skip that case.
    [[ -d "$service_dir" ]] || continue
    service_dir="${service_dir%/}"

    if [[ -f "$service_dir/.sample.cloud-dev.env" ]]; then
        copySampleEnv "$service_dir" ".sample.cloud-dev.env"
    else
        copySampleEnv "$service_dir"
    fi
done


# ***************************************************************
# ***************** 3. Docker daemon and network ****************
# ***************************************************************
startDockerDaemon

# docker-compose.yml declares dev-net as an external network, so it must
# exist before "compose up" (locally devcontainer-init.sh creates it).
# Create it only if it does not exist yet.
if docker network inspect dev-net >/dev/null 2>&1; then
    log "Docker network 'dev-net' already exists"
else
    docker network create dev-net >/dev/null
    log "Created Docker network 'dev-net'"
fi


# ***************************************************************
# ***************** 4. Containers *******************************
# ***************************************************************
# The "workspace" service is intentionally NOT started: its image cannot
# be built in the cloud, and the VM itself already provides Python (uv)
# and Node. Ports are published on the VM, so everything is on localhost.
#
# docker-compose.cloud.yml is merged on top of docker-compose.yml and
# only adds the nginx service (host network, same conf.d site configs as
# the devcontainer). Both files are always passed together (COMPOSE).
cd "$DEVCONTAINER_DIR"

# Fail early with a clear message if another process holds one of our
# ports (e.g. a PostgreSQL server on 5432 that the setup script did not
# remove).
checkPortsAvailable

log "Starting postgres, pgadmin, rabbitmq, mailpit and nginx"
"${COMPOSE[@]}" up -d "${!SERVICE_PORTS[@]}"


# ***************************************************************
# ***************** 5. *.localhost hostnames ********************
# ***************************************************************
addLocalHostnames


# ***************************************************************
# ***************** 6. Summary **********************************
# ***************************************************************
cat <<'EOF'

[cloud-bootstrap] Done. Service endpoints (credentials: see CLAUDE.md "Cloud sessions"):
  Postgres       localhost:5432
  RabbitMQ       localhost:5672   (management UI: http://localhost:15672)
  Mailpit SMTP   localhost:1025
  Mailpit UI     http://localhost:8025
  PgAdmin        http://localhost:8080

Routed by nginx (port 80). A route returns 502 until its dev server is running:
  Frontend       http://main-client.localhost   -> localhost:8001
  Auth API       http://auth.localhost          -> localhost:8000
  Booking API    http://booking.localhost       -> localhost:8004
  Dashboard API  http://dashboard.localhost     -> localhost:8005
  Payment API    http://payment.localhost       -> localhost:8006
  Mailpit UI     http://mailpit.localhost       -> localhost:8025
EOF
