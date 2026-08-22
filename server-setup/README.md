# Server Setup Guide

This guide explains how to prepare an Ubuntu/Linux server for deploying the Hospitia application.

> **Assumptions**
>
> * All backend services, frontend services, and the PostgreSQL database will run on the **same server**.
> * The target server is running **Ubuntu/Linux**.

---

## Prerequisites

Ensure the following software is installed on the server before proceeding:

* Git
* Docker
* Docker Compose

---

## Clone the Server Setup Directory

Clone only the `server-setup` directory from the repository using Git sparse checkout.

```bash
mkdir hospitia-server-setup && cd hospitia-server-setup

git clone --depth 1 --filter=blob:none --sparse git@github.com:smit9924/angular-fastapi-template-master.git .

git sparse-checkout set server-setup
```

Navigate to the cloned `server-setup` directory before executing the remaining commands.

```bash
cd server-setup
```

---

## Configure Environment Variables

Create the environment file from the provided sample.

```bash
cp .sample.env .env
```

Open the `.env` file and update all variables with values appropriate for your environment.

---

## Install SSL Certificates

Each service is hosted on a different subdomain and requires its own SSL certificate. Create a dedicated directory for each service under `./nginx/ssl`:

```bash
mkdir -p ./nginx/ssl/main-client \
         ./nginx/ssl/auth \
         ./nginx/ssl/notification
```

Copy the certificate files for each service into its respective directory. For example:

```text
nginx/
└── ssl/
    ├── main-client/
    │   ├── ca_bundle.crt
    │   ├── certificate.crt
    │   └── private.key
    ├── auth/
    │   ├── ca_bundle.crt
    │   ├── certificate.crt
    │   └── private.key
    └── notification/
        ├── ca_bundle.crt
        ├── certificate.crt
        └── private.key
```

Nginx expects the server certificate and CA bundle to be provided as a single certificate chain file. For each service, append the CA bundle to the server certificate:

```bash
cat ./nginx/ssl/main-client/ca_bundle.crt >> ./nginx/ssl/main-client/certificate.crt
cat ./nginx/ssl/auth/ca_bundle.crt >> ./nginx/ssl/auth/certificate.crt
cat ./nginx/ssl/notification/ca_bundle.crt >> ./nginx/ssl/notification/certificate.crt
```

After running these commands, each `certificate.crt` file will contain both the server certificate and the complete certificate chain, allowing it to be referenced directly in the corresponding Nginx server configuration.

## Create Docker Network

All application containers (frontend, backend services, Nginx, etc.) must be connected to a common Docker network so they can communicate with each other using their container names.

Create the network by running:

```bash
docker network create hospitia-network
```

If the network already exists, Docker will return an error similar to:

```text
Error response from daemon: network with name "hospitia-network" already exists
```

This is expected and can be safely ignored.


## Start the Infrastructure

Run the following command to start the required infrastructure containers.

```bash
docker compose -f docker-compose.yml up -d
```

---

## Verify the Deployment

Verify that all infrastructure containers are running successfully.

```bash
docker compose ps
```

You should see the required infrastructure containers (such as Nginx, PostgreSQL, Loki, Prometheus, Alloy, and Grafana) in the **Up** state.

---

## Observability

Grafana, Loki, Prometheus, and Grafana Alloy run on the same Compose file and Docker network as Postgres, Nginx, and RabbitMQ.

Pinned images (never `latest`):

* Grafana Enterprise `13.1.3` — UI at port `3000`. Admin user and password come from `.env`. Dashboards survive recreation via `./grafana/data` and provisioning under `./grafana/provisioning`.
* Loki `3.5.5` — log store. Retention is `LOKI_RETENTION_DAYS` (default 10). Config is bind-mounted from `./loki/config.yaml`.
* Prometheus `v3.5.0` — metrics store, self-scrape only. Ready for future `/metrics` jobs. No Alertmanager.
* Grafana Alloy `v1.12.0` — reads Docker container stdout via the Docker socket and pushes logs to Loki. FastAPI must log JSON to stdout (`ENVIRONMENT=production`, `LOG_FORMAT=json`). Do not write log files in production.

Docker JSON-file logs are rotated (`max-size=10m`, `max-file=3`) on Compose services and on the Auth service `docker run` from Jenkins, so container logs do not grow without bound. Loki is the query store.

Open Grafana at `http://<server>:3000`, sign in with `GRAFANA_ADMIN_USER` / `GRAFANA_ADMIN_PASSWORD`, and open **Hospitia → Application logs** or Explore → Loki. Filter by `container` (for Auth: `auth-service`).

Tempo, Vector, OpenTelemetry tracing, and Alertmanager are not deployed.

---

## 🎉 Server Setup Complete

Your server is now ready for application deployment.

Once your frontend and backend services are deployed and connected to the shared Docker network, they will be accessible through the configured Nginx reverse proxy.
