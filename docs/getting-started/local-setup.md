# Local setup (dev container)

This guide sets up the standard development workspace on your machine. You'll clone the three repositories into one folder, create the environment files and open the folder in a VS Code dev container. It takes about 15 minutes, mostly downloading images.

## 1. Clone the repositories

Open a WSL2 terminal (on Linux or macOS, any terminal) and clone the master repository, then the frontend and backend repositories **inside** it:

```bash
mkdir Project
cd Project
git clone https://github.com/smit9924/hospitia-master .
git clone https://github.com/smit9924/hospitia-frontend ./frontend
git clone https://github.com/smit9924/hospitia-backend ./backend
```

`frontend/` and `backend/` are separate Git repositories nested in the master checkout; the master repository's `.gitignore` excludes them. See [Workspace and repositories](../architecture/workspace.md).

## 2. Run the initial setup script

```bash
bash ./scripts/initial_setup.sh
```

It creates the `dev-net` Docker network and installs the VS Code **Dev Containers** and **WSL** extensions.

## 3. Create the environment files

The dev container and each backend service read a `.env` file that is not committed. Create them from the committed samples, which already contain working local-development values:

```bash
cp .devcontainer/.sample.env .devcontainer/.env
for service in auth booking dashboard notification payment; do
  cp backend/services/$service/.sample.env backend/services/$service/.env
done
```

!!! warning "Local values only"
    The samples contain local-development values such as `ENVIRONMENT=local`. Never use them on a shared or production server: with `ENVIRONMENT=local`, the auth service marks new users' email as verified and gives provisioned users a fixed default password. See [Configuration](../reference/configuration.md).

## 4. Open the workspace in the dev container

1. Open the `Project` folder in VS Code.
2. Press <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> and run **Dev Containers: Rebuild and Reopen in Container**. You only need to rebuild the first time.
3. Next time, use **Dev Containers: Reopen in Container**.

The dev container (`.devcontainer/devcontainer.json`) starts these containers on the `dev-net` network:

| Container | Purpose |
|---|---|
| `webapp-workspace` | Your shell: Python 3.13, Node.js 20, uv, and nginx routing the `*.localhost` hostnames |
| `webapp-postgres` | Postgres 17 with the `auth`, `booking`, `payment` and `dashboard` databases |
| `webapp-pgadmin` | PgAdmin, preconnected to Postgres |
| `webapp-rabbitmq` | RabbitMQ with the management UI |
| `webapp-mailpit` | Mailpit, which catches every email the app sends |

The `webapp-` prefix comes from `project_name` in `.devcontainer/.env`.

## 5. Install dependencies and migrate the databases

Inside the dev container, run the VS Code task **install dependencies** (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> → **Tasks: Run Task**), or from a terminal:

```bash
for service in auth booking dashboard notification payment; do
  (cd /workspace/backend/services/$service && uv sync)
done
(cd /workspace/frontend/clients/main && npm ci)
```

!!! note
    The **install dependencies** task does not include the dashboard service; run `uv sync` in `backend/services/dashboard` yourself, as in the loop above.

Then apply the database migrations for each service that has a database:

```bash
for service in auth booking dashboard payment; do
  (cd /workspace/backend/services/$service && uv run alembic -c ./$service/database/alembic.ini upgrade head)
done
```

The VS Code tasks **Migrate : auth**, **Migrate : booking**, **Migrate : payment** and **Migrate : dashboard** do the same per service.

## Next step

[Running the app](running-the-app.md)
