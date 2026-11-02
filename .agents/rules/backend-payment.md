---
description: Payment service - skeleton with user replica and health check
paths:
  - "backend/services/payment/**"
---

# Backend: payment service

Payments for bookings, currently a skeleton (`backend/services/payment/`, package `payment/payment/`, port 8006): its database, a user replica fed by `auth.user.created`, and `GET /api/v1/login/health-check`.

- Build payment features with the standard package map and layering; follow the booking service as the closest example.
- Data owned elsewhere (users, bookings) comes through events or the owning service's API, never by reading other databases.
- Consumer failures retry up to `USER_CREATED_RETRY_COUNT`, then go to the dead-letter queue.
- New error codes use the next free 3xxx number.
- Treat amounts as `Decimal`/`NUMERIC`, never floats, and record the currency unit with every amount, as room types do.

Details: `docs/backend/payment.md`, `docs/backend/index.md`.
