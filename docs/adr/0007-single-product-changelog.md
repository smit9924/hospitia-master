# 0007: Single product changelog

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-11-02 (decided) |
| **Deciders** | Project maintainers |

## Context

Hospitia is one product delivered from three repositories. Users and operators care about what changed in the product, not in which repository.

## Decision

One `CHANGELOG.md` in `hospitia-master` follows Keep a Changelog 1.1.0 and Semantic Versioning. Each entry starts with an area tag (`[frontend]`, `[backend:<service>]`, `[infra]`, `[docs]`) and ends with a pull request or commit reference. A release tags all three repositories with the same version.

## Alternatives considered

- **One changelog per repository:** closer to the code, but readers must combine three files to understand a release.
- **Generated from commit messages:** less manual work, but requires strict commit linting and produces implementation-level entries.

## Consequences

- Contributors add an `[Unreleased]` entry in the master repository even for frontend or backend changes (or the doc-sync tooling drafts it).
- See [Releasing and versioning](../operations/releasing.md).
