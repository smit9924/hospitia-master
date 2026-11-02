# 0001: Multi-repo workspace

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-11-02 (recorded retroactively) |
| **Deciders** | Project maintainers |

## Context

Hospitia has an Angular frontend, several Python services, and shared infrastructure (dev container, CI/CD, server configuration). Frontend and backend use different toolchains and are deployed independently.

## Decision

We keep three repositories: `hospitia-frontend` (Angular apps under `clients/`), `hospitia-backend` (services under `services/`) and `hospitia-master` (workspace, dev container, Jenkins, server setup, scripts, documentation and agent rules). Developers clone the frontend and backend into `hospitia-master/frontend` and `hospitia-master/backend`, which the master repository ignores; cloud sessions link them there instead.

## Alternatives considered

- **Monorepo:** one history and atomic cross-cutting changes, but mixes toolchains and CI triggers, and the master's infrastructure changes would share history with application code.
- **One repository per service:** maximum independence, but many repositories for a small team and duplicated workspace setup.

## Consequences

- Each repository has its own history, pull requests and Jenkins jobs.
- A feature spanning areas needs one pull request per repository with the same branch name, merged in dependency order.
- Workspace-wide tooling and docs have one home (`hospitia-master`).
