# Configuration

Every setting Hospitia reads, by **name and purpose**. Values live in `.env` files that are never committed; the committed `.sample.env` (local) and `.sample.cloud-dev.env` (cloud sessions) files show the expected keys with local-development values.

!!! warning "Rules for configuration"
    - Never commit a `.env` file or a real secret, and never put one in docs or rules.
    - When you add or change a key in a `.sample.env`, make the same change in the `.sample.cloud-dev.env` next to it, and update this page.
    - Backend settings are declared in `<service>/core/config.py`. Settings without a default are required: a missing value stops the service at startup.

## Backend services

Each service reads `backend/services/<service>/.env`.

### Common to all services

| Setting | Purpose |
|---|---|
| `ENVIRONMENT` | `local` or `production`. `local` enables development shortcuts in auth (verified emails, default password) and file logging. **Never `local` on a shared or production server.** |
| `SERVICE_NAME` | Name used in logs. |
| `LOG_LEVEL` | `DEBUG`, `INFO`, `WARNING`, `ERROR` or `CRITICAL`. |
| `LOG_FORMAT` | `console` (local) or `json` (production; stdout only, shipped to Loki). |
| `LOG_RETENTION_DAYS` | Days of rotated log files kept locally. |
| `MQ_CLIENT_TYPE` | Which messaging implementation `get_mq_client()` returns (RabbitMQ). |
| `RABBITMQ_HOST`, `RABBITMQ_PORT` | Broker address. |
| `RABBITMQ_USERNAME`, `RABBITMQ_PASSWORD` | Broker credentials. |
| `RABBITMQ_HEART_BEAT`, `RABBITMQ_CONNECTION_TIMEOUT` | Connection heartbeat and timeout. |
| `RABBITMQ_RETRY_ATTEMPTS`, `RABBITMQ_RETRY_DELAY` | Connection attempts and delay. |
| `RABBITMQ_PUBLISH_RETRY_ATTEMPTS`, `RABBITMQ_PUBLISH_RETRY_DELAY` | Publish retries and delay. |
| `EMAIL_NOTIFICATION_EXCHANGE`, `EMAIL_NOTIFICATION_EXCHANGE_TYPE` | Email exchange name and type (`direct`). |
| `FORGOT_PASSWORD_EMAIL_QUEUE`, `FORGOT_PASSWORD_EMAIL_QUEUE_ROUTING_KEY` | Forgot-password email queue. |

### HTTP services (auth, booking, dashboard, payment)

| Setting | Purpose |
|---|---|
| `ALLOWED_ORIGINS`, `ALLOWED_CREDENTIALS`, `ALLOWED_METHODS`, `ALLOWED_HEADERS` | CORS. Locally the only origin is `http://main-client.localhost`. |
| `POSTGRES_SERVER`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` | The service's own database. |
| `JWT_ENCRYPTION_ALGORITHM`, `JWT_ENCRYPTION_SECRET_KEY` | JWT signing; must be identical in all four services. |
| `USER_EVENTS_EXCHANGE`, `USER_EVENTS_EXCHANGE_TYPE` | User events exchange (`topic`). |
| `FRONTEND_BASE_URL` | Base URL of the frontend, used for links in emails. |

### auth only

| Setting | Purpose |
|---|---|
| `JWT_ACCESS_TOKEN_EXPIRE_MINUTES` | Access token lifetime. |
| `JWT_REFRESH_TOKEN_EXPIRE_MINUTES` | Refresh token lifetime. |
| `JWT_REFRESH_TOKEN_EXPIRE_MINUTES_REMEMBER_ME` | Refresh token lifetime with "remember me". |
| `PASSWORD_RESET_TOKEN_EXPIRE_MINUTES` | Password reset link lifetime. |
| `VERIFY_EMAIL_OTP_TIMEOUT` | Email verification code lifetime (minutes). |
| `VERIFY_EMAIL_OTP_EMAIL_QUEUE`, `…_ROUTING_KEY` | Verification email queue. |
| `WELCOME_EMAIL_QUEUE`, `…_ROUTING_KEY` | Welcome email queue. |
| `USER_CREATED_EVENT_TYPE`, `USER_CREATED_ROUTING_KEY` | User-created event type and routing key (`auth.user.created`). |
| `BOOKING_USER_CREATED_QUEUE`, `DASHBOARD_USER_CREATED_QUEUE`, `PAYMENT_USER_CREATED_QUEUE` (each with `…_ROUTING_KEY`) | Subscriber queues auth declares so events persist while subscribers are down. |
| `OUTBOX_POLL_INTERVAL_SECONDS`, `OUTBOX_BATCH_SIZE` | Outbox worker polling interval (default 2) and batch size (default 50). Optional; not in the samples. |

### Consumers (booking, dashboard, payment, notification)

| Setting | Purpose |
|---|---|
| `RABBITMQ_CONSUMER_RETRY_DELAY` | Delay before a consumer reconnects. |
| `RABBITMQ_CONSUMER_PREFETCH_COUNT` | Messages a consumer takes at a time. |

### booking, dashboard, payment

| Setting | Purpose |
|---|---|
| `USER_CREATED_QUEUE`, `USER_CREATED_QUEUE_ROUTING_KEY` | This service's user-created queue. |
| `USER_CREATED_DEAD_LETTER_QUEUE`, `…_ROUTING_KEY` | Its dead-letter queue. |
| `USER_CREATED_RETRY_COUNT` | Retries before dead-lettering. |

### notification only

| Setting | Purpose |
|---|---|
| `VERIFY_EMAIL_OTP_EMAIL_QUEUE`, `WELCOME_EMAIL_QUEUE` (each with `…_ROUTING_KEY`) | Email queues it consumes (plus the common forgot-password queue). |
| `FORGOT_PASSWORD_DEAD_LETTER_EMAIL_QUEUE`, `VERIFY_EMAIL_OTP_DEAD_LETTER_EMAIL_QUEUE`, `WELCOME_DEAD_LETTER_EMAIL_QUEUE` (each with `…_ROUTING_KEY`) | Dead-letter queues. |
| `FORGOT_PASSWORD_EMAIL_RETRY_COUNT`, `VERIFY_EMAIL_OTP_EMAIL_RETRY_COUNT`, `WELCOME_EMAIL_RETRY_COUNT` | Retries before dead-lettering. |
| `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_USE_TLS`, `SMTP_FROM` | Outgoing mail server (Mailpit locally). |

## Frontend (`clients/main/src/environments/`)

`environment.ts` (development) and `environment.prod.ts` (production build):

| Key | Purpose |
|---|---|
| `production`, `tag`, `version` | Build flags and version label. |
| `authServiceBaseUrl`, `bookingServiceBaseUrl`, `dashboardServiceBaseUrl` | API base URLs, including `/api/v1`. |
| `forgotPasswordResendTimeoutSeconds`, `emailVerificationResendTimeoutSeconds` | Cool-down before the user can request another email. |
| `enableOwnerSignup` | Shows the owner tab on the sign-up page. |
| `accountSetupMaxRetries`, `accountSetupRetryIntervalSeconds` | How long to wait for a new account to reach the booking service. |

## Workspace and infrastructure

| File | Keys (purpose) |
|---|---|
| `.devcontainer/.env` (from `.sample.env` / `.sample.cloud-dev.env`) | `project_name` (container name prefix, `webapp`); `RABBITMQ_DEFAULT_USER`, `RABBITMQ_DEFAULT_PASS` (broker account); `MP_*` (Mailpit storage, message limit, UI and SMTP authentication) |
| `.devcontainer/postgres/.default_db_config.env` | `POSTGRES_USER`, `POSTGRES_PASSWORD`, `PGADMIN_DEFAULT_EMAIL`, `PGADMIN_DEFAULT_PASSWORD` (local only; optional `.override_db_config.env` overrides them) |
| `jenkins/.env` (from `.sample.env`) | See [CI/CD with Jenkins](../operations/ci-cd.md#configure-environment-variables) |
| `server-setup/.env` (from `.sample.env`) | See [Server setup and deployment](../operations/deployment.md#configure-environment-variables) |
| `/opt/hospitia/<container>/.env` on the server | Production settings of each deployed service, with the backend keys above |
