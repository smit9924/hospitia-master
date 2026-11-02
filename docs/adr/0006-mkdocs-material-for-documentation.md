# 0006: MkDocs Material for documentation

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-11-02 (decided) |
| **Deciders** | Project maintainers |

## Context

Documentation was scattered across the three repositories, partly empty and partly out of date. Contributors and evaluators land on `hospitia-master` first.

## Decision

All documentation lives in `hospitia-master/docs/` as Markdown, organized by the Diátaxis model, and is built with MkDocs Material (`mkdocs.yml`, pinned dependencies in `docs/requirements.txt`). `scripts/check_docs.sh` runs a strict build that fails on broken links and pages missing from the navigation. The frontend and backend repositories keep only short README stubs that link here.

## Alternatives considered

- **Plain Markdown only:** no build step, but no search, navigation or link checking.
- **Docusaurus or VitePress:** richer UI, but adds a Node.js build to the master repository.

## Consequences

- One searchable site, readable as plain Markdown on GitHub too.
- Publishing the site (for example GitHub Pages) and a CI check are follow-ups.
- Python tooling (uv) is needed to build the docs, which the project already uses.
