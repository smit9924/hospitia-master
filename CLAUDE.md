# Hospitia: agent instructions

Hospitia is a guest house management system for NGOs: an Angular frontend (`frontend/`, repository `hospitia-frontend`) and FastAPI services (`backend/`, repository `hospitia-backend`) inside this workspace repository, `hospitia-master`. Project overview: `README.md`. Full documentation, the source of truth for how things work and the standards: `docs/index.md`.

## How rules work

Rules are short files, one per area, each scoped to the paths it applies to. The table below lists them.

- **Local sessions** started in `hospitia-master` load the always-on rules at start and each path-scoped rule when you touch a matching file (`.claude/rules/`).
- **If `.claude/rules/` was not loaded automatically** (for example a cloud session that starts in the parent folder of `hospitia-master`): read every rule marked "always" now, and before editing any file, read each rule whose paths match it. Paths are relative to `hospitia-master`; in cloud sessions work through `hospitia-master/frontend` and `hospitia-master/backend` so they match.
- Rules state what to do; follow their **Details** links into `docs/` for reasons and examples. If a rule and a docs page disagree, the docs page wins; fix the rule.

## Rules

<!-- BEGIN GENERATED: agent-rules -->
| Rule | Applies to | Read |
|---|---|---|
| agent-workflow: How to work on any change - patterns, scope, secrets, git, docs and changelog | always | `.claude/rules/agent-workflow.md` |
| architecture: Architecture principles every change must respect, including internal-API rules | always | `.claude/rules/architecture.md` |
| cloud-sessions: Claude Code cloud sessions (claude.ai/code) - bootstrap, tools and endpoints; applies only when CLAUDE_CODE_REMOTE=true | always | `.claude/rules/cloud-sessions.md` |
| project-overview: What Hospitia is, how the workspace is laid out, and where documentation lives | always | `.claude/rules/project-overview.md` |
| backend-auth: Auth service - users, tokens, roles, email verification, provisioning and the outbox | `backend/services/auth/**` | `.claude/rules/backend-auth.md` |
| backend-booking: Booking service - organizations, active organization, memberships and room setup | `backend/services/booking/**` | `.claude/rules/backend-booking.md` |
| backend-common: Shared rules for every backend service - layout, layering, exceptions, messaging, config, logging, checks | `backend/**` | `.claude/rules/backend-common.md` |
| backend-dashboard: Dashboard service - read-only user listings built from the user replica | `backend/services/dashboard/**` | `.claude/rules/backend-dashboard.md` |
| backend-database: SQLModel models, relationships and Alembic migrations in backend services | `backend/services/*/*/database/**` | `.claude/rules/backend-database.md` |
| backend-notification: Notification service - message handlers, Jinja templates and SMTP delivery | `backend/services/notification/**` | `.claude/rules/backend-notification.md` |
| backend-payment: Payment service - skeleton with user replica and health check | `backend/services/payment/**` | `.claude/rules/backend-payment.md` |
| documentation: Rules for documentation - where it goes, structure, links, secrets, checks and the changelog | `docs/**`, `**/*.md`, `mkdocs.yml` | `.claude/rules/documentation.md` |
| frontend-accessibility: Accessibility requirements for frontend UI - AXE and WCAG AA | `frontend/**/*.{ts,html,scss}` | `.claude/rules/frontend-accessibility.md` |
| frontend-angular: Angular and TypeScript rules for frontend apps - structure, components, state, templates, services | `frontend/**/*.ts` | `.claude/rules/frontend-angular.md` |
| frontend-templates-styles: HTML template and SCSS rules - review comments, style placement, Material overrides, colors, themes, responsiveness | `frontend/**/*.{html,scss}` | `.claude/rules/frontend-templates-styles.md` |
<!-- END GENERATED: agent-rules -->

## Changing rules

Edit `.agents/rules/<name>.md` (format in `.agents/rules/README.md`), then run `bash scripts/sync_agent_rules.sh`. Never edit `.claude/rules/`, `.cursor/rules/` or the table above by hand; `bash scripts/check_docs.sh` reports drift.
