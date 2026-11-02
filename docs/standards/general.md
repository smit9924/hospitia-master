# General standards

Rules for every change in every repository.

## Follow what exists

- **Existing patterns first.** Before introducing a new pattern, find the closest existing implementation and follow it. Match the naming, file layout and error style of the file and service you touch.
- **Respect the layering** of the backend and frontend; see [Architecture standards](architecture.md).
- **Extend, don't duplicate.** When adding cross-cutting behaviour (authentication, messaging, errors, logging), extend the existing abstraction instead of inventing a parallel one.

## Keep changes small and focused

- Prefer small, focused changes that do one thing.
- Avoid drive-by refactors unrelated to the change; propose them separately.
- Leave the code at least as clear as you found it: readable names, docstrings and comments where the reason isn't obvious.

## Never commit secrets

- Don't commit secrets, `.env` files, `.env` values or credentials, and don't paste them into docs, rules, issues or pull requests.
- Configuration that differs between environments belongs in configuration (`.env`, `environments/`), never hard-coded in business logic.
- Local-development credentials that are already in the committed samples may appear only on local-development docs pages, labelled as such.

## Keep docs and changelog in step

- Update the affected documentation pages in the same pull request as the code change (or run `/doc-sync` if available), and add a user-facing entry to the `[Unreleased]` section of `CHANGELOG.md`.
- See [Documentation standards](documentation.md).

## Language and naming

- Use the domain terms from the [Glossary](../about/glossary.md) consistently in code, UI text and docs.
- Write code, comments, commit messages and docs in English.
