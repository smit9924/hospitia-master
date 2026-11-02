# Active organization

Owners and managers can belong to several organizations. They work within one **active organization** per login session, and organization-scoped booking endpoints act on that organization only. This page explains how it's chosen, sent and validated.

## How it works

```mermaid
sequenceDiagram
    participant UI as Angular app
    participant B as booking service
    UI->>B: GET /api/v1/organization/memberships
    B-->>UI: Organizations the caller is actively mapped to
    Note over UI: User picks one (or the only one is picked automatically);<br/>stored in localStorage "activeOrganization"
    UI->>B: Any booking request<br/>X-Active-Organization-Guid: <guid>
    B->>B: Validate header, organization and membership
    B-->>UI: Response scoped to that organization
```

1. After sign-in, the frontend loads the caller's memberships (`GET /api/v1/organization/memberships`, owners and managers, not paginated, sorted by name).
2. The selected organization is stored in local storage (`activeOrganization`) and sent on every booking request in the `X-Active-Organization-Guid` header by `activeOrganizationInterceptor`.
3. The backend never trusts that value without validating it. `GET /api/v1/organization/active` validates the header and returns the organization summary.

## Endpoints and errors

| Method | Path | Access | Purpose |
|---|---|---|---|
| `GET` | `/api/v1/organization/memberships` | Owner, Manager | Every active organization the caller is actively mapped to, sorted by name. No header required. |
| `GET` | `/api/v1/organization/active` | Owner, Manager | Validates the header and returns the organization summary. |

| Status | Error code | When |
|---|---|---|
| 400 | `ACTIVE_ORGANIZATION_REQUIRED` (2012) | Header missing or not a UUID. |
| 403 | `ACTIVE_ORGANIZATION_INVALID` (2013) | Organization not found, inactive, or the caller has no active mapping to it. One code for all three so the response never reveals whether an organization exists. |

## Scoping an endpoint

In booking, depend on `ActiveOrganizationDep` (`booking/api/dependencies.py`). It authenticates the caller like `RoleValidationDep` and returns the resolved `ActiveOrganization` (internal `id` plus `guid`):

```python
@router.get("/example")
async def example_route(
    session: SessionDep,
    active_organization: Annotated[ActiveOrganization, Depends(ActiveOrganizationDep([UserType.OWNER, UserType.MANAGER]))],
) -> ...:
    ...
```

For endpoints that admins also use, depend on `OrganizationScopedActorDep(roles)`. Admins get an unscoped actor (they have no active organization and choose the organization in the request, for example with `organizationGuid`); owners and managers are resolved exactly like `ActiveOrganizationDep`. The room, room type and room amenity endpoints use this.

## Onboarding

The frontend's active-organization resolver (`services/organization/active-organization-resolver.ts`) decides where a signed-in owner or manager lands:

- An owner without an organization is sent to `/onboarding/create-organization`.
- A manager without an organization is sent to `/onboarding/no-organization` until an owner or admin maps them.
- Right after sign-up, the booking service may not have received the user-created event yet; the frontend retries loading memberships (`accountSetupMaxRetries`, `accountSetupRetryIntervalSeconds`) before showing `/error/account-setup`.

## Why a header

See [ADR 0005: Active organization header](../adr/0005-active-organization-header.md).
