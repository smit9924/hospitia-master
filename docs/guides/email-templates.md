# Email templates

Emails are rendered by the [notification service](../backend/notification.md) from Jinja templates in `backend/services/notification/notification/templates/`. This guide changes or adds one.

## Change an existing email

1. Edit the template (`forgot_password_email.html`, `verify_email_otp_email.html` or `welcome_email.html`). Each extends `base.html` and fills `{% block content %}`.
2. Use only the variables in the message schema (`MqForgotPasswordMessage`, `MqVerifyEmailOtpMessage`, `MqWelcomeEmailMessage` in `schemas/mq_schemas.py`); the handler passes `message.model_dump()` to the template.
3. Restart the notification service, trigger the email (for example **Forgot password** in the app) and check it in Mailpit ([http://localhost:8025](http://localhost:8025)).

## Add a new email

1. **Publisher (usually auth):** add the queue and routing-key settings, declare the queue on the email exchange, define the message schema, and publish it from the service layer. See [Publishing and consuming messages](messaging.md).
2. **notification:**
    - add the same settings plus a dead-letter queue and `<NAME>_EMAIL_RETRY_COUNT` to `core/config.py`, `.sample.env` and `.sample.cloud-dev.env`;
    - declare the queue in the consumer;
    - add the message schema to `schemas/mq_schemas.py`;
    - add a handler in `handlers/email_handlers.py` that validates the message, calls `render_template("<name>.html", data.model_dump())` and `send_html_email(to=..., subject=..., body=html)`;
    - register it in `handlers/handler_routes.py` and add its retry/dead-letter exception handler.
3. **Template:** add `<name>.html` extending `base.html`.

## Template rules

- Keep content in templates, not in Python strings.
- Templates are autoescaped; don't mark user-provided values as safe.
- Use inline styles and tables suitable for email clients, like the existing templates; email clients ignore most CSS.
- Write a clear subject and a plain explanation of why the user received the email.
- Never include secrets other than what the email is for (the welcome email intentionally contains the initial password).
