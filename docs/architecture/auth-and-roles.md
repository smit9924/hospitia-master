# Authentication and roles

This page explains how users sign in, how requests are authorized in every service, and the rules for internal endpoints.

## Tokens

The auth service issues JSON Web Tokens (JWT), signed with `JWT_ENCRYPTION_SECRET_KEY` using `JWT_ENCRYPTION_ALGORITHM`:

- **Access token**, valid for `JWT_ACCESS_TOKEN_EXPIRE_MINUTES`. Sent as `Authorization: Bearer <token>` on every API call.
- **Refresh token**, valid for `JWT_REFRESH_TOKEN_EXPIRE_MINUTES`, or `JWT_REFRESH_TOKEN_EXPIRE_MINUTES_REMEMBER_ME` when the user ticks "remember me". `POST /api/v1/login/refresh-token` exchanges it for a new access token.

The token subject carries the user's `user_guid`, `role` and `email_verified` flag. The token type (access or refresh) is checked when decoding, so a refresh token can't be used as an access token.

auth, booking, dashboard and payment all have the same `JWT_ENCRYPTION_SECRET_KEY` and validate tokens themselves, without calling auth.

## Sign-in flows

| Flow | Endpoints (auth) |
|---|---|
| Sign up as owner / customer | `POST /api/v1/users/signup`, `POST /api/v1/users/signup-customer`; both return tokens |
| Sign in | `POST /api/v1/login` (username or email, password, remember me) |
| Verify email | `POST /api/v1/users/request-email-verification-otp`, then `POST /api/v1/users/verify-email-otp`; returns fresh tokens that carry the verified state |
| Forgot / reset password | `POST /api/v1/login/forgot-password` emails a link valid for `PASSWORD_RESET_TOKEN_EXPIRE_MINUTES`; `POST /api/v1/login/reset-password` sets the new password |

Most endpoints require a verified email. A few (profile read, email verification) accept unverified users so they can finish verification.

## Roles

Every user has exactly one role, `UserType` (stored as an integer):

| Value | Role | Who |
|---|---|---|
| 1 | `ADMIN` | Platform administrators |
| 2 | `OWNER` | Organization owners |
| 3 | `MANAGER` | Organization managers |
| 4 | `CUSTOMER` | Guests |
| 5 | `INTERNALE` | Reserved for internal service-account data |

`INTERNALE` must never appear in public role lists and must never be assigned through public sign-up or user-provisioning flows.

## Authorization in code

Backend routes declare who may call them with a dependency:

- **`RoleValidationDep(roles, require_email_verified=True)`** decodes the access token, and rejects the request (`UNAUTHORIZED`, 1004) when the role isn't in `roles` or, by default, when the email isn't verified. An empty role list rejects everyone.
- **`ActiveOrganizationDep(roles)`** (booking) also resolves and validates the caller's [active organization](active-organization.md).
- **`OrganizationScopedActorDep(roles)`** (booking) lets admins act on any organization and scopes owners and managers to their active organization.

The frontend mirrors this with `permissionGuard` and `requiredPermission` route data; see [Routes and guards](../guides/routes-and-guards.md). The frontend check is for user experience only; the backend check is the real one.

The full matrix is in [Roles and permissions](../reference/roles-and-permissions.md).

## Internal APIs

Some endpoints are for operators on the server itself, such as creating the first admin (`POST /api/v1/users/internal/admins`) before any admin exists to log in. Internal endpoints:

- **must** check that the request comes from a loopback address (`127.0.0.0/8` or `::1`), using `InternalRequestDep` in auth;
- **must not** require a JWT or role validation, since they exist precisely for when no authenticated user is available;
- use the `/internal/` path segment.

In production the services are reached through nginx, so a request from outside the server never arrives from a loopback address.

## Local development shortcut

With `ENVIRONMENT=local`, auth marks every new user's email as verified, and provisioned users (created by an admin, owner or manager, or by the internal admin API) get the password `Password@123` instead of a generated one. Self-signed-up users keep the password they typed. Never use `ENVIRONMENT=local` on a shared or production server.
