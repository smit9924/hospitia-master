# Releasing and versioning

How Hospitia is versioned and how to cut a release. Hospitia is released as **one product** across its three repositories.

## Versioning

- Hospitia uses [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`. While the version is `0.x`, minor versions may contain breaking changes.
- One product version covers all three repositories. The current baseline is `0.1.0`; it's recorded in the changelog but not yet tagged.
- Package versions (`version` in each service's `pyproject.toml`, currently `0.1.0`, and in `clients/main/package.json`, currently `0.0.0`) and `environment.prod.ts` `version` aren't bumped automatically. Update them as part of a release when you want them to show the product version.

## The changelog

`CHANGELOG.md` in `hospitia-master` follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/). Every pull request with a user- or operator-visible change adds an entry under `[Unreleased]`; see [Documentation standards](../standards/documentation.md#changelog-entries).

## Cutting a release

1. **Freeze:** make sure everything intended for the release is merged into `main` in all three repositories, and docs are in sync.
2. **Choose the version** from the `[Unreleased]` entries: breaking change → MAJOR (MINOR while in `0.x`), new feature → MINOR, only fixes → PATCH.
3. **Update the changelog** in a pull request to `hospitia-master`:
    - rename `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD` and add a new empty `[Unreleased]` section above it;
    - update the comparison links at the bottom of the file.
4. **Optionally bump versions** in `pyproject.toml` files, `package.json` and `environment.prod.ts` (one pull request per repository).
5. **Tag** the merged commit in **each** repository with the same annotated tag and push it:

    ```bash
    git tag -a vX.Y.Z -m "Hospitia vX.Y.Z"
    git push origin vX.Y.Z
    ```

6. **Create GitHub releases** (optional) using the changelog section as the notes.
7. **Deploy** by running the Jenkins jobs; see [CI/CD with Jenkins](ci-cd.md).

## Hotfixes

Fix on a `fix/` branch from `main`, merge, add the changelog entry, then release a PATCH version as above.
