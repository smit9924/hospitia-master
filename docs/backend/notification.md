# Notification service

The notification service sends emails. It has no HTTP API: its entry points are message handlers that consume email messages from RabbitMQ, render a Jinja template and send the result over SMTP.

| | |
|---|---|
| Code | `hospitia-backend/services/notification/` (package `notification`) |
| Database | none |
| Local port | 8002 in the VS Code task / launch configuration (no HTTP routes, not routed by nginx) |
| Production container | `notification-service`, port 9003 |
| Consumes | `forgot_password_email_queue`, `verify_email_otp_email_queue`, `welcome_email_queue` |
| Publishes | Retried and dead-lettered email messages |

## Flow

```text
auth → email_notifications_exchange → queue → handler → template_service (Jinja) → email_service (SMTP)
```

| Queue | Handler | Template | Message schema |
|---|---|---|---|
| `forgot_password_email_queue` | `forgot_password_email_handler` | `forgot_password_email.html` | `MqForgotPasswordMessage` |
| `verify_email_otp_email_queue` | `verify_email_otp_email_handler` | `verify_email_otp_email.html` | `MqVerifyEmailOtpMessage` |
| `welcome_email_queue` | `welcome_email_handler` | `welcome_email.html` | `MqWelcomeEmailMessage` |

Handlers are registered by queue name in `handlers/handler_routes.py`. Each handler validates the message against its schema, renders the template with the message data and sends it with `send_html_email`.

## Package map

```text
notification/
├── core/          # settings
├── handlers/      # queue consumers (entry points) and handler_routes.py
├── services/      # template_service.py (Jinja), email_service.py (SMTP)
├── templates/     # base.html and one template per email
├── messaging/     # MQ abstraction (client and consumer) + rabbitmq/
├── channels/      # placeholder for future delivery channels (empty today)
├── exceptions/    # definitions and handler exception handlers (retry / dead letter)
├── schemas/       # message schemas
└── types/         # enums
```

## Templates

Templates live in `notification/templates/` and extend `base.html`. They're rendered with Jinja autoescaping for HTML. Keep email content in templates, not in Python code. See [Email templates](../guides/email-templates.md).

## Retries and dead letters

When a handler fails, the message is republished with `retry_count + 1` up to the queue's `*_EMAIL_RETRY_COUNT` (3 in the samples), then moved to the queue's dead-letter queue (`forgot_password_dead_letter_email_queue` and so on).

## SMTP

`SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_USE_TLS` and `SMTP_FROM` configure delivery. Locally they point to Mailpit, which catches every email; see [PgAdmin, Mailpit and RabbitMQ](../guides/dev-tools.md).

## Manual test publisher

`notification/test_publish_email.py` is a small developer script that publishes a test message with pika directly. It's a local testing aid, not part of the service.
