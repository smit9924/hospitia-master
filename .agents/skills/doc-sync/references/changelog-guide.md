# Changelog guide

How to draft `CHANGELOG.md` entries during a sync. The file follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/); the project's own rules are in `docs/standards/documentation.md#changelog-entries`.

## Where entries go

- Only under `## [Unreleased]`, in these subsections and this order: `### Added`, `### Changed`, `### Deprecated`, `### Removed`, `### Fixed`, `### Security`. Create a subsection only when it gets an entry.
- Never edit a released section (`## [X.Y.Z] - date`).

## What gets an entry

| Change | Entry? | Category |
|---|---|---|
| New feature, page, endpoint, setting a user or operator sees | Yes | Added |
| Behaviour, UI, API contract or configuration changed | Yes | Changed |
| Something will be removed in a later release | Yes | Deprecated |
| Feature, endpoint or setting removed | Yes | Removed |
| Bug fix with a user- or operator-visible effect | Yes | Fixed |
| Vulnerability fixed, security hardening | Yes | Security |
| Refactor, tests, lint, formatting, internal renames, CI-only tweaks with no visible effect | No | — |
| Documentation-only changes | Only notable ones (new section, major rewrite) | Added / Changed with `[docs]` |

One entry per user-visible change, not per commit: several commits of one feature (usually one pull request) become one entry.

## Format

```markdown
- [<area tag>] <What changed, for users or operators, in one sentence>. (<reference>)
```

- **Area tag:** see the table at the end of `doc-map.md`. Use two tags when a change spans areas (`[backend:booking] [frontend]`).
- **Sentence:** describe the outcome, not the implementation. "Rooms can be marked as out of service." not "Add OUT_OF_SERVICE to RoomStatus enum."
- **Reference:** the pull request as `<repo>#<number>` (`frontend#6`, `backend#5`, `master#12`), taken from the merge commit subject `Merge pull request #N from …`; otherwise the short commit SHA. Use plain text, or an absolute URL; never a relative link (the file is included in the docs site).

## Avoiding duplicates

Before adding an entry, search the whole file for its reference (`backend#5`, or the SHA). If the reference is already present (in `[Unreleased]` or a release), don't add it again; update the existing `[Unreleased]` entry instead if the change grew.

## Examples

```markdown
## [Unreleased]

### Added

- [backend:booking] [frontend] Rooms with number, floor, room type and status. (backend#5, frontend#6)

### Fixed

- [frontend] Created-at and updated-at columns no longer break the listing layout. (2b4c90d)
```
