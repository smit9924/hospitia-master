# 0004: Messaging abstraction over RabbitMQ

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-11-02 (recorded retroactively) |
| **Deciders** | Project maintainers |

## Context

Services exchange events and commands asynchronously. RabbitMQ is the broker today, but broker-specific code spread through business logic would be hard to test and to replace.

## Decision

Each service has a `messaging/` package with abstract interfaces (`MQClient`, and `MQConsumer` for consumers), a factory selected by `MQ_CLIENT_TYPE` (`get_mq_client()`, `get_mq_consumer()`), and the RabbitMQ implementation in `messaging/rabbitmq/` using pika. Business code, handlers and services only use the abstraction. Topology names come from settings. Consumers use manual acknowledgement, per-queue retry counts and dead-letter queues.

## Alternatives considered

- **Use pika directly in services:** less code, but couples business logic to RabbitMQ.
- **A shared Python messaging package:** less duplication, but needs packaging and versioning across services.

## Consequences

- The messaging code is duplicated in each service and must be kept consistent by hand.
- Replacing or adding a broker means a new implementation behind the same interface.
