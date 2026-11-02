# Roles and permissions

Who can do what, by role. The backend enforces these rules (`RoleValidationDep`, `ActiveOrganizationDep`, `OrganizationScopedActorDep`); the frontend mirrors them with `permissionGuard` for user experience. Roles are explained in [Authentication and roles](../architecture/auth-and-roles.md).

Legend: ✅ allowed · 🏢 allowed within the caller's active organization · — not allowed.

## Users (auth, dashboard)

| Action | Admin | Owner | Manager | Customer |
|---|---|---|---|---|
| Sign up | — | ✅ (`/users/signup`) | — | ✅ (`/users/signup-customer`) |
| View / edit own profile, change password, verify email | ✅ | ✅ | ✅ | ✅ |
| Create, view, update admins | ✅ | — | — | — |
| Create, view, update owners | ✅ | — | — | — |
| Create, view, update managers | ✅ | ✅ | — | — |
| Create, view, update customers | ✅ | ✅ | ✅ | — |
| List admins / owners | ✅ | — | — | — |
| List managers | ✅ | ✅ | — | — |
| List customers | ✅ | ✅ | ✅ | — |
| Create or remove an admin from the server (internal API) | Loopback only, no token | | | |

## Organizations (booking)

| Action | Admin | Owner | Manager | Customer |
|---|---|---|---|---|
| Manage organization types | ✅ | — | — | — |
| List organization types | ✅ | ✅ | — | — |
| Create / update any organization | ✅ | — | — | — |
| Create / update own organization | — | ✅ | — | — |
| Deactivate an organization | ✅ | ✅ | — | — |
| List all organizations | ✅ | — | — | — |
| List an owner's / a manager's organizations | ✅ | ✅ | ✅ (manager list) | — |
| Map owners to organizations | ✅ | — | — | — |
| Map managers to organizations | ✅ | ✅ | — | — |
| See own memberships, validate active organization | — | ✅ | ✅ | — |

## Room setup (booking)

| Action | Admin | Owner | Manager | Customer |
|---|---|---|---|---|
| Manage currency units | ✅ | — | — | — |
| Pick a currency unit (options) | ✅ | ✅ | ✅ | — |
| Manage default room amenities | ✅ | — | — | — |
| Manage organization room amenities | ✅ (any organization) | 🏢 | 🏢 | — |
| Manage room types | ✅ (any organization) | 🏢 | 🏢 | — |
| Manage rooms | ✅ (any organization) | 🏢 | 🏢 | — |

## Email verification

Unless stated otherwise above, every authenticated action also requires a verified email. Profile reading and the email-verification endpoints work before verification.

## Frontend routes

The `requiredPermission` of every route in `app.routes.ts` matches the tables above. For example, `/users/create/manager` allows Admin and Owner, and `/organization/room/listing` allows Admin, Owner and Manager.
