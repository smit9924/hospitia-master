# Database migrations

Every schema change in auth, booking, dashboard or payment goes through an Alembic migration in that service's `<service>/database/alembic/versions/`. This guide shows how to create, review and apply one.

## 1. Change the model

Edit or add a SQLModel class in `backend/services/<service>/<service>/database/models/`. For a new module, export its models in `__all__` and import it in `database/models/__init__.py`; Alembic only sees tables registered there.

Every `Relationship()` needs an explicit scalar foreign-key column on the same model:

```python
organization_id: int = Field(foreign_key="organizations.id", nullable=False, index=True, ondelete="RESTRICT")
organization: Organization = Relationship()
```

Match the column's nullability and delete behaviour to the relationship. See [Backend standards](../standards/backend.md#models-and-migrations).

## 2. Generate the migration

=== "VS Code task (dev container)"

    Run **Make migrations : &lt;service&gt;** (available for auth, booking, payment, dashboard). It runs `backend/scripts/create_migration.sh <service>`, asks for a message, and autogenerates the revision.

=== "Command line"

    ```bash
    cd backend/services/<service>/<service>/database
    uv run alembic revision --autogenerate -m "create rooms table"
    ```

    `create_migration.sh` assumes the dev container path `/workspace/backend/services`; in a cloud session use the command line form.

Name migrations with a short imperative description: `create rooms table`, `add role to usersreplica`.

## 3. Review the generated file

Autogenerate is a starting point, not the final migration. Check that:

- every table, column, index, unique constraint and **foreign key** you expect is there, with the right `ondelete`;
- `downgrade()` reverses `upgrade()` exactly;
- data changes (seeds, backfills of existing rows) are added by hand when needed; see `c4e6a8b0d2f3_seed_common_currency_units.py` in booking for an example;
- nothing unrelated was picked up (for example a model you didn't mean to change).

## 4. Apply it

```bash
cd backend/services/<service>
uv run alembic -c ./<service>/database/alembic.ini upgrade head
```

or the **Migrate : &lt;service&gt;** VS Code task. Test the downgrade too:

```bash
uv run alembic -c ./<service>/database/alembic.ini downgrade -1
uv run alembic -c ./<service>/database/alembic.ini upgrade head
```

## In production

Each service's Docker image runs `jenkins/scripts/update-db.sh` as its entrypoint, which applies `alembic upgrade head` before starting the app. A deployment therefore migrates automatically, so migrations must be safe to run against existing data. See [CI/CD with Jenkins](../operations/ci-cd.md).
