# Testing and linting

Run these checks before you open a pull request. CI (Jenkins) builds and deploys but doesn't run them, so they're your responsibility.

## Backend

```bash
cd backend/services/<service>
uv run ruff check .        # lint
uv run ruff check . --fix  # lint and fix what ruff can fix
```

The VS Code tasks **Lint : &lt;service&gt; (ruff check)** and **(ruff check --fix)** do the same. Ruff's rules are in each `pyproject.toml`: pycodestyle, pyflakes, isort, bugbear, comprehensions, pyupgrade, unused function arguments (`ARG001`), and no `print` (`T201`); Alembic migrations are excluded.

!!! info "No automated backend tests today"
    The backend has no test suite at the moment: booking's pytest suite was removed in commit `5ceedfa` ("remove the API test suite and pytest dependency"). Until tests are reintroduced, verify backend changes manually:

    - exercise the endpoints in Swagger UI (`http://<service>.localhost/docs`) or through the app, for every role that may and may not call them;
    - check error responses (status, `errorCode`, message);
    - for migrations, run `upgrade head`, `downgrade -1` and `upgrade head` again;
    - for messaging, watch the queues in RabbitMQ and the emails in Mailpit.

    Describe what you checked in the pull request.

## Frontend

```bash
cd frontend/clients/main
npm run lint       # ESLint: TypeScript, Angular, template accessibility rules, Prettier
npm run format     # Prettier (printWidth 100, single quotes)
npm test           # unit tests: Vitest through @angular/build:unit-test
```

Specs (`*.spec.ts`) sit next to the file they test. Add or update the spec when you add a component, service, guard, pipe or directive.

Also run an AXE check on every screen you changed, in light and dark theme. See [Accessibility in the frontend](../frontend/accessibility.md).

## Documentation

```bash
bash scripts/check_docs.sh
```

A strict MkDocs build: it fails on broken links and on pages missing from the nav. See [Documentation standards](../standards/documentation.md).
