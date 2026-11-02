# PgAdmin, Mailpit and RabbitMQ

The dev container (and cloud sessions) run three tools next to the app. Addresses and local credentials are on [Local services and credentials](../getting-started/local-services.md).

## PgAdmin: browse the databases

1. Open [http://localhost:8080](http://localhost:8080) and sign in as `developer@domain.com` / `password`.
2. The Postgres server is already registered (`.devcontainer/postgres/servers.json`). If PgAdmin asks for the database password, enter `password`.
3. Expand **Databases** to see `auth`, `booking`, `dashboard` and `payment`, then **Schemas → public → Tables**.

Use it to check what a migration created or what an API call stored. Don't fix data by hand in a way the app couldn't reproduce; fix the code or write a migration.

## Mailpit: see every email

Mailpit is the SMTP server the notification service uses locally. It accepts every email and delivers none, so nobody receives test emails.

- Web UI: [http://localhost:8025](http://localhost:8025) or [http://mailpit.localhost](http://mailpit.localhost), user `developer`, password `password`.
- Use it to read OTP codes, password-reset links and welcome emails, and to check how templates render.

## RabbitMQ: inspect queues

- Management UI: [http://localhost:15672](http://localhost:15672), user `developer`, password `password`.
- **Exchanges:** `user_events_exchange` (topic) and `email_notifications_exchange` (direct), with their bindings.
- **Queues:** the `*.user.created` queues, the three email queues and their dead-letter queues. A growing **Ready** count means no consumer is running for that queue; messages in a dead-letter queue failed every retry.
- From a queue's page you can **Get messages** to look at the payload, or purge a queue you filled during testing.
