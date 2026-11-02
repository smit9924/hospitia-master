# Debugging

## Backend services in VS Code

`.vscode/launch.json` has a **Python Debug** configuration per service: **Python Debug: Auth** (port 8000), **Notification** (8002), **Booking** (8004), **Payment** (8006) and **Dashboard** (8005). Each runs `uvicorn <service>.main:app --reload --reload-dir <service>` from the service folder, so breakpoints work in routes, services, repositories and message handlers.

Stop the same service if it's already running from a terminal or task, since the port would be taken.

## Follow a request through the logs

Every response has an `X-Request-ID` header; every log line written while handling that request carries the same ID. Copy the ID from the browser's network tab and search the service's console output (or `services/<service>/bin/logs/` locally, or Grafana in production) for it.

Turn up detail with `LOG_LEVEL=DEBUG` in the service's `.env` and restart it.

## Frontend

- Use the browser's developer tools: the **Network** tab shows each API call, its `Authorization` and `X-Active-Organization-Guid` headers, and the `errorCode` of failed calls.
- Angular DevTools (browser extension) shows the component tree and signal values.
- Unexpected errors go through `GlobalErrorHandler` (`src/app/error/global-error-handler.ts`); check the browser console.

## Messages and emails

- **RabbitMQ management UI:** see whether messages are waiting, being consumed, or in a dead-letter queue. You can view and republish messages there.
- **Mailpit:** see every email the app sent, including HTML and headers.

See [PgAdmin, Mailpit and RabbitMQ](dev-tools.md).

## Database

Inspect data in PgAdmin, or with `psql`:

```bash
docker exec -it webapp-postgres psql -U postgres -d booking
```
