# Your first backend endpoint

In this tutorial you'll add `GET /api/v1/room/status-summary` to the booking service: the number of active rooms in each status (available, under maintenance, out of service) for the caller's organization. Along the way you'll touch every backend layer, apply the access rules, and update the API reference. It takes about 40 minutes.

!!! info "Exercise"
    Work on a throwaway branch in `hospitia-backend`. This endpoint isn't part of the product; delete the branch when you're done.

## Before you start

- Complete the [Product tour](product-tour.md), so you have an owner with rooms.
- Read [Backend overview](../backend/index.md#layering) and [Active organization](../architecture/active-organization.md).

The files you'll change, all under `backend/services/booking/booking/`:

```text
schemas/room_schemas.py           # 1. response schema
api/repositories/room_repository.py   # 2. query
api/services/room_service.py          # 3. business rule (scoping)
api/routes/room.py                    # 4. endpoint and access control
```

## 1. Define the response schema

Responses are Pydantic schemas extending `BaseSchema`, which serializes fields as camelCase. Add to `schemas/room_schemas.py`:

```python
class RoomStatusSummaryResponse(BaseSchema):
    """Number of active rooms per status."""

    available: int
    under_maintenance: int
    out_of_service: int
```

## 2. Query in the repository

Repositories own the database queries. Add to `api/repositories/room_repository.py`, next to the other room queries:

```python
def count_active_rooms_by_status(*, session: Session, organization_id: int | None) -> dict[RoomStatus, int]:
    """Count active rooms per status.

    Parameters
    ----------
    session : Session
        Active database session.
    organization_id : int | None
        Internal ID of the organization, or ``None`` for every organization.

    Returns
    -------
    dict[RoomStatus, int]
        Number of active rooms for each status that has at least one room.
    """
    statement = select(Room.status, func.count()).where(col(Room.is_active).is_(True))
    if organization_id is not None:
        statement = statement.where(Room.organization_id == organization_id)
    statement = statement.group_by(Room.status)
    return {status: count for status, count in session.exec(statement).all()}
```

Notice the scalar `organization_id` column on `Room`: the [backend standards](../standards/backend.md#models-and-migrations) require it next to every relationship precisely so queries like this can filter on it directly.

## 3. Apply the business rule in the service

Services decide *what* the caller may see. Admins see every organization; owners and managers only their active organization. Follow `list_rooms` in `api/services/room_service.py`:

```python
def get_room_status_summary(*, session: Session, actor: OrganizationScopedActor) -> RoomStatusSummaryResponse:
    """Return the number of active rooms per status visible to the caller."""
    organization_id = None if actor.is_admin else get_member_active_organization_id(actor)
    counts = count_active_rooms_by_status(session=session, organization_id=organization_id)
    return RoomStatusSummaryResponse(
        available=counts.get(RoomStatus.AVAILABLE, 0),
        under_maintenance=counts.get(RoomStatus.UNDER_MAINTENANCE, 0),
        out_of_service=counts.get(RoomStatus.OUT_OF_SERVICE, 0),
    )
```

Import the new repository function and schema, and `RoomStatus` from `booking.types.enums`.

## 4. Expose the route

Routes only validate input, declare access and call one service function. In `api/routes/room.py`, the existing `_RoomActorDep` already authenticates the caller, allows Admin, Owner and Manager, and resolves the active organization for owners and managers:

```python
@router.get("/status-summary", responses={**_AUTH_RESPONSES})
async def get_room_status_summary_route(
    session: SessionDep,
    actor: _RoomActorDep,
) -> RoomStatusSummaryResponse:
    """
    Return the number of active rooms per status: every active
    organization's for admins; the active organization's for owners
    and managers.
    """
    return get_room_status_summary(session=session, actor=actor)
```

`responses={**_AUTH_RESPONSES}` documents the 401/403 errors in Swagger UI. If your service raised a new error, you'd add an exception following [Exceptions and error codes](../guides/exceptions-and-error-codes.md).

## 5. Try it

1. Restart booking (or let `--reload` pick up the change).
2. Lint: `cd backend/services/booking && uv run ruff check .`
3. Open [http://booking.localhost/docs](http://booking.localhost/docs). The new endpoint appears under **room**.
4. Call it as the owner from the tour. The simplest way is from the browser console while signed in at `http://main-client.localhost`, or with curl using the owner's access token (from local storage key `authToken`) and active organization (`activeOrganization`):

    ```bash
    curl http://booking.localhost/api/v1/room/status-summary \
      -H "Authorization: Bearer <access token>" \
      -H "X-Active-Organization-Guid: <organization guid>"
    ```

    With the tour's data you get `{"available": 1, "underMaintenance": 1, "outOfService": 0}`.

5. Check the access rules: without the header you get `400` with `errorCode` 2012; with another organization's GUID, `403` with 2013; as a customer, `401` with 1004.

## 6. Update the API reference and docs

In a real change you'd also:

```bash
cd hospitia-master
bash scripts/export_openapi.sh booking
```

and add the endpoint to [Booking service](../backend/booking.md), plus an `[Unreleased]` changelog entry.

## What you learned

- The layering: schema → repository (query) → service (rules) → route (access).
- How `OrganizationScopedActorDep` scopes owners and managers to their active organization while admins see everything.
- How the API reference is regenerated from the code.

Next: [Your first frontend page](first-frontend-page.md).
