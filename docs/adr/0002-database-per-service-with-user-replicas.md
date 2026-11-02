# 0002: Database per service with user replicas

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-11-02 (recorded retroactively) |
| **Deciders** | Project maintainers |

## Context

Services are meant to evolve and deploy independently. Several services (booking, dashboard, payment) need basic user data that the auth service owns.

## Decision

Each service owns one PostgreSQL database (`auth`, `booking`, `dashboard`, `payment`) and never reads another service's database. Services that need user data keep a local `usersreplica` table, filled from auth's `auth.user.created` events.

## Alternatives considered

- **Shared database:** simple joins, but couples every service's schema and deployment.
- **Synchronous calls to auth:** always fresh, but makes every request depend on auth's availability and adds latency.

## Consequences

- Services can change their schema and deploy independently.
- User data in replicas is eventually consistent; right after sign-up, booking may not know a user yet (the frontend retries during account setup).
- Every new piece of shared data needs an event and a replica, and consumers must be idempotent.
- Only user creation is replicated today; updates to users aren't propagated yet.
