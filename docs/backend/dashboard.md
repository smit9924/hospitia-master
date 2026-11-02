# Dashboard service

The dashboard service serves read-only views for the role dashboards. Today it provides the user listings for admins, owners, managers and customers, built from its own copy of the user data.

| | |
|---|---|
| Code | `hospitia-backend/services/dashboard/` (package `dashboard`) |
| Database | `dashboard` (`usersreplica`) |
| Local port / URL | 8005 / `http://dashboard.localhost` |
| Production container | `dashboard-service`, port 9005 |
| Publishes | Requeued and dead-lettered user-created events |
| Consumes | `dashboard.user.created` |
| API reference | [Dashboard API](../reference/api/dashboard.md) |

## Endpoints

All paths are under `/api/v1`. Each listing is paginated and takes `searchTerm`, `pageSize` (1–100, default 10), `sortBy` (`firstName`, `lastName`, `username`, `email`; default `firstName`), `sortDirection` (`asc`, `desc`) and `pageNumber` (from 1).

| Method | Path | Access | Lists |
|---|---|---|---|
| `GET` | `/users/admins` | Admin | Admins |
| `GET` | `/users/owners` | Admin | Owners |
| `GET` | `/users/managers` | Admin, Owner | Managers |
| `GET` | `/users/customers` | Admin, Owner, Manager | Customers |

The listings aren't scoped to an organization: every caller allowed to see a role sees every user with that role.

## User replica

`handlers/user_handlers.py` consumes `auth.user.created` events and upserts the `usersreplica` row (including the role, which the listings filter on). Failed events are retried up to `USER_CREATED_RETRY_COUNT` times and then moved to the dead-letter queue. See [Messaging and events](../architecture/messaging.md).

## Error codes

dashboard adds `HANDLER_NOT_FOUND` (4001) to the shared 1xxx codes. See [Error codes](../reference/error-codes.md).
