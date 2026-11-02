# Product tour

In this tutorial you'll use Hospitia the way an NGO would: an administrator prepares the platform, an owner registers an organization and sets up rooms, and a manager joins to help. Along the way you'll see emails arrive in Mailpit and events flow through RabbitMQ. It takes about 30 minutes.

## Before you start

- Complete [Getting started](../getting-started/index.md): infrastructure running, dependencies installed, databases migrated.
- Use the sample `.env` files (`ENVIRONMENT=local`). New users' emails are then already verified, and users created by someone else get the password `Password@123`.

## 1. Start the app

Start auth, booking, dashboard and notification, each in its own terminal, then the frontend (see [Running the app](../getting-started/running-the-app.md)):

```bash
cd backend/services/auth && uv run uvicorn auth.main:app --reload --reload-dir auth --port 8000
cd backend/services/booking && uv run uvicorn booking.main:app --reload --reload-dir booking --port 8004
cd backend/services/dashboard && uv run uvicorn dashboard.main:app --reload --reload-dir dashboard --port 8005
cd backend/services/notification && uv run uvicorn notification.main:app --reload --reload-dir notification --port 8002
cd frontend/clients/main && npm start
```

Open **http://main-client.localhost**. You see the public landing page.

## 2. Create the administrator

Nobody can sign in yet. Create the first admin with the internal API, which only accepts requests from the same machine:

```bash
curl -X POST http://localhost:8000/api/v1/users/internal/admins \
  -H 'Content-Type: application/json' \
  -d '{"firstName": "Super", "lastName": "Admin", "email": "admin@example.com", "username": "admin"}'
```

Open Mailpit at [http://localhost:8025](http://localhost:8025) (user `developer`, password `password`). A **welcome email** for `admin` has arrived with the initial password. It travelled through auth's outbox, RabbitMQ and the notification service.

## 3. Prepare the platform as admin

1. Sign in at **http://main-client.localhost/auth/login** with `admin` / `Password@123`.
2. Open **Currency units** (under **System** in the sidebar). The migrations seeded ten common currencies (AUD, CAD, CHF, CNY, EUR, GBP, HKD, INR, JPY, USD).
3. Open **Organization types**. The default type `OTHER` exists; add one that fits your NGO, for example "Trust".
4. Open **Room amenities** and add a few **default amenities** (for example "Wi-Fi", "Hot water"). Default amenities are available to every organization.
5. Sign out.

## 4. Register an organization as owner

1. Go to **Sign up**, choose the **Owner** tab and create an account (for example username `owner1`).
2. Because you have no organization yet, Hospitia takes you to **onboarding**. Create your organization: name, type and full address.
3. You're now working in that organization: it's your **active organization**, sent with every booking request. Open your browser's developer tools, **Network** tab, and look for the `X-Active-Organization-Guid` header on requests to `booking.localhost`.

## 5. Set up rooms

Still as the owner:

1. **Room amenities:** add an amenity only your organization offers, for example "Garden view". You see it next to the admin's default amenities, which you can't edit.
2. **Room types:** create "Two sharing" with capacity 2, a cost per night in INR, and some amenities.
3. **Rooms:** create rooms 101 and 102 on floor 1 with type "Two sharing". Set one of them to **Under maintenance**.

## 6. Bring in a manager

1. Open **Managers** and create a manager (for example `manager1`) for your organization.
2. In Mailpit, open the welcome email for `manager1`.
3. Behind the scenes, auth published an `auth.user.created` event with your organization's GUID; booking received it, created its user replica and mapped the manager to your organization. You can see the queues in the RabbitMQ management UI at [http://localhost:15672](http://localhost:15672) (`developer` / `password`).
4. Sign out, then sign in as `manager1` / `Password@123`. The manager lands directly in your organization and sees its room types and rooms.

## 7. Look behind the scenes

- **PgAdmin** ([http://localhost:8080](http://localhost:8080)): open the `booking` database and look at `organizations`, `organization_user_mapping`, `room_types` and `rooms`. Open `auth.users_outbox` and see the processed rows.
- **Swagger UI:** open [http://booking.localhost/docs](http://booking.localhost/docs) to see every booking endpoint.

## What you learned

- The four roles and what each can do ([Roles and permissions](../reference/roles-and-permissions.md)).
- How organizations, the active organization, room amenities, room types and rooms relate ([Data and databases](../architecture/data.md)).
- How users and emails flow between services through RabbitMQ ([Messaging and events](../architecture/messaging.md)).

Next: [Your first backend endpoint](first-backend-endpoint.md).
