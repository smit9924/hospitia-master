# Architecture

This section explains how Hospitia is built and why. Read it before making a change that crosses a service boundary or adds a new pattern.

## System overview

Hospitia is an Angular single-page app talking to several FastAPI services. Each service owns its own Postgres database. Services share data through events on RabbitMQ, never by reading another service's database.

```mermaid
flowchart LR
    browser["Browser<br/>Angular app (clients/main)"]
    nginx["nginx<br/>*.localhost / subdomains"]

    subgraph services["Backend services (FastAPI)"]
        auth["auth<br/>users, login, tokens, outbox"]
        booking["booking<br/>organizations, rooms"]
        dashboard["dashboard<br/>user listings"]
        payment["payment<br/>(health check)"]
        notification["notification<br/>emails (no HTTP API)"]
    end

    subgraph data["Postgres (one database per service)"]
        authdb[(auth)]
        bookingdb[(booking)]
        dashboarddb[(dashboard)]
        paymentdb[(payment)]
    end

    mq{{"RabbitMQ<br/>user_events_exchange (topic)<br/>email_notifications_exchange (direct)"}}
    smtp["SMTP<br/>(Mailpit locally)"]

    browser --> nginx
    nginx --> auth & booking & dashboard & payment
    auth --- authdb
    booking --- bookingdb
    dashboard --- dashboarddb
    payment --- paymentdb
    auth -- "user created events, emails" --> mq
    mq -- "user created" --> booking & dashboard & payment
    mq -- "emails" --> notification
    booking -- "requeue / dead-letter" --> mq
    notification --> smtp
```

## Key ideas

| Idea | Summary | Read more |
|---|---|---|
| Multi-repo workspace | `hospitia-master` holds the workspace and docs; frontend and backend are separate repositories nested inside it. | [Workspace and repositories](workspace.md) |
| Service per business area | auth, booking, dashboard, payment and notification are independent apps with their own database and deployment. | [Services](services.md) |
| Stateless JWT auth | auth issues JWTs; every service validates them with the shared secret and checks the role. | [Authentication and roles](auth-and-roles.md) |
| Events, not shared tables | auth publishes user-created events from a transactional outbox; other services keep a user replica. | [Messaging and events](messaging.md) |
| Database per service | Postgres with one database per service, schema changes through Alembic. | [Data and databases](data.md) |
| Active organization | Owners and managers work in one organization at a time, sent as a header and validated by booking. | [Active organization](active-organization.md) |
| Layered code | Routes → services → repositories → models in every backend service; components → services → API in the frontend. | [Backend](../backend/index.md), [Frontend architecture](frontend.md) |

## Decisions

The reasons behind these choices are recorded as [Architecture decision records](../adr/index.md).
