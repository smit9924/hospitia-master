# Your first message flow

In this tutorial you'll follow a real event through Hospitia, from the moment auth creates a user to the moment booking stores its replica, and watch it in RabbitMQ. Then you'll design a new flow of your own using the same building blocks. It takes about 45 minutes.

## Before you start

- Complete the [Product tour](product-tour.md).
- Read [Messaging and events](../architecture/messaging.md).

## Part 1: follow the user-created event

### 1. Watch the queues

1. Open the RabbitMQ management UI ([http://localhost:15672](http://localhost:15672), `developer` / `password`) and go to **Queues and Streams**.
2. **Stop the dashboard service** for this step only.
3. As the owner, create a customer in the app.
4. `dashboard.user.created` now shows **1** ready message; it waits safely because auth declared the queue. `booking.user.created` and `payment.user.created` are empty if those services are running.
5. Start dashboard again. The message is consumed within seconds.

### 2. Read the code, step by step

All paths are under `backend/services/`.

| Step | Code | What happens |
|---|---|---|
| 1 | `auth/auth/api/routes/users.py` → `create_customer` | The route checks the caller's role and calls the service. |
| 2 | `auth/auth/api/services/user_service.py` → `provision_user` | Creates the user and, **in the same transaction**, a `users_outbox` row. |
| 3 | `auth/auth/outbox/worker.py` | A background thread polls the outbox every `OUTBOX_POLL_INTERVAL_SECONDS`. |
| 4 | `auth/auth/outbox/service.py` → `_publish_user_created_event` | Wraps the user in an `MqDomainEvent` and publishes it to `user_events_exchange` with routing key `auth.user.created`, through `get_mq_client()`. Then it publishes the welcome email and marks the row processed. |
| 5 | `auth/auth/messaging/rabbitmq/client.py` | The only place that knows about RabbitMQ: it declares the exchange and the three subscriber queues and publishes with retries. |
| 6 | `booking/booking/messaging/rabbitmq/consumer.py` | Consumes `booking.user.created` with manual acknowledgement. |
| 7 | `booking/booking/handlers/handler_routes.py` | Maps the queue name to `user_created_handler`. |
| 8 | `booking/booking/handlers/user_handlers.py` → `user_created_handler` | Validates the envelope and payload, then calls the service. |
| 9 | `booking/booking/api/services/user_replica_service.py` | Upserts the `usersreplica` row, so receiving the same event twice is harmless. |
| 10 | `booking/booking/exceptions/handlers/consumer_exception_handlers.py` | On failure: republish with `retry_count + 1`, up to `USER_CREATED_RETRY_COUNT`, then move to `booking.user.created.dlq`. |

### 3. See a retry and a dead letter

1. In PgAdmin, open the `booking` database.
2. In RabbitMQ, open `booking.user.created` and use **Publish message** with the payload `{"event_id": "not-a-uuid"}`.
3. Validation fails. The consumer republishes the message with a growing `retry_count` and finally moves it to `booking.user.created.dlq`. Open the dead-letter queue and **Get messages** to see it.
4. Purge the dead-letter queue when you're done.

## Part 2: design your own flow

Suppose the dashboard should show live room counts. booking would publish an event whenever a room is created, updated or deleted, and dashboard would keep its own counts. Plan it with the [messaging guide](../guides/messaging.md) by answering these questions on paper (or on a throwaway branch):

1. **Event or command?** An event: dashboard *reacts* to something that happened in booking. Name it like the existing one: `booking.room.changed`.
2. **Exchange:** a new topic exchange `booking_events_exchange`, configured as settings in booking and dashboard, and in both sample env files of each.
3. **Queue:** `dashboard.room.changed`, bound with routing key `booking.room.changed`, declared by **booking** (the publisher), so events wait while dashboard is down; plus `dashboard.room.changed.dlq` and `ROOM_CHANGED_RETRY_COUNT` in dashboard.
4. **Reliability:** room changes are business data that mustn't be lost after the commit, so booking would need its own outbox table, migration and worker, following auth's.
5. **Payload:** an `MqDomainEvent` with the organization GUID, room GUID, status and `is_active`. Never internal IDs.
6. **Consumer:** `room_changed_handler` in `dashboard/handlers/`, registered in `handler_routes.py`, idempotent (upsert by room GUID), delegating to a service.
7. **Docs:** [Messaging and events](../architecture/messaging.md), both service pages and [Configuration](../reference/configuration.md).

A change of this size also deserves an [ADR](../adr/index.md), since it adds a second event source and a second outbox.

## What you learned

- How the outbox, the messaging abstraction, consumers, retries and dead-letter queues work together.
- Why consumers must be idempotent and queues are declared by the publisher.
- How to plan a new event flow that fits the existing architecture.
