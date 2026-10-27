# Hospitia — Project Overview

Hospitia is a **Guest House Management System for NGOs**.

## Workspace

`hospitia-master` is an umbrella workspace containing two separate Git repositories:

```text
hospitia-master/
├── frontend/       # Angular frontend repository
├── backend/        # FastAPI backend repository
├── .devcontainer/  # Development environment configuration
├── jenkins/        # Top-level CI/CD configuration
├── server-setup/   # Server/deployment configuration
└── README.md

# Architectural Principles

- **Multi-repo**: `frontend/` and `backend/` are separate Git repositories under `hospitia-master`.
- **Multiple frontend apps**: New Angular applications belong under `frontend/clients/`.
- **Service-oriented backend**: Backend domains are separated into independent services.
- **Layered Auth API**: Follow `API → Services → Repositories → Database`; keep business and persistence logic out of route handlers.
- **Messaging abstraction**: Use the project's MQ abstraction; keep RabbitMQ-specific code inside its implementation layer.
- **Centralized exceptions**: Follow the existing service-level exception definition/handler/registration pattern.
- **Configuration separation**: Keep environment-specific configuration outside business logic; never hardcode secrets or environment-specific values.
- **Existing patterns first**: Before introducing a new pattern, inspect and follow the closest existing implementation.
- **Internal APIs**: Internal-only endpoints must validate the request source
  as a loopback address (`127.0.0.0/8` or `::1`) and must not require JWT or
  role validation. `UserType.INTERNALE` is reserved for internal
  service-account data and must not be included in public role lists or
  assigned through public signup/user-provisioning flows.

# Coding Standards

## Agent defaults

- Follow existing patterns in the file/service you touch; match naming, layout, and error style.
- Respect architectural layering (see architectural-principles and scoped backend/frontend rules).
- Do not commit secrets, `.env` values, credentials, or paste them into rules/docs.
- Prefer small, focused changes; avoid drive-by refactors unrelated to the request.
- When adding cross-cutting behavior (auth, messaging, errors), extend existing abstractions instead of inventing parallel ones.
- In Angular HTML templates, add concise review comments for identifiable UI elements and sections, following the existing convention (for example, `<!-- TEXT FIELD: Email -->`, `<!-- BUTTON: Login -->`, and `<!-- Form: Login -->`).
- Every SQLModel/SQLAlchemy `Relationship()` field must have an explicit scalar
  foreign-key column on the same model (for example, `organization_id:
  int = Field(foreign_key="organizations.id", ...)` alongside
  `organization: Organization = Relationship()`). Keep the scalar column
  available for direct filtering/navigation, configure its nullability and
  delete behavior to match the relationship, and include the constraint in the
  corresponding Alembic migration. Never rely on `Relationship()` alone to
  enforce referential integrity.

## Team conventions

<!-- Add project-specific naming, PR prefs, domain workflows, etc. below -->

# Backend — Auth Service

Applies to: `backend/services/auth/**/*`

FastAPI service at `backend/services/auth/`. App package: `auth/auth/`.

## Package map

```text
auth/
├── api/           # HTTP layer
│   ├── routes/    # Endpoints
│   ├── services/  # Business logic
│   ├── repositories/
│   └── datamodels/
├── core/          # Config, security, settings
├── database/      # Alembic + SQLAlchemy models
├── exceptions/    # definitions/, handlers/, registry
├── messaging/     # base abstraction + rabbitmq/
├── schemas/       # Pydantic request/response schemas
└── types/         # Shared types, enums, error codes
```

## Layering

```text
API routes → Services → Repositories → SQLAlchemy models → PostgreSQL
```

- Routes validate input, call services, return responses—no heavy business or DB logic in routes.
- Repositories own persistence; services own business rules.
- Schema changes go through **Alembic** under `database/`.

## Cross-cutting

- **Exceptions**: define in `exceptions/definitions/`, handle in `exceptions/handlers/`, register via registry at startup.
- **Messaging**: publish/consume through the MQ abstraction (`messaging/`), not RabbitMQ clients in business code.
- **Schemas/types**: Pydantic in `schemas/`; shared constants/enums in `types/`.

# Backend — Notification Service

Applies to: `backend/services/notification/**/*`

Service at `backend/services/notification/`. App package: `notification/notification/`.

**No direct HTTP API today.** Entry points are message handlers consuming RabbitMQ (via the messaging abstraction).

## Flow

```text
Auth/Other services → RabbitMQ → Handlers → Services → Jinja templates → Email/channel
```

## Package map

```text
notification/
├── core/          # Config / settings
├── handlers/      # Queue consumers / message entry points
├── services/      # Business helpers for notification processing
├── messaging/     # base abstraction + rabbitmq/
├── channels/      # Delivery channels (e.g. email)
├── exceptions/    # definitions (+ handlers as needed)
├── schemas/       # Message/payload schemas
├── templates/     # Jinja templates for notification content
└── types/         # Shared types / enums
```

## Conventions

- Add new message flows as handlers that delegate to `services/`; keep queue wiring out of business logic.
- Render content with Jinja under `templates/`; do not hardcode large email bodies in Python.
- Use the messaging abstraction—do not scatter RabbitMQ-specific calls in handlers/services.
- Keep exception definitions centralized under `exceptions/`.

# Frontend — Angular (`clients/main`)

Applies to: `frontend/**/*.{ts,html,scss}`

Primary app: `frontend/clients/main/`. Future apps also go under `frontend/clients/`.

## Source layout

```text
src/
├── app/           # Core application code
├── assets/        # fonts, icons, images, logos
├── environments/  # env-specific config (API URLs, etc.)
├── locale/        # i18n localization files
└── styles/        # global, utils, colors, Material overrides
```

## `src/app`

| Area | Role |
|------|------|
| `components/` | UI by feature (`auth`, `common`, dashboards, `errors`, landing, loaders, `profile`, `reset-password`, `settings`, `style-guide`, …) |
| `data/` | Centralized constants (API endpoints, routes, icons, localStorage keys) |
| `directives/` | Reusable DOM/UI behavior |
| `guards/` | Authn/authz and route access control |
| `services/` | Shared logic (auth, dialog, icon, layout, local storage, profile, snackbar, …) |
| `types/` | Interfaces, models, enums, shared TS definitions |

## App conventions

- Put reusable UI in `components/common/` or style-guide patterns; avoid duplicating Material wrappers—use existing services (e.g. dialog, snackbar, icon).
- Keep static definitions in `data/`; keep shared types in `types/`.
- Protect routes with guards; do not scatter ad-hoc auth checks in components when a guard fits.
- Use `environments/` for environment-dependent values; do not hardcode API bases in components.

---

# UI / HTML & SCSS

When writing HTML/SCSS, follow this order:

1. **Reuse first** — Check `src/styles/global.scss` and `src/styles/_utils.scss` for an existing generic/reusable class and use it.
2. **Promote if reusable** — If the styling should be generic and useful elsewhere, add a reusable class to the appropriate global/utils stylesheet and use that.
3. **Otherwise component-scoped** — Write styles in the component's own SCSS only when they are truly component-specific.
4. **Material overrides** — Global Material component styling goes in dedicated files under `src/styles/` (e.g. `_material-buttons-override.scss`, `_material-dialog-override.scss`, `_material-snackbar-override.scss`, `_material-toolbar-override.scss`, `_material-theme-config.scss`). Do not dump Material overrides into component SCSS or `global.scss`.
5. **No hardcoded colors** — Define colors in `src/styles/colors.scss`. Prefer **Angular Material color palette / theme tokens** over raw hex/rgb values.
6. **Themes** — The app supports **light and dark** themes; styles must work in both (use theme tokens / CSS variables, not light-only assumptions).
7. **Responsive** — Layouts and UI must work across viewports (mobile, tablet, desktop).

---

# Angular & TypeScript (LLM guide)

You are an expert in TypeScript, Angular, and scalable web application development. Write functional, maintainable, performant, and accessible code following Angular and TypeScript best practices.

## TypeScript Best Practices

- Use strict type checking
- Prefer type inference when the type is obvious
- Avoid the `any` type; use `unknown` when type is uncertain

## Angular Best Practices

- Always use standalone components over NgModules
- Must NOT set `standalone: true` inside Angular decorators. It's the default in Angular v20+.
- Do NOT set `changeDetection: ChangeDetectionStrategy.OnPush` explicitly. `OnPush` is the default in Angular v22+.
- Use signals for state management
- Implement lazy loading for feature routes
- Do NOT use the `@HostBinding` and `@HostListener` decorators. Put host bindings inside the `host` object of the `@Component` or `@Directive` decorator instead
- Use `NgOptimizedImage` for all static images.
  - `NgOptimizedImage` does not work for inline base64 images.

## Accessibility Requirements

- It MUST pass all AXE checks.
- It MUST follow all WCAG AA minimums, including focus management, color contrast, and ARIA attributes.

### Components

- Keep components small and focused on a single responsibility
- Use `input()` and `output()` functions instead of decorators
- Use `model()` for two-way bound properties with `[(prop)]` syntax instead of pairing `input()` with `output()`
- Use `computed()` for derived state
- Use `linkedSignal()` for state derived from multiple reactive sources that must stay synchronized
- Prefer inline templates for small components
- Prefer Signal Forms (`@angular/forms/signals`) for new forms. They are stable in Angular v22+ and provide signal-based state, type-safe field access, and schema-based validation
- When not using Signal Forms, prefer Reactive forms instead of Template-driven ones
- Do NOT use `ngClass`, use `class` bindings instead
- Do NOT use `ngStyle`, use `style` bindings instead
- When using external templates/styles, use paths relative to the component TS file.

## State Management

- Use signals for local component state
- Use `computed()` for derived state
- Keep state transformations pure and predictable
- Do NOT use `mutate` on signals, use `update` or `set` instead

## Templates

- Keep templates simple and avoid complex logic
- Use native control flow (`@if`, `@for`, `@switch`) instead of `*ngIf`, `*ngFor`, `*ngSwitch`
- Use the async pipe to handle observables
- Do not assume globals like (`new Date()`) are available.

## Services

- Design services around a single responsibility
- Use the `providedIn: 'root'` option for singleton services
- Prefer the `@Service` decorator over `@Injectable({providedIn: 'root'})` for new singleton services (Angular v22+)
- Use the `inject()` function instead of constructor injection

# Cloud sessions (claude.ai/code)

Applies when `CLAUDE_CODE_REMOTE=true`. Repos are cloned as siblings (`hospitia-master/`, `hospitia-frontend/`, `hospitia-backend/`); there is no devcontainer, and the VM itself is the workspace.

- **First, every session:** when `CLAUDE_CODE_REMOTE=true`, run `bash hospitia-master/scripts/cloud_bootstrap.sh` (from the parent folder) before any other work. Run it again after a session is reopened following expiry, since the fresh VM has no running dockerd or containers. It's safe to re-run. It symlinks `hospitia-master/frontend` and `hospitia-master/backend` to the sibling repos, creates missing `.env` files (backend services from `.sample.cloud-dev.env`, `.devcontainer` from `.sample.env`), starts dockerd, runs postgres/pgadmin/rabbitmq/mailpit via `.devcontainer/docker-compose.yml` plus nginx and cloud-only settings from the `docker-compose.cloud.yml` override, waits until every service responds, and maps the `*.localhost` hostnames to `127.0.0.1` in `/etc/hosts`. It fails loudly (exit 1, with container logs) on a missing required command, a port held by another process, or a service that crashes or doesn't respond. Treat any non-zero exit as a broken setup and report it; don't work around it. Hooks don't run in multi-repo sessions, so run it yourself.
- **Node:** the project uses Node 20, so run `export PATH=/opt/node20/bin:$PATH` before any `npm`/`ng` command.
- **Python:** 3.13 via uv (`uv sync`, `uv run …`).
- **Hosts:** each backend service has a `.sample.cloud-dev.env`, a copy of `.sample.env` with the Postgres/RabbitMQ/SMTP hosts set to `localhost` instead of dev-net Docker hostnames. The bootstrap copies it to `.env`, so the cloud environment needs no env vars. Keep it in sync with `.sample.env` when you add or change keys.

| Service | Endpoint | Credentials |
|---|---|---|
| Postgres | `localhost:5432` (DBs: `auth`, `booking`, `payment`, `dashboard`); use `docker exec webapp-postgres psql -U postgres …`, since the VM's `psql` 16 doesn't fully work with server 17 (e.g. `\l` fails) | `postgres` / `password` |
| RabbitMQ | `localhost:5672`, UI `http://localhost:15672` | `developer` / `password` |
| Mailpit | SMTP `localhost:1025`, UI `http://localhost:8025` | `developer` / `password` (UI and SMTP) |
| PgAdmin | `http://localhost:8080` | `developer@domain.com` / `password` |

**Backend** (per service under `backend/services/<svc>`; `<svc>` is `auth`, `booking`, `dashboard`, `payment` or `notification`):

```bash
uv sync
uv run alembic -c ./<svc>/database/alembic.ini upgrade head   # not for notification (no DB)
uv run uvicorn <svc>.main:app --reload --port <port>          # auth 8000, notification 8003, booking 8004, dashboard 8005, payment 8006
uv run pytest                                                 # tests use in-memory SQLite
```

**Frontend** (`frontend/clients/main`): `npm ci`, then `npm start` (ng serve on `0.0.0.0:8001`).

**Routing:** the nginx container (host network, same `.devcontainer/nginx/conf.d` as the devcontainer) routes these hostnames on port 80, as locally. Use them for browser and API testing, since `environment.ts` and CORS expect them. A route returns 502 until its dev server is running.

| URL | Target |
|---|---|
| `http://main-client.localhost` | frontend `:8001` |
| `http://auth.localhost` / `booking.localhost` / `dashboard.localhost` / `payment.localhost` | services `:8000` / `:8004` / `:8005` / `:8006` |
| `http://mailpit.localhost` | Mailpit UI `:8025` |
