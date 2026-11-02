# Architecture decision records

An architecture decision record (ADR) captures one important decision: the context, what was decided, and the consequences. ADRs explain *why* the system is the way it is, so future contributors don't undo a decision without knowing its reasons.

## Records

| ADR | Title | Status |
|---|---|---|
| [0001](0001-multi-repo-workspace.md) | Multi-repo workspace | Accepted |
| [0002](0002-database-per-service-with-user-replicas.md) | Database per service with user replicas | Accepted |
| [0003](0003-transactional-outbox-in-auth.md) | Transactional outbox in auth | Accepted |
| [0004](0004-messaging-abstraction-over-rabbitmq.md) | Messaging abstraction over RabbitMQ | Accepted |
| [0005](0005-active-organization-header.md) | Active organization header | Accepted |
| [0006](0006-mkdocs-material-for-documentation.md) | MkDocs Material for documentation | Accepted |
| [0007](0007-single-product-changelog.md) | Single product changelog | Accepted |
| [0008](0008-generated-openapi-reference.md) | Generated OpenAPI reference | Accepted |

ADRs 0001–0005 were recorded retroactively in 2026-11 from decisions already visible in the code.

## Writing an ADR

1. Copy the [template](template.md) to `NNNN-short-title.md` with the next number.
2. Fill it in and set the status to **Proposed**.
3. Add it to the table above and to `nav` in `mkdocs.yml`.
4. Open a pull request; when it's merged, the status becomes **Accepted**.

Don't edit an accepted ADR's decision. To change it, write a new ADR that **supersedes** the old one, and set the old one's status to "Superseded by NNNN".
