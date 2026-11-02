# Architecture standards

Rules that keep Hospitia's structure consistent. The [Architecture](../architecture/index.md) section explains the design behind them.

## Repositories and apps

- **Multi-repo:** `frontend/` and `backend/` are separate Git repositories under `hospitia-master`. Workspace, infrastructure, CI/CD, docs and agent rules belong in `hospitia-master`.
- **Multiple frontend apps:** new Angular applications belong under `frontend/clients/`.
- **Service-oriented backend:** backend domains are separated into independent services, each with its own database. A service never reads or writes another service's database; it uses events (for example the user replica) or the owning service's API.

## Layering

- **Backend:** `API → Services → Repositories → Database`. Keep business and persistence logic out of route handlers. See [Backend standards](backend.md#layering).
- **Frontend:** components call services; services call the API through `HttpClient` with URLs from `data/api-routes.ts`. See [Frontend standards](frontend-angular.md).

## Cross-cutting concerns

- **Messaging abstraction:** use the project's MQ abstraction (`messaging/`, `get_mq_client()`); keep RabbitMQ-specific code inside its implementation layer (`messaging/rabbitmq/`).
- **Centralized exceptions:** follow the existing service-level exception definition → handler → registration pattern. See [Exceptions and error codes](../guides/exceptions-and-error-codes.md).
- **Configuration separation:** keep environment-specific configuration outside business logic; never hard-code secrets or environment-specific values.

## Internal APIs

- Internal-only endpoints **must** validate that the request comes from a loopback address (`127.0.0.0/8` or `::1`), as `InternalRequestDep` does in auth.
- They **must not** require JWT or role validation.
- `UserType.INTERNALE` is reserved for internal service-account data. It **must not** be included in public role lists or assigned through public sign-up or user-provisioning flows.

## Reliability

- Events that must not be lost when a database change commits are written to an outbox in the same transaction and published by a worker (see the auth outbox).
- Message consumers are idempotent and declare a dead-letter queue and a retry limit.

## Recording decisions

A change that alters one of these rules, adds a service, or introduces a new cross-cutting pattern needs an [architecture decision record](../adr/index.md).
