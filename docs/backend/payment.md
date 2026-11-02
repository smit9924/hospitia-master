# Payment service

The payment service will own payments for bookings. Today it's a skeleton: it has its database, keeps a user replica in sync, and exposes a health check, so payment features can be added without new infrastructure.

| | |
|---|---|
| Code | `hospitia-backend/services/payment/` (package `payment`) |
| Database | `payment` (`usersreplica`) |
| Local port / URL | 8006 / `http://payment.localhost` |
| Production container | `payment-service`, port 9006 |
| Publishes | Requeued and dead-lettered user-created events |
| Consumes | `payment.user.created` |
| API reference | [Payment API](../reference/api/payment.md) |

## Endpoints

| Method | Path | Access | Purpose |
|---|---|---|---|
| `GET` | `/api/v1/login/health-check` | Public | Returns an empty response when the service is up. |

## User replica

`handlers/user_handlers.py` consumes `auth.user.created` events and upserts the `usersreplica` row, retrying failed events up to `USER_CREATED_RETRY_COUNT` times before dead-lettering them. See [Messaging and events](../architecture/messaging.md).

## Error codes

payment adds `HANDLER_NOT_FOUND` (3001) to the shared 1xxx codes. See [Error codes](../reference/error-codes.md).

## Building payment features

Follow the [service anatomy](index.md#service-anatomy) and the booking service as the closest example: routes in `api/routes/`, business rules in `api/services/`, queries in `api/repositories/`, models and an Alembic migration in `database/`, and new error codes in the 3xxx range.
