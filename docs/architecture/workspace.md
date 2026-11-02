# Workspace and repositories

Hospitia is split across three Git repositories that are used together as one workspace. This page explains the layout and where things belong.

## Layout

`hospitia-master` is the umbrella workspace. The frontend and backend repositories are cloned inside it (or, in cloud sessions, linked into it):

```text
hospitia-master/                 # this repository
├── frontend/                    # hospitia-frontend repository (Angular)
│   └── clients/
│       └── main/                # the main Angular app
├── backend/                     # hospitia-backend repository (FastAPI)
│   ├── scripts/                 # backend helper scripts (migrations)
│   └── services/
│       ├── auth/
│       ├── booking/
│       ├── dashboard/
│       ├── notification/
│       └── payment/
├── .agents/                     # agent skills and rules (source of truth)
├── .claude/, .cursor/           # tool-specific copies generated from .agents/
├── .devcontainer/               # dev container, local infrastructure, nginx routing
├── .github/                     # issue and pull request templates
├── .vscode/                     # tasks and debug configurations
├── docs/                        # this documentation (MkDocs)
├── jenkins/                     # Jenkins controller and agents (CI/CD)
├── scripts/                     # workspace scripts (setup, cloud, docs, sync)
├── server-setup/                # production infrastructure (nginx, Postgres, observability)
├── CHANGELOG.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md
├── mkdocs.yml
└── README.md
```

`frontend/` and `backend/` are listed in the master `.gitignore` (without a trailing slash, so cloud-session symlinks are ignored too). Each of the three repositories has its own history, branches and pull requests.

## What goes where

| You are adding… | Repository and place |
|---|---|
| A backend feature in an existing service | `hospitia-backend/services/<service>/` |
| A new backend service | `hospitia-backend/services/<new-service>/`, plus routing, CI and docs in `hospitia-master` (see the [Backend overview](../backend/index.md)) |
| A frontend feature | `hospitia-frontend/clients/main/src/app/` |
| A new frontend app | `hospitia-frontend/clients/<new-app>/` (see [Adding a client app](../frontend/adding-a-client-app.md)) |
| Dev environment, CI/CD, server config, workspace scripts | `hospitia-master` |
| Documentation of any of the above | `hospitia-master/docs/` |
| Rules for AI coding agents | `hospitia-master/.agents/rules/` |

## Working across repositories

A feature that touches several repositories needs one branch and one pull request per repository. Use the same branch name in each, link the pull requests to each other, and merge them in dependency order (usually backend, then frontend, then master). See [Git and pull requests](../standards/git.md).

## Why multi-repo

See [ADR 0001: Multi-repo workspace](../adr/0001-multi-repo-workspace.md).
