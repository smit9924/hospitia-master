# Git and pull requests

How to branch, commit and open pull requests in the three Hospitia repositories. These conventions describe what the project already does; follow them so history stays readable.

## Branches

- `main` is the default branch in every repository. Never commit directly to it; every change goes through a pull request.
- Name branches `<type>/<short-kebab-description>`:

| Type | Use for | Example |
|---|---|---|
| `feature/` (or `feat/`) | New features | `feature/room-management` |
| `fix/` | Bug fixes | `fix/retry-memberships-while-account-setup` |
| `task/` | Other planned work | `task/implement-users-listing` |
| `chore/` | Tooling, configuration, dependencies | `chore/cloud-dev-env-samples` |
| `docs/` | Documentation only | `docs/central-documentation` |

- For a change across repositories, use the **same branch name** in each repository.

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/)-style subjects, as the history does:

```text
<type>(<optional scope>): <imperative summary>
```

- Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`.
- Scope: the service or area, for example `feat(booking): add rooms table and model`, `refactor(data): …`.
- Write the summary in the imperative ("add", not "added"), lower case, without a trailing period, ideally under 72 characters.
- Use the body to explain **why** when it isn't obvious.
- Make each commit one logical change that builds on its own. Don't push "temp" commits to shared branches.

## Pull requests

1. Open the pull request against `main` and fill in the template (summary, linked issue, how it was tested, screenshots for UI changes, checklist).
2. Keep pull requests small enough to review; split large work.
3. Before requesting review, make sure:
    - lint passes (`ruff check` / `npm run lint`) and frontend tests pass (`npm test`);
    - you verified the change manually for every affected role (see [Testing and linting](../guides/testing-and-linting.md));
    - docs are updated (or `/doc-sync` was run) and `CHANGELOG.md` `[Unreleased]` has an entry for user-visible changes;
    - `bash scripts/check_docs.sh` passes if you touched `hospitia-master`.
4. Address review comments with new commits; don't rewrite history others have reviewed.
5. Merge with a merge commit (the project's current practice) once approved.

## Changes across repositories

- Open one pull request per repository and link them to each other in the descriptions.
- Merge in dependency order: usually **backend → frontend → master** (master often documents both).
- If a backend change breaks the current frontend, say so in both pull requests and merge them together.

## Reviews

Reviewers check against the [Standards](index.md): layering, exceptions, messaging, migrations and foreign keys, accessibility, theming, no secrets, docs and changelog.
