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

**Docs.** `CLAUDE.md` at the workspace root combines all of the `.cursor/rules/*.mdc` files below. Read the topic file you need, or `CLAUDE.md` once; not both.

| Topic | Where to read |
|---|---|
| Central documentation | *Planned, not available yet.* Once it exists, add its index here and prefer it over every entry below. |
| Purpose and workspace layout | `.cursor/rules/project-overview.mdc` |
| Architecture principles and internal-API rules | `.cursor/rules/architectural-principles.mdc` |
| Coding standards and agent conventions | `.cursor/rules/coding-standards.mdc` |
| Backend overview | `backend/README.md` |
| A backend service | `backend/services/<service>/README.md`, plus `.cursor/rules/backend-<service>.mdc` if it exists |
| Frontend: structure, UI/SCSS, Angular, accessibility, theming | `.cursor/rules/frontend-angular.mdc`; `frontend/README.md`; `frontend/clients/<app>/README.md` |
| Local development environment | `README.md`; `.devcontainer/` |
| CI/CD | `jenkins/readme.md`; `backend/services/<service>/jenkins/`; `frontend/clients/<app>/jenkins/` |
| Deployment and observability | `server-setup/README.md` |

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
