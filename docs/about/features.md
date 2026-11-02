# Features

This page lists what Hospitia can do today, based on the code in the `main` branches. Planned work is on the [Roadmap](roadmap.md).

## Accounts and sign-in

- Sign up as an **owner** (to register an organization) or as a **customer**.
- Sign in with username or email and password; "remember me" keeps the session longer.
- Email verification with a one-time password (OTP) sent by email.
- Forgot password and reset password by email link.
- Change password, view and edit your profile, and check username availability while typing.
- Access and refresh tokens (JWT); the app refreshes the access token automatically.

## User management

- Admins create other admins and owners; admins and owners create managers; admins, owners and managers create customers.
- New provisioned users receive a welcome email with an initial password.
- Separate listings for admins, owners, managers and customers, with search, sorting and pagination.

## Organizations

- Admins manage **organization types** (for example trust, foundation) and all **organizations**.
- Owners create their own organization during onboarding, with a full postal address.
- Owners and managers can belong to several organizations and switch between them; the selected one is the **active organization** and scopes their work.
- Admins map owners and managers to organizations; a manager can be created directly into an organization.

## Rooms

- **Currency units** (ISO 4217) managed by admins; a common subset is seeded.
- **Room amenities**: default amenities managed by admins and available to every organization, plus organization-specific amenities.
- **Room types** per organization: name, description, capacity, cost per night with currency, and a set of amenities.
- **Rooms** per organization: room number, floor, room type, status (`AVAILABLE`, `UNDER_MAINTENANCE`, `OUT_OF_SERVICE`) and notes.

## Dashboards

- A dashboard per role (admin, owner, manager, customer).

## Experience and accessibility

- Collapsible, grouped sidebar navigation with role-based menu items.
- Light and dark themes, following the system preference by default, plus large-text and high-contrast-focus preferences.
- Built to WCAG AA and AXE checks.
- Interface text prepared for translation (`en-US` source, `hi` translation file).

## Platform

- Microservices (auth, booking, dashboard, payment, notification) with a database per service.
- Reliable user-created events through a transactional outbox, and email delivery with retries and dead-letter queues.
- Structured JSON logs shipped to Grafana Loki in production.
- Jenkins pipelines that build Docker images and deploy each service.

!!! info "Not built yet"
    Guest bookings, payments and reporting have services and databases in place but no user-facing features yet. The payment service currently exposes only a health check.
