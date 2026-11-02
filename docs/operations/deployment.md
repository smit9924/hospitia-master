# Server setup and deployment

This guide prepares an Ubuntu/Linux server to run Hospitia and explains how the applications are deployed onto it.

!!! info "Assumptions"
    - All backend services, the frontend and the PostgreSQL database run on the **same server**.
    - The server runs **Ubuntu/Linux**.

## What runs where

`server-setup/docker-compose.yml` runs the shared infrastructure; Jenkins deploys each application as its own container (see [CI/CD with Jenkins](ci-cd.md)). Everything joins the external Docker network `hospitia-network`.

| Container | Started by | Purpose |
|---|---|---|
| `hospitia-postgres` (Postgres 17) | server-setup | Databases `auth`, `booking`, `dashboard`, `payment` (created by `postgres/docker-entrypoint-initdb.d/01_create_database.sql`) |
| `hospitia-rabbitmq` (RabbitMQ 4 with management) | server-setup | Message broker |
| `hospitia-nginx` (nginx 1.29) | server-setup | Reverse proxy, ports 80 (and 443 once HTTPS is enabled) |
| `hospitia-loki`, `hospitia-alloy`, `hospitia-grafana` | server-setup | Logs; see [Observability](observability.md) |
| `main-client`, `auth-service`, `notification-service`, `booking-service`, `dashboard-service`, `payment-service` | Jenkins | The applications |

## Prerequisites

Install on the server:

- Git
- Docker
- Docker Compose

## Get the server configuration

Clone only the `server-setup` directory:

```bash
mkdir hospitia-server-setup && cd hospitia-server-setup
git clone --depth 1 --filter=blob:none --sparse git@github.com:smit9924/hospitia-master.git .
git sparse-checkout set server-setup
cd server-setup
```

Run the remaining commands in this `server-setup` directory.

## Configure environment variables

```bash
cp .sample.env .env
```

Edit `.env` and replace every value, including every `ChangeMe123!` password:

| Variable | Purpose |
|---|---|
| `POSTGRES_USER`, `POSTGRES_PASSWORD` | Postgres superuser. |
| `POSTGRES_DB` | Default database created by the Postgres image. Referenced by `docker-compose.yml` but **not** in `.sample.env`; add it (for example `postgres`) to avoid a Compose warning. |
| `RABBITMQ_DEFAULT_USER`, `RABBITMQ_DEFAULT_PASS` | RabbitMQ account used by the services. |
| `GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD` | Grafana administrator. |
| `GF_USERS_ALLOW_SIGN_UP`, `GF_AUTH_ANONYMOUS_ENABLED` | Keep `false`. |
| `GF_PATHS_PROVISIONING` | Grafana provisioning path inside the container. |
| `LOKI_RETENTION_DAYS` | Log retention in Loki (default 10). |
| `PROMETHEUS_RETENTION_DAYS` | Metrics retention, used once Prometheus is enabled. |
| `DOCKER_LOG_MAX_SIZE`, `DOCKER_LOG_MAX_FILE` | Docker log rotation for the infrastructure containers (samples: `20m`, `3`). |

## Create the Docker network

All containers (frontend, backend services, nginx and the infrastructure) must be on a common Docker network so they can reach each other by container name:

```bash
docker network create hospitia-network
```

If the network already exists, Docker reports `network with name "hospitia-network" already exists`. That's expected and can be ignored.

## Start the infrastructure

```bash
docker compose -f docker-compose.yml up -d
```

Verify that the containers are up:

```bash
docker compose ps
```

You should see Postgres, RabbitMQ, nginx, Loki, Alloy and Grafana in the **Up** state.

## Prepare the application settings

Each backend container reads `/opt/hospitia/<container>/.env` on the server (for example `/opt/hospitia/booking-service/.env`). Create one per service from that service's `.sample.env` and set production values:

- `ENVIRONMENT=production` and `LOG_FORMAT=json` (never `local` on a server);
- `POSTGRES_SERVER=hospitia-postgres`, `RABBITMQ_HOST=hospitia-rabbitmq` and their credentials;
- a strong `JWT_ENCRYPTION_SECRET_KEY`, identical for auth, booking, dashboard and payment;
- `ALLOWED_ORIGINS` and `FRONTEND_BASE_URL` with the production frontend URL;
- real SMTP settings for the notification service.

See [Configuration](../reference/configuration.md) for every key. Then run each Jenkins job to deploy the applications. On first start, each service applies its database migrations.

## Routing

`nginx/conf.d/` has one site per container: the main domain for `main-client`, and `auth.`, `booking.`, `dashboard.`, `payment.`, `notification.` and `grafana.` subdomains, each proxying to the container port (see [Ports and hostnames](../reference/ports-and-hostnames.md#production)). The domain names are set in those files.

## Install SSL certificates

HTTPS is prepared but currently **disabled**: the `listen 443 ssl` server blocks in `nginx/conf.d/*.conf` and the `./nginx/ssl` volume in `docker-compose.yml` are commented out. To enable it:

1. Create a directory per site under `./nginx/ssl` (the directory names used in the configs are `main-client`, `auth`, `booking`, `notification` and `grafana`):

    ```bash
    mkdir -p ./nginx/ssl/main-client ./nginx/ssl/auth ./nginx/ssl/booking ./nginx/ssl/notification ./nginx/ssl/grafana
    ```

2. Copy each site's `ca_bundle.crt`, `certificate.crt` and `private.key` into its directory.
3. nginx expects the server certificate and CA bundle as one chain file. For each site, append the bundle to the certificate:

    ```bash
    cat ./nginx/ssl/<site>/ca_bundle.crt >> ./nginx/ssl/<site>/certificate.crt
    ```

4. Uncomment the HTTPS server blocks and the `./nginx/ssl:/etc/nginx/ssl:ro` volume, then restart nginx.

!!! note "TODO"
    The commented HTTPS blocks in `dashboard.conf` and `payment.conf` point to the `booking` certificate directory. Owner to confirm whether they should use their own certificates before HTTPS is enabled.

## Done

The server is ready. Once the applications are deployed and connected to `hospitia-network`, they're reachable through the nginx reverse proxy.
