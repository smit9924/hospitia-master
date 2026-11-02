# Running the app

This page shows how to start the backend services and the frontend once your [workspace is set up](index.md). Paths are relative to the workspace root (`/workspace` in the dev container, `hospitia-master/` in a cloud session).

## Backend services

Each service is a separate FastAPI app with its own virtual environment. Start the ones you need, each in its own terminal:

```bash
cd backend/services/<service>
uv run uvicorn <service>.main:app --reload --reload-dir <service> --port <port>
```

| Service | Port | Routed as | Needed for |
|---|---|---|---|
| auth | 8000 | `http://auth.localhost` | Sign-in, sign-up, users. Also runs the outbox worker. |
| booking | 8004 | `http://booking.localhost` | Organizations, room setup. |
| dashboard | 8005 | `http://dashboard.localhost` | User listings. |
| payment | 8006 | `http://payment.localhost` | Health check only, today. |
| notification | 8002 (VS Code) or any free port | not routed | Sending emails. It has no HTTP API; it only consumes messages. |

In VS Code you can also use the tasks **service : auth**, **service : booking** and so on, or the **Python Debug: …** launch configurations (see [Debugging](../guides/debugging.md)).

!!! tip "Which services to start"
    For the [Product tour](../tutorials/product-tour.md) start auth, booking, dashboard and notification. Every service except notification serves `GET /docs` (Swagger UI), for example `http://auth.localhost/docs`.

Each service connects to RabbitMQ on startup (retrying `RABBITMQ_RETRY_ATTEMPTS` times) and fails to start if it still can't. Make sure the infrastructure containers are running.

## Frontend

```bash
cd frontend/clients/main
npm ci        # first time, or after package-lock.json changes
npm start     # ng serve on 0.0.0.0:8001
```

Open **http://main-client.localhost**. The app calls the services through `http://auth.localhost/api/v1`, `http://booking.localhost/api/v1` and `http://dashboard.localhost/api/v1` (`src/environments/environment.ts`), and the backend CORS settings only allow the `http://main-client.localhost` origin, so use the hostname rather than `localhost:8001`.

## Create the first admin

There's no admin until you create one. Creating an admin uses an [internal API](../architecture/auth-and-roles.md#internal-apis) that only accepts requests from the same machine. With auth running:

```bash
curl -X POST http://localhost:8000/api/v1/users/internal/admins \
  -H 'Content-Type: application/json' \
  -d '{"firstName": "Super", "lastName": "Admin", "email": "admin@example.com", "username": "admin"}'
```

With `ENVIRONMENT=local` (the sample setting) the new admin's email is already verified and the password is `Password@123`. The welcome email, with the same password, appears in Mailpit when the notification service is running.

## Next step

[Local services and credentials](local-services.md), then the [Product tour](../tutorials/product-tour.md).
