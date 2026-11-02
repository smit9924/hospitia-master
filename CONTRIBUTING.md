# Contributing to Hospitia

Thank you for helping build Hospitia. This guide explains how to propose a change, from setting up your workspace to getting your pull request merged. By taking part you agree to follow our [code of conduct](CODE_OF_CONDUCT.md).

Hospitia is developed in three repositories, and this guide applies to all of them:

| Repository | Contains |
|---|---|
| [hospitia-master](https://github.com/smit9924/hospitia-master) | Workspace, dev container, CI/CD, server setup, scripts, agent rules, documentation |
| [hospitia-frontend](https://github.com/smit9924/hospitia-frontend) | Angular client apps |
| [hospitia-backend](https://github.com/smit9924/hospitia-backend) | FastAPI services |

## Ways to contribute

- **Report a bug or request a feature:** open an issue with the matching template in the repository it belongs to. See [Support](https://github.com/smit9924/hospitia-master/blob/main/docs/community/support.md).
- **Improve the documentation:** everything lives in `hospitia-master/docs/`.
- **Fix a bug or build a feature:** pick an open issue, or open one first for anything larger than a small fix so the approach can be agreed before you write code.
- **Report a vulnerability:** privately, following the [security policy](SECURITY.md). Never in a public issue.

## 1. Set up your workspace

Follow [Getting started](https://github.com/smit9924/hospitia-master/blob/main/docs/getting-started/index.md): clone the three repositories into one folder, create the `.env` files, open the dev container, migrate the databases and start the app. Then take the [Product tour](https://github.com/smit9924/hospitia-master/blob/main/docs/tutorials/product-tour.md).

New to the code base? The tutorials walk you through [a backend endpoint](https://github.com/smit9924/hospitia-master/blob/main/docs/tutorials/first-backend-endpoint.md), [a frontend page](https://github.com/smit9924/hospitia-master/blob/main/docs/tutorials/first-frontend-page.md) and [a message flow](https://github.com/smit9924/hospitia-master/blob/main/docs/tutorials/first-message-flow.md).

## 2. Create a branch

Branch from an up-to-date `main` and name the branch `<type>/<short-kebab-description>`, for example `feature/room-availability` or `fix/login-redirect`. Types: `feature/` (or `feat/`), `fix/`, `task/`, `chore/`, `docs/`.

For a change across repositories, use the same branch name in each. See [Git and pull requests](https://github.com/smit9924/hospitia-master/blob/main/docs/standards/git.md).

## 3. Make your change

Follow the [standards](https://github.com/smit9924/hospitia-master/blob/main/docs/standards/index.md). The ones reviewers check most:

- Follow the closest existing implementation; keep changes small and focused; no drive-by refactors.
- **Backend:** routes → services → repositories → models; exceptions through definitions, handlers and the registry; messaging only through the MQ abstraction; every `Relationship()` with an explicit foreign-key column and an Alembic migration.
- **Frontend:** standalone components with signals, `inject()`, native control flow; constants in `data/`; guards for routes; theme tokens, never hard-coded colors; light and dark themes; responsive layouts.
- **Accessibility:** the UI must pass AXE checks and meet WCAG AA.
- **Never commit secrets** or `.env` files.

## 4. Commit

Use Conventional Commits-style messages:

```text
<type>(<optional scope>): <imperative summary>
```

For example `feat(booking): add room status summary` or `fix: keep icons in text color`. Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`. Make each commit one logical change.

## 5. Check your work

| Area | Run |
|---|---|
| Backend service | `uv run ruff check .` in `backend/services/<service>`, plus a manual check of every changed endpoint for each role (there's no automated backend test suite yet) |
| Database changes | `uv run alembic -c ./<service>/database/alembic.ini upgrade head`, then `downgrade -1` and `upgrade head` again |
| Frontend | `npm run lint` and `npm test` in `frontend/clients/main`, plus an AXE check of changed screens in light and dark theme |
| API changes | `bash scripts/export_openapi.sh` in `hospitia-master`, and commit the updated reference |
| Documentation | `bash scripts/check_docs.sh` in `hospitia-master` |

See [Testing and linting](https://github.com/smit9924/hospitia-master/blob/main/docs/guides/testing-and-linting.md).

## 6. Update docs and the changelog

- Update the affected pages in `hospitia-master/docs/` in the same change (or run the `/doc-sync` agent skill, or follow `.agents/skills/doc-sync/SKILL.md` with another agent). Don't add content to the README stubs in the frontend and backend repositories.
- Add a user-facing entry under `[Unreleased]` in [`CHANGELOG.md`](CHANGELOG.md), with its area tag and pull request reference. See [Documentation standards](https://github.com/smit9924/hospitia-master/blob/main/docs/standards/documentation.md).

## 7. Open a pull request

- Open it against `main` and fill in the template: what and why, linked issue, how you tested, screenshots for UI changes, and the checklist.
- For changes across repositories, link the pull requests to each other and say in which order to merge them (usually backend → frontend → master).
- Keep the pull request focused. Respond to review comments with new commits rather than rewriting reviewed history.
- A maintainer merges it once it's approved.

## Working with AI coding agents

If you use Claude Code, Cursor or another agent, it follows the project rules in `CLAUDE.md` and `.agents/rules/`. You're still responsible for every line you submit: review the agent's changes as carefully as your own.

To change a rule, edit `.agents/rules/<name>.md` and run `bash scripts/sync_agent_rules.sh`; never edit `.claude/rules/` or `.cursor/rules/` directly. See [AI coding agents](https://github.com/smit9924/hospitia-master/blob/main/docs/standards/ai-agents.md).

## Questions

Ask in an issue in [hospitia-master](https://github.com/smit9924/hospitia-master/issues). Thank you for contributing!
