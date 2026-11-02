# Troubleshooting

Common problems when setting up or running Hospitia locally, and how to fix them.

## A `*.localhost` URL returns 502 Bad Gateway

nginx is running but the dev server behind that hostname isn't. Start it (see [Running the app](running-the-app.md)). For example, `http://booking.localhost` needs the booking service on port 8004.

## The browser shows a CORS error

Open the app at `http://main-client.localhost`, not `http://localhost:8001`. The services only allow the `http://main-client.localhost` origin (`ALLOWED_ORIGINS` in each service's `.env`).

## A service exits on startup with a RabbitMQ connection error

Every service connects to RabbitMQ at startup. Check that the RabbitMQ container is running (`docker ps`) and that `RABBITMQ_HOST` in the service's `.env` is right: `${project_name}-rabbitmq` in the dev container (the sample value, which resolves to `webapp-rabbitmq`), `localhost` in a cloud session.

## A service fails with a pydantic `SettingsError` or "field required"

The service's `.env` is missing or lacks a key. Copy `.sample.env` to `.env` (or compare them and add the missing keys). Settings have no defaults on purpose, so a missing value fails loudly.

## The dev container won't start: `.env` not found

`.devcontainer/.env` is required. Create it with `cp .devcontainer/.sample.env .devcontainer/.env`.

## Database errors such as "relation does not exist"

Migrations haven't been applied. Run `uv run alembic -c ./<service>/database/alembic.ini upgrade head` in `backend/services/<service>`, or the **Migrate : <service>** VS Code task.

## No email arrives

- Make sure the notification service is running. It consumes the email queues.
- Open Mailpit ([http://localhost:8025](http://localhost:8025)): all local email is caught there, nothing is delivered to real inboxes.
- In RabbitMQ's management UI, check whether messages are piling up in the email queues or have moved to a dead-letter queue.

## Owners or managers see "account setup failed" right after sign-up

The booking service learns about new users through an event. If booking (or RabbitMQ) wasn't running when the user signed up, the event waits in the queue until booking starts. Start booking and try again. The frontend retries for a short time while the account is being set up (`accountSetupMaxRetries` in `environment.ts`).

## Cloud session: the bootstrap script failed

Read the message: the script names the missing command, the busy port or the failing service and prints its container logs. Fix that cause and run it again. See [Claude Code cloud sessions](cloud-sessions.md).

## `npm` or `ng` not found in a cloud session

Run `export PATH=/opt/node20/bin:$PATH` first.

Still stuck? See [Support](../community/support.md).
