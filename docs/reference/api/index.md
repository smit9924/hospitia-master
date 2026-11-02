# API reference

The API reference is generated from each service's FastAPI OpenAPI document, so it always matches the code it was exported from.

| Service | Page | OpenAPI document |
|---|---|---|
| auth | [Auth API](auth.md) | `docs/reference/api/auth.openapi.json` |
| booking | [Booking API](booking.md) | `docs/reference/api/booking.openapi.json` |
| dashboard | [Dashboard API](dashboard.md) | `docs/reference/api/dashboard.openapi.json` |
| payment | [Payment API](payment.md) | `docs/reference/api/payment.openapi.json` |

The notification service has no HTTP API; its message contracts are in [Messaging and events](../../architecture/messaging.md).

## Conventions

- Every path is under `/api/v1`.
- JSON fields are camelCase.
- Authenticated endpoints expect `Authorization: Bearer <access token>`; organization-scoped booking endpoints also expect `X-Active-Organization-Guid` for owners and managers.
- Errors use the `ApiErrorResponse` shape with an `errorCode`; see [Error codes](../error-codes.md).

## Interactive docs

A running service also serves Swagger UI at `/docs` and the raw document at `/openapi.json`, for example `http://booking.localhost/docs`. Use **Authorize** in Swagger UI with `POST /api/v1/login/access-token` on auth to try authenticated endpoints.

## Regenerating

After changing routes, schemas or dependencies of a service, run:

```bash
bash scripts/export_openapi.sh            # all HTTP services
bash scripts/export_openapi.sh booking    # one service
```

Commit the updated JSON with the code change. The script reads only the committed `.sample.env` of each service (never a real `.env`) and sets `info.title` to name the service; it changes nothing else in FastAPI's output.
