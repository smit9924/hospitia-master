# Backend overview

The backend lives in the [`hospitia-backend`](https://github.com/smit9924/hospitia-backend) repository: five Python 3.13 services built with FastAPI, SQLModel, Alembic and pika, managed with [uv](https://docs.astral.sh/uv/). This page describes what all services share. Each service has its own page:

| Service | Page | Purpose |
|---|---|---|
| auth | [Auth service](auth.md) | Users, sign-in, tokens, roles |
| booking | [Booking service](booking.md) | Organizations and room setup |
| dashboard | [Dashboard service](dashboard.md) | User listings |
| payment | [Payment service](payment.md) | Payments (skeleton) |
| notification | [Notification service](notification.md) | Emails |

## Service anatomy

Every service lives in `backend/services/<service>/` and has the same shape. The application package has the service's name, so auth's code is in `backend/services/auth/auth/`.

```text
services/<service>/
├── <service>/                 # application package
│   ├── main.py                # FastAPI app: lifespan, middleware, CORS, routers, exception handlers
│   ├── api/                   # HTTP layer (not in notification)
│   │   ├── routes/            # endpoints; routes/main.py mounts the routers under /api/v1
│   │   ├── services/          # business logic
│   │   ├── repositories/      # database access
│   │   └── dependencies.py    # SessionDep, RoleValidationDep and other FastAPI dependencies
│   ├── core/config.py         # Settings (pydantic-settings) loaded from .env
│   ├── database/              # SQLModel models, engine, Alembic (alembic.ini, alembic/versions/)
│   ├── doc/                   # OpenAPI error-response examples used by routes
│   ├── exceptions/            # definitions/, handlers/, registry.py
│   ├── handlers/              # message handlers (consumers only)
│   ├── logging/               # logging setup, filters, formatters
│   ├── messaging/             # MQ abstraction + rabbitmq/ implementation
│   ├── middleware/            # RequestContextMiddleware (request ID, log context)
│   ├── schemas/               # Pydantic request/response/message schemas
│   └── types/                 # enums, error codes, constants
├── jenkins/                   # Dockerfile, Jenkinsfile, scripts/ (CI/CD)
├── .sample.env                # local development settings
├── .sample.cloud-dev.env      # cloud-session settings
├── pyproject.toml, uv.lock
└── README.md                  # short pointer to these docs (also packaged by the Docker build)
```

## Layering

```text
API routes → services → repositories → SQLModel models → PostgreSQL
```

- **Routes** validate input (Pydantic schemas), declare access with dependencies, call one service function and return its result. No business rules or queries in routes.
- **Services** hold business rules and orchestrate repositories, messaging and other services.
- **Repositories** own persistence: queries, inserts, updates. Services never build queries themselves.
- **Models** are SQLModel tables in `database/models/`.

See [Backend standards](../standards/backend.md) for the full rules.

## Requests and responses

- All endpoints are mounted under `API_V1_STR` (`/api/v1`).
- JSON uses **camelCase**: schemas extend `BaseSchema`, which sets a camelCase alias generator (`populate_by_name=True`, so Python code uses snake_case).
- Errors share one shape, `ApiErrorResponse`:

    ```json
    {
      "metadata": null,
      "message": "The requested user was not found.",
      "errorCode": 1007
    }
    ```

- Every response carries an `X-Request-ID` header (taken from the request or generated), which also appears in the logs.

## Exceptions

Exceptions follow a central pattern in `exceptions/`:

1. **Define** the exception in `exceptions/definitions/<category>_exceptions.py`, extending the service's `BaseException` with an `ErrorCodes` value and a message.
2. **Handle** it in `exceptions/handlers/<category>_exception(s)_handlers.py`, returning a `JSONResponse` with the right status and an `ApiErrorResponse` body.
3. **Register** the handler in `exceptions/registry.py` (`get_exception_handlers()`), which `main.py` passes to `FastAPI(exception_handlers=...)`.
4. **Document** the response in `doc/<category>_exception(s)_doc.py` and reference it in the route's `responses=`.

Step-by-step: [Exceptions and error codes](../guides/exceptions-and-error-codes.md). All codes: [Error codes](../reference/error-codes.md).

## Configuration

Each service reads its settings from `services/<service>/.env` through `core/config.py` (`Settings`, pydantic-settings). Required settings have no default, so a missing value stops the service at startup. Never hard-code environment-specific values or secrets in code. See [Configuration](../reference/configuration.md).

## Logging

`logging/` configures Python logging from `LOG_LEVEL`, `LOG_FORMAT` and `LOG_RETENTION_DAYS`:

- **Local** (`ENVIRONMENT=local`, `LOG_FORMAT=console`): readable console logs plus daily rotating files under `services/<service>/bin/logs/`.
- **Production** (`ENVIRONMENT=production`, `LOG_FORMAT=json`): JSON to stdout only; Grafana Alloy ships it to Loki. Don't write log files in production.

`RequestContextMiddleware` adds the request ID and context to every log line. Use `log = logging.getLogger(__name__)`; never `print` (ruff rule `T201`).

## Messaging

Publish and consume only through the messaging abstraction. See [Messaging and events](../architecture/messaging.md).

## Running, linting and testing

```bash
cd backend/services/<service>
uv sync
uv run uvicorn <service>.main:app --reload --reload-dir <service> --port <port>
uv run ruff check .          # lint (configured in pyproject.toml)
```

There's currently no automated backend test suite; see [Testing and linting](../guides/testing-and-linting.md).

## Adding a new service

1. Copy the closest existing service (booking for an HTTP service with a database and consumer; notification for a consumer without HTTP API) and rename the package.
2. Pick the next free ports (local dev and production) and add the database to both `01_create_database.sql` files.
3. Add routing: a site in `.devcontainer/nginx/conf.d/` (cloud sessions read its `*.localhost` name automatically) and in `server-setup/nginx/conf.d/`, and the origin/URL in the frontend `environments/` if the frontend calls it.
4. Add CI/CD: `services/<service>/jenkins/`, and `jenkins/job-dsl/backend/<service>.groovy` listed in `jenkins/casc/jobs.yaml`.
5. Add VS Code tasks and launch configuration, and the service to `scripts/export_openapi.sh` if it has an HTTP API.
6. Document it: a page in `docs/backend/`, the nav in `mkdocs.yml`, [Services](../architecture/services.md), [Ports and hostnames](../reference/ports-and-hostnames.md), and an agent rule in `.agents/rules/`.
