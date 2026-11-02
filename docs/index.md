# Hospitia documentation

Hospitia is a guest house management system for NGOs. These docs cover what Hospitia is, how to run it, how it is built, and how to contribute to it.

## Where to start

| You are… | Start here |
|---|---|
| Evaluating Hospitia for your organization | [About Hospitia](about/index.md) and [Features](about/features.md) |
| A new contributor | [Getting started](getting-started/index.md), then the [Product tour](tutorials/product-tour.md) |
| Building a backend feature | [Backend overview](backend/index.md), [Your first backend endpoint](tutorials/first-backend-endpoint.md), [Backend standards](standards/backend.md) |
| Building a frontend feature | [Frontend overview](frontend/index.md), [Your first frontend page](tutorials/first-frontend-page.md), [Angular standards](standards/frontend-angular.md) |
| Operating a deployment | [Operations](operations/index.md) |
| Looking up a fact (API, error code, setting, port) | [Reference](reference/index.md) |
| Using an AI coding agent | [Standards](standards/index.md); agent rules link to these pages |

## How these docs are organized

The docs follow the [Diátaxis](https://diataxis.fr/) model, so each page has one job:

- **[Tutorials](tutorials/index.md)** teach by walking you through a complete task.
- **[Guides](guides/index.md)** are short recipes for a specific job.
- **[Reference](reference/index.md)** lists facts: endpoints, settings, error codes, ports.
- **[Architecture](architecture/index.md)** and **[About](about/index.md)** explain how and why things are the way they are.
- **[Standards](standards/index.md)** are the rules every change must follow.
- **[Decisions](adr/index.md)** record important architectural decisions and their reasons.

## The three repositories

Hospitia is developed in three Git repositories. This documentation lives in the first one.

| Repository | Contains |
|---|---|
| [`hospitia-master`](https://github.com/smit9924/hospitia-master) | Workspace, dev container, CI/CD (Jenkins), server setup, scripts, agent rules, **this documentation** |
| [`hospitia-backend`](https://github.com/smit9924/hospitia-backend) | FastAPI services: auth, booking, dashboard, payment, notification |
| [`hospitia-frontend`](https://github.com/smit9924/hospitia-frontend) | Angular client apps (today: `clients/main`) |

See [Workspace and repositories](architecture/workspace.md) for how they fit together.

## Contributing to the docs

Docs are Markdown files under `docs/` in `hospitia-master`, built with MkDocs Material. Read [Documentation standards](standards/documentation.md) before you add or change a page.
