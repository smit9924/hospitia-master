# Documentation map

Which documentation to check for each kind of code change. This file and `scripts/collect_changes.sh` are the only places the skill is wired to Hospitia's layout. The area names match the script's output.

When a changed path is reported as `unmapped`, or a row below no longer matches the docs tree, update this file (and the script's `AREA_RULES`) as part of the run and say so in the report.

Paths in the "Update" column are relative to `hospitia-master/`.

## Backend (`hospitia-backend`)

| Area | Change detected | Update |
|---|---|---|
| `backend-api` | Routes, request/response schemas, dependencies, OpenAPI error docs (`doc/`) | Run `bash scripts/export_openapi.sh <service>` (auth, booking, dashboard, payment). Update the endpoint tables and rules in `docs/backend/<service>.md`. Access changes: `docs/reference/roles-and-permissions.md`. Active-organization behaviour: `docs/architecture/active-organization.md`. |
| `backend-data` | Models, Alembic migrations, seeds, reference data | `docs/architecture/data.md` (tables, ER diagram, rules), the service page, `docs/about/glossary.md` for new domain entities. |
| `backend-error-codes` | `types/error_codes.py` | `docs/reference/error-codes.md`. |
| `backend-messaging` | Messaging clients/consumers, handlers, outbox, consumer exception handlers | `docs/architecture/messaging.md` (topology diagram, payloads, guarantees), the service pages, `docs/guides/messaging.md` if the procedure changed. |
| `backend-config` | `.sample.env`, `.sample.cloud-dev.env`, `core/config.py` | `docs/reference/configuration.md` (names and purpose only, never values). Check both sample files have the same keys. |
| `backend-email-templates` | notification templates | `docs/backend/notification.md` (queue/template table), `docs/guides/email-templates.md`. |
| `backend-logic` | Services, repositories, exceptions, middleware, logging, enums, `main.py` | The service page when behaviour or business rules change; `docs/backend/index.md` for shared patterns; `docs/about/features.md` for user-visible features. Usually "no doc impact" for internal refactors. |
| `backend-dependencies` | `pyproject.toml`, `uv.lock` | Tech stack in `README.md` and `docs/backend/index.md` only for a new framework or major version. |
| `backend-other` | A new top-level service directory, or anything else under `services/` | **New service:** `docs/backend/<service>.md` + `mkdocs.yml` nav, `docs/backend/index.md` table, `docs/architecture/services.md`, `docs/architecture/index.md` diagram, `docs/reference/ports-and-hostnames.md`, `docs/reference/configuration.md`, `scripts/export_openapi.sh` `HTTP_SERVICES` (if HTTP), backend README stub table, a stub `services/<service>/README.md`, and a new `.agents/rules/backend-<service>.md`. **Removed service:** the reverse. |

## Frontend (`hospitia-frontend`)

| Area | Change detected | Update |
|---|---|---|
| `frontend-routing` | `app.routes.ts`, guards, `app-routes.ts`, `sidebar-navigation.ts` | `docs/guides/routes-and-guards.md` (guard behaviour), `docs/reference/roles-and-permissions.md` (route roles), `docs/about/features.md` for new pages, tutorials if their steps changed. |
| `frontend-services` | `api-routes.ts`, services, interceptors | `docs/architecture/frontend.md` (interceptors, services), `docs/architecture/active-organization.md` if the header handling changed. |
| `frontend-components` | Feature components | `docs/frontend/index.md` (components table) for a new feature folder; `docs/about/features.md` for user-visible features. |
| `frontend-shared` | `data/`, `types/`, `pipes/`, `directives/`, `assets/` | Usually no doc impact; local-storage keys → `docs/architecture/frontend.md`; frontend error codes must mirror `docs/reference/error-codes.md`; icons → `docs/frontend/styling-and-theming.md` only if the mechanism changed. |
| `frontend-styles` | `src/styles/`, fonts | `docs/frontend/styling-and-theming.md`, `docs/frontend/typography.md`; `docs/standards/html-and-scss.md` and `.agents/rules/frontend-templates-styles.md` if a convention changed. |
| `frontend-config` | `environments/` | `docs/reference/configuration.md` (frontend keys). |
| `frontend-i18n` | `locale/` | `docs/architecture/frontend.md` (internationalization) for a new language; `docs/about/features.md`. |
| `frontend-tooling` | `package.json`, `angular.json`, ESLint, tsconfig | `docs/frontend/index.md` commands, `docs/guides/testing-and-linting.md`, tech stack and versions (`README.md`, `docs/standards/frontend-angular.md` version note) on a major upgrade. |
| `frontend-other` | A new client app under `clients/`, or anything else | **New app:** follow `docs/frontend/adding-a-client-app.md` checklist for docs: a page under `docs/frontend/` + nav, `docs/reference/ports-and-hostnames.md`, the frontend README stub table, an agent rule if needed. |

## Workspace (`hospitia-master`)

| Area | Change detected | Update |
|---|---|---|
| `dev-environment` | `.devcontainer/`, `.vscode/` | `docs/getting-started/local-setup.md`, `running-the-app.md`, `local-services.md`, `docs/reference/ports-and-hostnames.md`, `docs/guides/debugging.md` (launch configs), `.agents/rules/cloud-sessions.md` for cloud changes. |
| `scripts` | `scripts/*.sh` (master) or `backend/scripts/` | `docs/reference/scripts.md`; `docs/getting-started/cloud-sessions.md` for `cloud_*.sh`; `docs/guides/database-migrations.md` for `create_migration.sh`. |
| `ci-cd` | `jenkins/`, `*/jenkins/` | `docs/operations/ci-cd.md`. |
| `deployment` | `server-setup/` | `docs/operations/deployment.md`, `docs/operations/observability.md`, `docs/reference/ports-and-hostnames.md`. |
| `agent-rules` | `.agents/rules/`, generated rule files, `CLAUDE.md` | `docs/standards/ai-agents.md` if the mechanism changed; run `bash scripts/sync_agent_rules.sh`. |
| `agent-skills` | `.agents/skills/`, `.claude/skills/` | `.agents/skills/README.md` table; run `bash scripts/sync_agent_skills.sh`. |
| `repo-meta` | READMEs, community files, `.github/` in any repository | Keep the three repositories' `.github` templates identical and the stubs within their limits; no other doc impact. |
| `docs-itself` | `docs/`, `mkdocs.yml`, `CHANGELOG.md` | No doc action; the change is the documentation. |

## Always verify

Check these facts on every run, whatever changed, because many pages repeat them:

- the list of services and client apps, and their ports (`docs/architecture/services.md`, `docs/reference/ports-and-hostnames.md`, `README.md`, the stubs);
- the role list (`UserType`) and the always-on agent rules;
- that every page under `docs/` is in the `mkdocs.yml` nav (the strict build checks this).

## Changelog area tags

| Repository / path | Tag |
|---|---|
| `hospitia-frontend` | `[frontend]` |
| `hospitia-backend/services/<service>` | `[backend:<service>]` |
| `hospitia-backend/scripts`, several services at once | `[backend]` |
| `hospitia-master` (dev environment, CI/CD, deployment, scripts, agent tooling) | `[infra]` |
| Documentation only | `[docs]` |
