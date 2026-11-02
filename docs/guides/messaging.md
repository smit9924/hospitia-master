# Publishing and consuming messages

This guide adds a new message flow between services. Read [Messaging and events](../architecture/messaging.md) first for the topology and delivery guarantees. The [message flow tutorial](../tutorials/first-message-flow.md) walks through a complete example.

## Decide: event or command, and how reliable

| Question | Guidance |
|---|---|
| Is it a fact other services may react to ("user created")? | Publish an **event** to a topic exchange (like `user_events_exchange`), with one queue per subscriber. |
| Is it a request for one service to do something ("send this email")? | Publish a **command** to a direct exchange (like `email_notifications_exchange`) and a dedicated queue. |
| Must it never be lost when the database change commits? | Use an **outbox** table written in the same transaction, as auth does for user creation. |
| Can the user just retry the action? | Publishing directly from the service is acceptable (as for password-reset emails). |

## Publisher side

1. **Configure the topology.** Add the exchange, queue and routing-key names as settings in `core/config.py` and to the service's `.sample.env` **and** `.sample.cloud-dev.env`. Never hard-code names.
2. **Declare it.** Register the exchange in `_exchanges` and the queue in `_queues` in `messaging/rabbitmq/client.py` (`RabbitMQClient.__init__`). Declaring the subscriber queues on the publisher side means messages wait in the queue even if the consumer isn't running yet.
3. **Define the message schema** in `schemas/mq_schemas.py`, extending `MqBaseSchema`. For events, wrap the payload in the `MqDomainEvent` envelope (`event_id`, `event_type`, `occurred_at`, `payload`, `retry_count`).
4. **Publish from the service layer** through the abstraction:

    ```python
    from auth.messaging.general import get_mq_client

    get_mq_client().publish(settings.WELCOME_EMAIL_QUEUE, message)
    ```

    `publish(destination, message, routing_key=None)` accepts a queue name, or an exchange name plus a routing key. The client retries failed publishes (`RABBITMQ_PUBLISH_RETRY_ATTEMPTS`, `RABBITMQ_PUBLISH_RETRY_DELAY`) and raises `MQMessagePublishException` if it still fails.

Never import `pika` outside `messaging/rabbitmq/`.

## Consumer side

1. **Configure** the queue, its routing key, a **dead-letter queue** and a retry count (`<NAME>_RETRY_COUNT`) in settings and both sample env files.
2. **Declare** the queue with its `dead_letter_queue` in the consumer (`messaging/rabbitmq/consumer.py`).
3. **Write the handler** in `handlers/<area>_handlers.py`: validate the message with its schema, then delegate to a function in `services/`. Keep the handler thin and **idempotent**: the same message may arrive more than once.
4. **Register the handler** for the queue name in `MESSAGE_ROUTES` in `handlers/handler_routes.py`.
5. **Add an exception handler** for the queue (see `exceptions/handlers/consumer_exception_handlers.py` in booking) that republishes with `retry_count + 1` until the limit, then publishes to the dead-letter queue.

## Check it

- Start RabbitMQ, the publisher and the consumer; trigger the action.
- In the RabbitMQ management UI ([http://localhost:15672](http://localhost:15672)), check the exchange bindings and that the queue drains.
- Make the handler fail on purpose once and confirm the message is retried, then dead-lettered.

## Document it

Update [Messaging and events](../architecture/messaging.md) (topology and payload), the service pages, and [Configuration](../reference/configuration.md).
