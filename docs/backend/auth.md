# Auth service

The auth service owns users and credentials. It signs users up and in, issues and refreshes JWTs, verifies email addresses, resets passwords, provisions users for other roles, and announces new users to the other services.

| | |
|---|---|
| Code | `hospitia-backend/services/auth/` (package `auth`) |
| Database | `auth` (`users`, `otp`, `secure_token`, `users_outbox`) |
| Local port / URL | 8000 / `http://auth.localhost` |
| Production container | `auth-service`, port 9002 |
| Publishes | `auth.user.created` events, welcome / forgot-password / verify-email-OTP emails |
| Consumes | nothing |
| API reference | [Auth API](../reference/api/auth.md) |

## Endpoints

All paths are under `/api/v1`. "Unverified OK" means the endpoint accepts a signed-in user whose email isn't verified yet.

| Method | Path | Access | Purpose |
|---|---|---|---|
| `POST` | `/login` | Public | Sign in with username or email, password and "remember me"; returns access and refresh tokens. |
| `POST` | `/login/access-token` | Public | OAuth2 password-form sign-in, kept for Swagger UI's **Authorize** button. |
| `POST` | `/login/refresh-token` | Refresh token | New access token. Claims (role, email verification) are rebuilt from the database, so changes take effect without signing in again. |
| `POST` | `/login/forgot-password` | Public | Emails a reset link valid for `PASSWORD_RESET_TOKEN_EXPIRE_MINUTES`. |
| `POST` | `/login/reset-password` | Reset token | Sets a new password. |
| `POST` | `/users/signup` | Public | Sign up as **owner**; returns tokens. |
| `POST` | `/users/signup-customer` | Public | Sign up as **customer**; returns tokens. |
| `GET` | `/users/check-username-availability` | Public | Validates a username and checks it's free. |
| `GET` | `/users/profile` | All roles, unverified OK | The signed-in user's profile. |
| `POST` | `/users/profile` | All roles | Update the signed-in user's profile. |
| `PUT` | `/users/change-password` | All roles | Change password (current password required). |
| `POST` | `/users/request-email-verification-otp` | All roles, unverified OK | Emails a one-time code valid for `VERIFY_EMAIL_OTP_TIMEOUT` minutes. |
| `POST` | `/users/verify-email-otp` | All roles, unverified OK | Verifies the code; returns fresh tokens carrying the verified state. |
| `POST`, `GET /{guid}`, `PUT` | `/users/admins` | Admin | Create, read and update admins. |
| `POST`, `GET /{guid}`, `PUT` | `/users/owners` | Admin | Create, read and update owners. |
| `POST`, `GET /{guid}`, `PUT` | `/users/managers` | Admin, Owner | Create, read and update managers. |
| `POST`, `GET /{guid}`, `PUT` | `/users/customers` | Admin, Owner, Manager | Create, read and update customers. |
| `POST` | `/users/internal/admins` | Loopback only | Create an admin; used to bootstrap the first admin. |
| `DELETE` | `/users/internal/admins/{guid}` | Loopback only | Soft-delete an admin. |
| `GET` | `/users/list` | Admin, Owner | Placeholder; returns a fixed string. User listings are served by the [dashboard service](dashboard.md). |

## Provisioning users

When an admin, owner or manager creates a user (`POST /users/{admins|owners|managers|customers}`, or the internal admin API):

1. auth generates a strong initial password (in `ENVIRONMENT=local`: `Password@123`) and creates the user.
2. In the same transaction it writes a `users_outbox` row with the user data, the role, the initial password and, for managers, the organization and creator.
3. The [outbox worker](../architecture/messaging.md#transactional-outbox-auth) publishes the `auth.user.created` event and the welcome email containing the username and initial password.

### Provisioning managers

`POST /users/managers` (admin, owner) requires `organizationGuid` in addition to the usual user fields. auth doesn't validate it, because it holds no organization data. It stores the GUID, together with the creator's GUID, on the `users_outbox` row, and both travel to the booking service in the user-created event (`organization_guid`, `created_by_guid`). The booking service then maps the new manager to that organization; see [Booking service](booking.md#managers-created-with-an-organization).

## Email verification and local development

Newly signed-up users must verify their email before most endpoints accept them. With `ENVIRONMENT=local`, every new user is created already verified, so you don't need Mailpit to sign in locally. See [Authentication and roles](../architecture/auth-and-roles.md#local-development-shortcut).

## Configuration

Besides the [common settings](../reference/configuration.md#common-to-all-services), auth uses the JWT settings, the email queue names, the user-events topology including every subscriber queue (auth declares them so events persist while subscribers are down), `FRONTEND_BASE_URL` (for links in emails), `PASSWORD_RESET_TOKEN_EXPIRE_MINUTES`, `VERIFY_EMAIL_OTP_TIMEOUT`, and the outbox worker settings `OUTBOX_POLL_INTERVAL_SECONDS` and `OUTBOX_BATCH_SIZE`.

## Error codes

auth uses codes 1001–1013. See [Error codes](../reference/error-codes.md).
