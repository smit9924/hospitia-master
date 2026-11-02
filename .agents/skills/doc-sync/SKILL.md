---
name: doc-sync
description: Brings Hospitia's documentation back in line with the code. Finds what changed in hospitia-master, hospitia-frontend and hospitia-backend since the docs were last synced (docs/.sync-state.json), then updates the affected docs pages, the generated OpenAPI reference, the CHANGELOG [Unreleased] section, the agent rules and the repository README stubs, runs the strict docs check, records the new sync point and reports what changed and why. Never commits. Use after merging features, before opening a pull request, or whenever the user asks to update, sync or check the docs, changelog, API reference or agent rules against the code ("/doc-sync", "are the docs up to date?", "update the changelog"). Not for writing whole new documentation sections from scratch.
compatibility: Any coding agent that can run bash, git and python3 and edit Markdown. Regenerating the API reference needs uv and the backend checkout.
metadata:
  author: smit9924
  version: "1.0.0"
---

# Doc sync

Act as the project's technical writer and a senior engineer reviewing every merged change. Your job is to make the documentation describe the code exactly as it is now: no missing features, no stale facts, nothing invented. The result is a set of edits the maintainer reviews and commits.

## Ground rules

- **Facts come only from the code.** Read the diff and the current files; never guess intent. When purpose or business meaning is unclear, write the factual part and add a visible TODO (`!!! note "TODO"`), and list it under "Needs human input" in the report.
- **Never commit, push, stash, checkout, reset or rebase**, and never run `git add`. Read-only git commands (`log`, `diff`, `show`, `rev-parse`, `merge-base`, `status`, `fetch`) are fine.
- **Write only these files:** `docs/**`, `mkdocs.yml`, `CHANGELOG.md`, `README.md`, `.agents/rules/**` and the files `scripts/sync_agent_rules.sh` generates from them, this skill's `references/doc-map.md` and `scripts/collect_changes.sh` (to map new areas), `docs/.sync-state.json`, and the README stubs in `hospitia-frontend` and `hospitia-backend` (repository root, `services/<service>/README.md`, `clients/<app>/README.md`). Never touch application code.
- **Never hand-edit generated files.** Regenerate them: `bash scripts/export_openapi.sh` for `docs/reference/api/*.openapi.json`, `bash scripts/sync_agent_rules.sh` for `.claude/rules/`, `.cursor/rules/` and the `CLAUDE.md` table.
- **No secrets.** Document settings by name and purpose only; never copy values from `.env` files.
- **Follow the docs standards** in `docs/standards/documentation.md`: Diátaxis placement, nav entries, relative links between docs pages, absolute URLs in `CHANGELOG.md`, one H1, no duplication.
- **Be economical with context.** Read the script's summary first; open full diffs only for areas that can affect docs.

Paths below are relative to `hospitia-master/`, which is the folder two levels above this skill's folder.

## Arguments

| Argument | Effect |
|---|---|
| *(none)* | Full run over all three repositories. |
| `--dry-run` | Report what would change; edit nothing and don't update the sync state. |
| `--repo <master\|frontend\|backend>` | Only that repository; the others keep their sync SHA. |
| `--since <repo>=<sha>` | Use this baseline for that repository instead of the stored one (repeatable). |

## Workflow

Preflight → Collect → Plan → Update → Verify → Record → Report.

### 1. Preflight

1. Check that `hospitia-master/frontend` and `hospitia-master/backend` resolve to Git repositories (nested clones locally, symlinks in cloud sessions). If one is missing, stop, name the path, and suggest `--repo` for the repositories that are present.
2. Read `docs/.sync-state.json`.
3. Run the collector (it's read-only):

    ```bash
    bash .agents/skills/doc-sync/scripts/collect_changes.sh [--repo …] [--since …]
    ```

4. For each repository, read `BRANCH`, `UNCOMMITTED_CHANGES` and `STATUS`:
    - **Branch isn't `main`, or there are uncommitted changes:** tell the user, explain that uncommitted changes aren't part of the range and that a feature-branch SHA may disappear after a squash merge, and ask whether to continue.
    - **`baseline-unknown`:** rerun with `--deepen-missing`; if it's still unknown, ask the user for a SHA or to cancel.
    - **`baseline-not-ancestor`** (history rewritten, squash merge): show the merge-base the script printed and ask the user to choose the merge-base, another SHA, or cancel. **Never guess.**
5. If every repository reports `in-sync`, say "Docs are in sync" with the SHAs, change nothing (not even the sync-state date) and stop.

### 2. Collect and plan

For each repository with `STATUS changes`:

1. Read the commit list. Note pull request numbers from merge subjects (`Merge pull request #N from …`) for changelog references.
2. Read the `--- structure` section: every `ADDED_UNIT` or `REMOVED_UNIT` (a backend service or frontend client app) triggers the new-service or new-app row of the doc map, whatever area its files were grouped under.
3. Read the files grouped by area. For each area, look up the targets in [references/doc-map.md](references/doc-map.md).
4. For areas that can affect docs, read the actual diff: `git -C <repo> diff <baseline> HEAD -- <paths>`. Read the current version of the code where the diff alone isn't enough.
5. Check **stale references**: for deleted or renamed files, and for anything the doc map lists under "Always verify", search `docs/`, `.agents/rules/`, `README.md` and the stubs for the old path, name, route, setting, error code or role (`grep -rn`), and plan a fix for each hit.
6. Build a plan: a list of `change → target file → what to write`, plus "no doc impact" with a reason for every remaining change (tests, refactors, formatting, docs-only commits). An area reported as `unmapped` means the doc map needs a new row: plan it.

For a large range (more than about 100 commits), work area by area and say so in the report.

With `--dry-run`, skip to step 6 and report the plan.

### 3. Update

Work through the plan:

- **Docs pages:** edit the page that owns the topic. Create a page only when none does, in the right Diátaxis section, and add it to `nav` in `mkdocs.yml` and to its section's `index.md`. Keep diagrams (Mermaid), tables and examples consistent with the change.
- **API reference:** when `backend-api` changed for auth, booking, dashboard or payment, run `bash scripts/export_openapi.sh <service>`. If the export fails, report the error, continue with everything else, and don't advance that repository's sync SHA.
- **Changelog:** add entries under `[Unreleased]` following [references/changelog-guide.md](references/changelog-guide.md). One entry per user- or operator-visible change, with area tag and reference; skip references already present anywhere in the file.
- **Agent rules:** when a convention, structure or service list changed, edit `.agents/rules/<name>.md` (keep it about 20–60 lines, link to docs), or add a rule for a new service or app, then run `bash scripts/sync_agent_rules.sh`.
- **README stubs:** when a service or client app was added, removed or renamed, or its port or commands changed, update the frontend/backend stub READMEs. Stubs stay short: purpose, port, commands and links only.
- **Doc map:** add rows for new areas to `references/doc-map.md` (and `AREA_RULES` in `scripts/collect_changes.sh`) when you mapped something new, then run `bash scripts/sync_agent_skills.sh` so the Claude Code copy matches.

### 4. Verify

```bash
bash scripts/check_docs.sh
```

It runs the strict MkDocs build and the agent rule and skill drift checks. If it fails, fix the cause and run it again, up to three attempts. If it still fails, stop: leave the edits in place, **don't update the sync state**, and report the failing output.

### 5. Record the sync point

Only after verification passes, and not in `--dry-run`, update `docs/.sync-state.json`:

- each processed repository's SHA becomes the `HEAD` the collector reported (the commit you documented, not a later one);
- repositories excluded with `--repo`, or whose API export failed, keep their old SHA;
- `updated` becomes today's date.

Commits that only change the docs or the sync tooling itself (area `docs-itself`, `agent-rules`, `agent-skills`) count toward the master SHA as "no doc impact".

### 6. Report

Finish with this report in chat:

1. **Range per repository:** `old..new`, number of commits (or "in sync", or "skipped").
2. **Changes and actions:** a table of change → file updated or created, or "no doc impact" with the reason.
3. **Changelog entries added.**
4. **Agent rules changed** (and whether `sync_agent_rules.sh` ran).
5. **Needs human input:** TODOs added, unmapped areas, ambiguous changes, failed exports.
6. **Verification:** the result of `check_docs.sh`.
7. **Nothing was committed.** Suggest a commit message, for example `docs: sync documentation with <repos> up to <short SHAs>`, and remind the user that frontend/backend stub changes are committed in those repositories.

For `--dry-run`, use "would update" wording and say that no files changed.

## Examples

- "/doc-sync" after merging a room-management feature: the collector reports `backend-api`, `backend-data`, `backend-error-codes`, `frontend-routing` and `frontend-components` changes; you regenerate the booking API reference, add the endpoints to `docs/backend/booking.md`, the tables to `docs/architecture/data.md`, the codes to `docs/reference/error-codes.md`, the pages to `docs/about/features.md`, two changelog entries, run the check and advance the SHAs.
- "/doc-sync --dry-run --repo frontend": report which frontend changes would touch which pages, edit nothing.
