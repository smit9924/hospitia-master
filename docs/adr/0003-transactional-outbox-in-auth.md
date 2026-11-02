# 0003: Transactional outbox in auth

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-11-02 (recorded retroactively) |
| **Deciders** | Project maintainers |

## Context

When auth creates a user, other services must learn about it, and provisioned users must receive a welcome email. Publishing to RabbitMQ inside the request can fail after the database commit (losing the event) or succeed before a rollback (announcing a user who doesn't exist).

## Decision

auth writes a `users_outbox` row in the same transaction as the user. A background worker thread started with the app polls unprocessed rows (every `OUTBOX_POLL_INTERVAL_SECONDS`, up to `OUTBOX_BATCH_SIZE`), publishes the user-created event and, when needed, the welcome email, and marks the row processed. Failed publishes stay unprocessed and are retried on the next poll.

## Alternatives considered

- **Publish directly in the request:** simpler, but events can be lost or invented.
- **Change data capture (for example Debezium):** robust, but heavy infrastructure for one event type.

## Consequences

- Events are delivered at least once; consumers must be idempotent (replica upserts).
- Delivery is delayed by up to the poll interval.
- Emails that a user can simply request again (password reset, verification code) are still published directly.
