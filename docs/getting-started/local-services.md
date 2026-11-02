# Local services and credentials

These are the development tools that run alongside Hospitia in the dev container and in cloud sessions.

!!! warning "Local development only"
    The credentials below come from the committed sample files and are only for local development and cloud sessions. Never reuse them anywhere else. Production values are set in each server's `.env` files; see [Server setup and deployment](../operations/deployment.md).

| Service | Address | Credentials |
|---|---|---|
| Postgres | `localhost:5432` (from the dev container: host `webapp-postgres`); databases `auth`, `booking`, `payment`, `dashboard` | `postgres` / `password` |
| PgAdmin | [http://localhost:8080](http://localhost:8080) | `developer@domain.com` / `password` |
| RabbitMQ | `localhost:5672`; management UI [http://localhost:15672](http://localhost:15672) | `developer` / `password` |
| Mailpit | SMTP `localhost:1025`; web UI [http://localhost:8025](http://localhost:8025) or [http://mailpit.localhost](http://mailpit.localhost) | `developer` / `password` (UI and SMTP) |

PgAdmin opens already connected to the Postgres server (`.devcontainer/postgres/servers.json`). If it asks for the database password, enter `password`.

See [PgAdmin, Mailpit and RabbitMQ](../guides/dev-tools.md) for what to do with each tool, and [Ports and hostnames](../reference/ports-and-hostnames.md) for every port in one table.
