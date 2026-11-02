# Booking service

The booking service owns organizations and everything needed to describe a guest house: organization types, organizations and their addresses, memberships of owners and managers, currency units, room amenities, room types and rooms. Guest bookings themselves are on the [roadmap](../about/roadmap.md).

| | |
|---|---|
| Code | `hospitia-backend/services/booking/` (package `booking`) |
| Database | `booking` (see [Data and databases](../architecture/data.md#booking-data-model)) |
| Local port / URL | 8004 / `http://booking.localhost` |
| Production container | `booking-service`, port 9004 |
| Publishes | Requeued and dead-lettered user-created events |
| Consumes | `booking.user.created` (dead-letter queue `booking.user.created.dlq`) |
| API reference | [Booking API](../reference/api/booking.md) |

## Endpoints

All paths are under `/api/v1`. Conventions:

- Create and update endpoints take a JSON body; update bodies carry the record's `guid`.
- Detail and delete endpoints take `guid` as a query parameter, except `GET /organization/{guid}` and `GET /organization-type/{guid}`, which take it in the path.
- Paginated listings take `searchTerm`, `pageSize`, `sortBy`, `sortDirection` and `pageNumber`.

### Organization types

| Method | Path | Access |
|---|---|---|
| `POST` / `PUT` | `/organization-type/create` | Admin (create or update) |
| `DELETE` | `/organization-type/delete` | Admin |
| `GET` | `/organization-type` | Admin, Owner |
| `GET` | `/organization-type/{guid}` | Admin |

### Organizations and memberships

| Method | Path | Access | Purpose |
|---|---|---|---|
| `POST` / `PUT` | `/organization/create-by-admin` | Admin | Create or update any organization |
| `POST` / `PUT` | `/organization/create-by-owner` | Owner | Create or update the owner's organization |
| `DELETE` | `/organization/delete` | Admin, Owner | Deactivate an organization |
| `GET` | `/organization/list-for-admin` | Admin | All organizations |
| `GET` | `/organization/list-for-owner` | Admin, Owner | Organizations of an owner |
| `GET` | `/organization/manager` | Admin, Owner, Manager | Organizations of a manager |
| `POST` / `PUT` | `/organization/admin` | Admin | Admin membership |
| `POST` / `PUT` | `/organization/owner` | Admin | Map an owner to an organization |
| `POST` / `PUT` | `/organization/manager` | Admin, Owner | Map a manager to an organization |
| `GET` | `/organization/memberships` | Owner, Manager | Active organizations of the caller (no header needed) |
| `GET` | `/organization/active` | Owner, Manager | Validate and return the [active organization](../architecture/active-organization.md) |
| `GET` | `/organization/{guid}` | Admin, Owner, Manager | One organization |

### Currency units

| Method | Path | Access |
|---|---|---|
| `POST` | `/currency-unit/create` | Admin |
| `PUT` | `/currency-unit/update` | Admin |
| `DELETE` | `/currency-unit/delete` | Admin |
| `GET` | `/currency-unit`, `/currency-unit/detail` | Admin |
| `GET` | `/currency-unit/options` | Admin, Owner, Manager (for pickers) |

### Room amenities, room types and rooms

These endpoints are shared by admins and organization members (`OrganizationScopedActorDep` with Admin, Owner, Manager): admins choose the organization with `organizationGuid`; owners and managers always act on their active organization.

| Resource | Endpoints |
|---|---|
| Room amenities | `POST /room-amenity/create`, `PUT /room-amenity/update`, `DELETE /room-amenity/delete`, `GET /room-amenity`, `GET /room-amenity/detail`, `GET /room-amenity/selectable` (every amenity a room type may use: defaults plus the organization's own, not paginated) |
| Room types | `POST /room-type/create`, `PUT /room-type/update`, `DELETE /room-type/delete`, `GET /room-type`, `GET /room-type/detail`, `GET /room-type/options` |
| Rooms | `POST /room/create`, `PUT /room/update`, `DELETE /room/delete`, `GET /room`, `GET /room/detail` |

Rules worth knowing:

- Admins create **default** amenities (no organization) or custom amenities for a chosen organization; owners and managers create custom amenities for their active organization and can't modify defaults (`ROOM_AMENITY_MODIFICATION_FORBIDDEN`, 2020).
- A room type can only use amenities available to its organization (`ROOM_TYPE_AMENITY_NOT_AVAILABLE`, 2023); a room can only use a room type of its organization (`ROOM_TYPE_NOT_AVAILABLE_FOR_ROOM`, 2028).
- Records in use can't be removed: `CURRENCY_UNIT_IN_USE`, `ROOM_AMENITY_IN_USE`, `ROOM_TYPE_IN_USE`.

## Active organization

Owners and managers work within one **active organization** per login session. The client stores the selection and sends it on every booking request in the `X-Active-Organization-Guid` header (`booking.types.constants.ACTIVE_ORGANIZATION_HEADER`). The backend never trusts that value without validating it.

To scope an endpoint to the active organization, depend on `ActiveOrganizationDep` (`booking.api.dependencies`); for endpoints admins also use, depend on `OrganizationScopedActorDep`. Details, examples and error codes: [Active organization](../architecture/active-organization.md).

## User replica

`handlers/user_handlers.py` consumes `auth.user.created` events from `booking.user.created` and upserts the `usersreplica` row. Failed events are retried up to `USER_CREATED_RETRY_COUNT` times and then moved to `booking.user.created.dlq` (`exceptions/handlers/consumer_exception_handlers.py`).

### Managers created with an organization

The auth service's user-created event carries `organization_guid` and `created_by_guid` when a manager is provisioned. `user_created_handler` upserts the replica, then maps the manager to that organization if it exists, is active, and the creator is an admin or an active owner of it. Otherwise the mapping is skipped with a warning and an admin can map the manager later through `POST /organization/manager`.

## Reference data

`booking/database/reference_data/` keeps source files for reference. They aren't loaded at runtime.

| File | Source | Content | Published |
|---|---|---|---|
| `iso_4217_currency_codes_list_one_by_www.six-group.com.xls` | [www.six-group.com](https://www.six-group.com/en/products-services/financial-information/market-reference-data/data-standards.html) (ISO 4217 Maintenance Agency) | ISO 4217 List One: current currency, fund and precious metal codes (entity, currency name, alphabetic code, numeric code, minor unit) | 2026-01-01 |

The `currency_units` seed migration takes its values from this file. Only a subset of currencies is seeded; admins add any others through the app.

## Error codes

booking uses codes 2001–2029 (and the shared 1xxx codes). See [Error codes](../reference/error-codes.md).
