---
description: What Hospitia is, how the workspace is laid out, and where documentation lives
---

# Project overview

Hospitia is a guest house management system for NGOs.

## Workspace

`hospitia-master` is the umbrella workspace; `frontend/` and `backend/` are separate Git repositories inside it (symlinks to `hospitia-frontend/` and `hospitia-backend/` in cloud sessions).

```text
hospitia-master/
├── frontend/        # hospitia-frontend: Angular apps in clients/ (main app: clients/main)
├── backend/         # hospitia-backend: FastAPI services in services/ (auth, booking, dashboard, payment, notification)
├── .agents/         # agent skills and rules (source of truth)
├── .devcontainer/   # dev container, local infrastructure, nginx routing
├── docs/            # all project documentation (MkDocs)
├── jenkins/         # CI/CD
├── scripts/         # workspace scripts
└── server-setup/    # production infrastructure
```

## Documentation

- `docs/` is the single source of truth for how the project works and its standards. Read the page for the area you change before changing it: `docs/index.md` links every section.
- These rules are summaries; when a rule and a docs page disagree, the docs page wins and the rule must be fixed.

Details: `docs/architecture/workspace.md`, `docs/about/glossary.md`.
