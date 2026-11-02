# Project Documentation Map

This file is the only place where the skill is wired to a specific project. It says **where** to look, never **what** the project is; the project's own docs remain the single source of truth. When documentation moves (for example into a central docs directory), update this file and nothing else in the skill.

## How to use

1. Pick the section below whose **Detect** rule matches the current workspace. If none matches, use **Any project (fallback)**.
2. Read only the entries relevant to the request and its affected areas.
3. If a listed path doesn't exist, skip it and fall back to discovery; docs move.
4. Link the docs you relied on in the requirement ("Conventions to follow" and "References").

## Hospitia

**Detect:** the workspace root contains both `frontend/clients/` and `backend/services/`.

**Requirements folder:** `.requirements/` at the workspace root, which is the umbrella directory containing both repositories.

**Docs.** The central documentation in `docs/` (index: `docs/index.md`) is the source of truth; prefer it over every other file. Agent rules (`CLAUDE.md`, `.cursor/rules/*.mdc`) summarize the same conventions for coding agents and link to these pages.

| Topic | Where to read |
|---|---|
| Central documentation | `docs/index.md`, then the section below that matches the topic |
| Purpose, features, glossary | `docs/about/` (`vision.md`, `features.md`, `glossary.md`) |
| Workspace layout and architecture | `docs/architecture/` (`workspace.md`, `services.md`, `auth-and-roles.md`, `messaging.md`, `data.md`, `active-organization.md`, `frontend.md`) |
| Decision records | `docs/adr/` |
| Coding standards and agent conventions | `docs/standards/` (`general.md`, `architecture.md`, `backend.md`, `frontend-angular.md`, `html-and-scss.md`, `accessibility.md`, `git.md`, `documentation.md`) |
| Backend overview | `docs/backend/index.md` |
| A backend service | `docs/backend/<service>.md`; endpoints in `docs/reference/api/<service>.md` |
| Frontend: structure, UI/SCSS, Angular, accessibility, theming | `docs/frontend/` and `docs/standards/frontend-angular.md`, `docs/standards/html-and-scss.md` |
| Configuration, error codes, roles, ports, scripts | `docs/reference/` |
| Local development environment | `docs/getting-started/`; `.devcontainer/` |
| CI/CD | `docs/operations/ci-cd.md`; `backend/services/<service>/jenkins/`; `frontend/clients/<app>/jenkins/` |
| Deployment and observability | `docs/operations/deployment.md`, `docs/operations/observability.md` |
| Releasing and the changelog | `docs/operations/releasing.md`; `CHANGELOG.md` |

**Scope codes** for folder names: a backend service directory name from `backend/services/`; `frontend` for `frontend/clients/main`, or the client directory name for other apps under `frontend/clients/`; plus `infra`, `ci` or `multi`.

## Any project (fallback)

Look for these in order and read what exists:

1. A central docs directory such as `docs/`, `documentation/` or `doc/`. Start from its index or README, and include architecture decision records (`docs/adr/`, `docs/decisions/`).
2. Agent instruction files: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/`, `.windsurf/rules/`.
3. `README.md` and `CONTRIBUTING.md`, at the root and in the affected modules.
4. Stack manifests that identify frameworks: `package.json`, `pyproject.toml`, `go.mod`, `pom.xml`, `*.csproj`.
5. API specs and schemas: OpenAPI/Swagger files, GraphQL schemas, migration directories.

**Requirements folder:** `.requirements/` at the workspace root.

**Scope codes:** top-level module, service, package or app directory names.
