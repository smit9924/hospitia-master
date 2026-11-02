# 0005: Active organization header

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-11-02 (recorded retroactively) |
| **Deciders** | Project maintainers |

## Context

Owners and managers can belong to several organizations. Most of their booking actions apply to one organization at a time, and an organization must never be accessible to someone who isn't an active member.

## Decision

The frontend stores the selected organization and sends its GUID on every booking request in the `X-Active-Organization-Guid` header. The booking service validates it on every request (`ActiveOrganizationDep`, `OrganizationScopedActorDep`): header present and a UUID (else `ACTIVE_ORGANIZATION_REQUIRED`, 400), organization exists and is active and the caller has an active membership (else `ACTIVE_ORGANIZATION_INVALID`, 403, one code for all cases so existence isn't revealed). Admins aren't scoped and choose the organization explicitly.

## Alternatives considered

- **Organization in the JWT:** no extra header, but switching organization would require a new token from auth, which holds no organization data.
- **Organization in every URL path:** explicit, but changes every route and still requires the same validation.

## Consequences

- Switching organization is instant on the client.
- Every organization-scoped endpoint must use one of the dependencies; forgetting it would be a security bug, so reviews check for it.
