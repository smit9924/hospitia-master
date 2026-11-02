# Services

Hospitia's backend is split into services by business area. Each service is a separate FastAPI application in `hospitia-backend/services/<service>/` with its own dependencies (`pyproject.toml`, `uv.lock`), configuration (`.env`), database, Docker image and Jenkins pipeline.

## Responsibilities

| Service | Owns | HTTP API | Database | Publishes | Consumes |
|---|---|---|---|---|---|
| [auth](../backend/auth.md) | Users, credentials, roles, tokens, email verification, password reset | Yes | `auth` | User-created events; email messages | — |
| [booking](../backend/booking.md) | Organizations, organization types, memberships, currency units, room amenities, room types, rooms | Yes | `booking` | Requeued or dead-lettered user events | User-created events |
| [dashboard](../backend/dashboard.md) | User listings per role | Yes | `dashboard` | Requeued or dead-lettered user events | User-created events |
| [payment](../backend/payment.md) | Payments (not built yet) | Health check only | `payment` | Requeued or dead-lettered user events | User-created events |
| [notification](../backend/notification.md) | Rendering and sending emails | No | none | Retried or dead-lettered email messages | Email messages |

## Boundaries

- A service reads and writes **only its own database**. When it needs data owned by another service, it keeps a local copy fed by events (the user replica), or the frontend calls the owning service.
- Services trust each other's JWTs because they share the signing secret; they don't call each other over HTTP today.
- Each service keeps its own copy of shared code (messaging client, logging, exception base classes). There is no shared Python package; keep the copies consistent when you change one.

## Shared service anatomy

Every HTTP service has the same package layout and layering; see the [Backend overview](../backend/index.md).

## Ports

| Service | Local dev port | Production container port |
|---|---|---|
| auth | 8000 | 9002 |
| notification | 8002 (VS Code task) | 9003 |
| booking | 8004 | 9004 |
| dashboard | 8005 | 9005 |
| payment | 8006 | 9006 |
| frontend (main client) | 8001 | 9001 |

See [Ports and hostnames](../reference/ports-and-hostnames.md).
