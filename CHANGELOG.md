# Changelog

All notable changes to Hospitia are recorded in this file, for the whole product across its three repositories.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Each entry starts with the area it affects (`[frontend]`, `[backend:<service>]`, `[infra]`, `[docs]`) and ends with a reference: a pull request (`frontend#6` is pull request 6 in `hospitia-frontend`) or a commit.

How to add entries and cut releases: [Documentation standards](https://github.com/smit9924/hospitia-master/blob/main/docs/standards/documentation.md#changelog-entries) and [Releasing and versioning](https://github.com/smit9924/hospitia-master/blob/main/docs/operations/releasing.md).

## [Unreleased]

### Added

- [docs] Central project documentation in `hospitia-master/docs/`, built with MkDocs Material: getting started, tutorials, architecture, backend and frontend guides, reference (configuration, error codes, roles, generated API reference), standards, operations and decision records.
- [docs] Project landing README, contributing guide, code of conduct (draft), security policy (draft), this changelog, and issue and pull request templates in all three repositories.
- [infra] `scripts/check_docs.sh` (strict documentation build) and `scripts/export_openapi.sh` (generated API reference).

### Changed

- [docs] Scattered READMEs (Jenkins, server setup, services, frontend app) moved into the central documentation; the frontend and backend repositories now keep short pointer READMEs.

## [0.1.0] - 2026-11-02

Baseline of everything built before versioning started (July–November 2026). This version isn't tagged; it summarizes the history up to `hospitia-master@44f89ed`, `hospitia-frontend@f0b5470` and `hospitia-backend@458343e`.

### Added

- [backend:auth] Sign-up for owners and customers, sign-in with username or email, access and refresh tokens with "remember me", forgot and reset password by email, change password, profile, and username availability check.
- [backend:auth] Email verification with one-time codes; verified state carried in fresh tokens. (3b5240d)
- [backend:auth] Provisioning of admins, owners, managers and customers by authorized roles, with a generated initial password sent in a welcome email. (4becf5d)
- [backend:auth] Internal, loopback-only API to create and soft-delete admins, used to bootstrap the first admin. (2ab1296)
- [backend:auth] Transactional outbox that reliably publishes user-created events and welcome emails. (d4a69b0)
- [backend:auth] Local development shortcut: with `ENVIRONMENT=local`, new users are verified and provisioned users get a default password. (b62f8b0)
- [backend:notification] Email delivery from RabbitMQ queues with Jinja templates, retries and dead-letter queues; redesigned forgot-password and verification emails.
- [backend:booking] Organization types, organizations with addresses, and owner, manager and admin memberships.
- [backend:booking] Active organization context through the `X-Active-Organization-Guid` header, with memberships and validation endpoints. (02a2a04)
- [backend:auth] [backend:booking] Managers provisioned directly into an organization. (02a2a04)
- [backend:booking] Currency units (ISO 4217, common subset seeded), default and organization room amenities, and room types with capacity, cost per night and amenities. (backend#4)
- [backend:booking] Rooms with number, floor, room type, status and notes. (backend#5)
- [backend:dashboard] Paginated, searchable and sortable user listings per role.
- [backend:booking] [backend:dashboard] [backend:payment] User replicas kept in sync from user-created events, with retries and dead-letter queues.
- [backend:payment] Service skeleton with database, user replica and health check.
- [backend] Structured logging with request IDs (`X-Request-ID`), JSON logs in production. (f755ebf)
- [frontend] Landing page, sign-in, sign-up (owner and customer), forgot and reset password, and email verification with one-time codes.
- [frontend] Role dashboards, profile, and settings (display and accessibility, change password, privacy).
- [frontend] User listings and creation forms for admins, owners, managers and customers.
- [frontend] Organization types, organizations, organization onboarding and active organization selection. (6c81591)
- [frontend] Room amenities, room types, rooms and currency units. (frontend#6)
- [frontend] Collapsible grouped sidebar shell, Hospitia brand theme ("Forest Sage"), design tokens and a living style guide. (frontend#5)
- [frontend] Light, dark and system themes, large-text and high-contrast-focus preferences.
- [frontend] Translation support with an `en-US` source and a Hindi (`hi`) translation file.
- [infra] Dev container with Postgres, PgAdmin, RabbitMQ, Mailpit and nginx routing of `*.localhost` hostnames.
- [infra] Claude Code cloud sessions: environment setup and bootstrap scripts.
- [infra] Jenkins controller configured as code, agent images, and build-and-deploy pipelines for every service and the frontend.
- [infra] Production server setup: nginx, Postgres, RabbitMQ, and observability with Grafana, Loki and Alloy.
- [infra] Agent skills shared between AI coding tools, with the requirement-gathering skill. (f9efda8)

### Fixed

- [frontend] Users kept a stale token after verifying their email. (8d18042)
- [frontend] Organization memberships are retried while a new account is still being set up. (frontend#2)
- [frontend] Accessibility (AXE) violations on the landing, sign-in and sign-up pages and dialogs. (frontend#5)
- [frontend] Broken created-at and updated-at columns in listing pages. (2b4c90d)
- [backend:booking] [frontend] Address postal code accepted non-numeric characters. (579c700, 0fc670b)

[Unreleased]: https://github.com/smit9924/hospitia-master/compare/44f89ed...HEAD
[0.1.0]: https://github.com/smit9924/hospitia-master/tree/44f89ed
