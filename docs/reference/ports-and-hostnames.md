# Ports and hostnames

## Local development and cloud sessions

nginx routes these hostnames on port 80 (`.devcontainer/nginx/conf.d/`). Use them in the browser and for API testing, since the frontend environment and the backend CORS settings expect them. A hostname returns 502 until its dev server is running.

| Hostname | Target | What runs there |
|---|---|---|
| `http://main-client.localhost` | `localhost:8001` | Angular dev server (`npm start`) |
| `http://auth.localhost` | `localhost:8000` | auth service |
| `http://booking.localhost` | `localhost:8004` | booking service |
| `http://dashboard.localhost` | `localhost:8005` | dashboard service |
| `http://payment.localhost` | `localhost:8006` | payment service |
| `http://mailpit.localhost` | Mailpit UI (`8025`) | Mailpit |

Each site also answers to `<name>.localhost.com`. The notification service has no HTTP routes and no hostname; its VS Code task and launch configuration use port 8002.

| Tool | Port |
|---|---|
| Postgres | 5432 |
| PgAdmin | 8080 |
| RabbitMQ (AMQP / management UI) | 5672 / 15672 |
| Mailpit (SMTP / UI) | 1025 / 8025 |
| Jenkins (when run locally) | 9000 (agents 50000) |

## Production

Containers join the `hospitia-network` Docker network; nginx (`server-setup/nginx/conf.d/`) routes one subdomain per container. The actual domain names are configured in those files.

| Container | Port | Routed as |
|---|---|---|
| `main-client` | 9001 | Main domain |
| `auth-service` | 9002 | `auth.` subdomain |
| `notification-service` | 9003 | `notification.` subdomain |
| `booking-service` | 9004 | `booking.` subdomain |
| `dashboard-service` | 9005 | `dashboard.` subdomain |
| `payment-service` | 9006 | `payment.` subdomain |
| `hospitia-grafana` | 3000 | `grafana.` subdomain |
| `hospitia-postgres` | 5432 | not routed |
| `hospitia-rabbitmq` | 5672, 15672 | not routed |
| `hospitia-nginx` | 80, 443 | public entry point |

HTTPS server blocks are prepared but commented out in the nginx configuration; see [Server setup and deployment](../operations/deployment.md#install-ssl-certificates).
