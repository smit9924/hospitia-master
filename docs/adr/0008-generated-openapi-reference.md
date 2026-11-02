# 0008: Generated OpenAPI reference

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-11-02 (decided) |
| **Deciders** | Project maintainers |

## Context

Hand-written endpoint tables drift from the code. FastAPI already produces an accurate OpenAPI document for each service.

## Decision

`scripts/export_openapi.sh` imports each HTTP service's FastAPI app (without starting it or needing Postgres or RabbitMQ, using only the committed `.sample.env`), writes sorted, deterministic JSON to `docs/reference/api/<service>.openapi.json`, and the docs render it with the `neoteroi-mkdocs` OpenAPI plugin (its `OAD` directive). The generated JSON is committed. The script sets `info.title` to name the service and changes nothing else.

`neoteroi-mkdocs` was chosen over Swagger UI embeds (for example `mkdocs-render-swagger-plugin`) because it renders static HTML at build time: no JavaScript from a CDN, works offline, and the content is searchable.

## Alternatives considered

- **Hand-written tables:** readable, but drift.
- **Only the live `/docs` of each service:** always current, but requires running services to read the API.

## Consequences

- The reference is regenerated whenever routes or schemas change (the doc-sync tooling does this).
- Conceptual pages (authentication, active organization, error format) are still written by hand and link to the reference.
