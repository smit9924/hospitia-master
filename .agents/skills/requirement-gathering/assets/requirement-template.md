<!--
Requirement template.
- Replace every {placeholder}.
- [required]       keep this section in every requirement.
- [if applicable]  include only when it carries real information; otherwise delete it.
- Keep section numbers stable even when you delete sections, so FR/AC/§ references stay meaningful.
- Delete all HTML comments in the final document.
-->

# {Outcome-focused title, e.g. "Guests can see room availability on a calendar"}

| | |
|---|---|
| **ID** | `{folder name}` |
| **Type** | {Category} (`{type}`) |
| **Scope** | {primary area}; also touches: {other areas, or "none"} |
| **Status** | {Draft \| Ready} |
| **Priority** | {Must \| Should \| Could}, {reason or deadline} |
| **Requested by** | {name or role} |
| **Created / Updated** | {YYYY-MM-DD} / {YYYY-MM-DD} |
| **Suggested branch** | `{type}/{scope}-{slug}` |

> **Implementing agent: start here.**
> 1. This file is the source of truth for scope. Requirements are numbered (FR-n, NFR-n, AC-n) so you can reference them in commits and reviews.
> 2. If **Status** is `Draft`, resolve §15 Open questions with the user before writing code.
> 3. Read the docs in §8.2 Conventions to follow before touching code.
> 4. Start from the files in §8.1 Affected areas and reuse the patterns in §8.3.
> 5. Work through §12 Implementation checklist in order, ticking items as you finish them.
> 6. Don't add scope. If the code contradicts this document or something is ambiguous, stop and ask rather than guess.
> 7. Done means every acceptance criterion in §6 passes and the §11 Test plan has been carried out.

## 1. Summary  <!-- [required] -->

{2–3 sentences: what changes, for whom, and why.}

## 2. Goal and success criteria  <!-- [required] -->

- **Goal:** {one sentence}
- **Success looks like:** {observable outcome or measurable target}

## 3. Current behavior  <!-- [required] -->

{What happens today, verified in code. Cite `path:line`. For a new feature: what exists nearby, and what is missing.}

### 3.1 Reproduction  <!-- [required for fix; delete otherwise] -->

1. {step}
2. {step}

- **Expected:** {…}
- **Actual:** {…}
- **Environment:** {environment, role, browser/device, data conditions, version or commit}
- **Frequency / since:** {always or intermittent; first seen, regression window}
- **Severity / impact:** {who is affected, data impact, workaround}
- **Evidence:** {error text, log lines, request IDs; files in `./assets/`}
- **Root-cause hypothesis:** {`path:line`: reasoning. Hypothesis, to be confirmed during implementation.}

## 4. Users and roles  <!-- [required] -->

| Role | Can see / do | Change introduced |
|---|---|---|
| {role} | {…} | {…} |

## 5. Requirements  <!-- [required] -->

### 5.1 Functional

- **FR-1** The system shall {observable behavior}.
- **FR-2** {…}

### 5.2 UI/UX  <!-- [if applicable] -->

- **Flow:** {entry point → steps → outcome}
- **Layout / design reference:** {`./assets/<file>` or an agreed textual/ASCII layout}
- **States:** default: {…} · loading: {…} · empty: {…} · error: {…} · success: {…} · disabled: {…}
- **Responsive:** {mobile / tablet / desktop behavior}
- **Accessibility:** {keyboard path, focus handling, labels/ARIA, contrast, announcements}
- **Theming:** {behavior in each supported theme; tokens to use}
- **Copy:** {exact labels, helper text, validation and error messages}
- **Reuse:** {existing components, styles or patterns}

### 5.3 Non-functional  <!-- [if applicable] -->

- **NFR-1** {performance / security / privacy / reliability / observability requirement with a measurable target}

## 6. Acceptance criteria  <!-- [required] -->

- **AC-1** (FR-1) Given {context}, when {action}, then {observable result}.
- **AC-2** (FR-1) Given {…}, when {…}, then {…}.

## 7. Scope  <!-- [required] -->

**In scope**

- {…}

**Out of scope**

- {explicitly excluded item, to prevent scope creep; note a follow-up if one is planned}

## 8. Technical notes  <!-- [required] -->

### 8.1 Affected areas

| Repo / area | Path | Change |
|---|---|---|
| {e.g. backend · booking} | `{path}` | {add / modify / remove: what} |

### 8.2 Conventions to follow

- `{doc path}`: {which rule applies here, and why}

### 8.3 Patterns to reuse  <!-- [if applicable] -->

- `{path:line}`: {what to follow, and how it maps to this change}

### 8.4 Data model and migrations  <!-- [if applicable] -->

{Entities and fields with types, nullability, defaults, constraints, indexes, foreign keys and delete behavior; migration and rollback; backfill and handling of existing rows.}

### 8.5 API contract  <!-- [if applicable] -->

`{METHOD} {path}`, access: {who / how authorized}

- **Request:** {fields, types, validation}
- **Response:** {status code: body shape}
- **Errors:** {status / error code: when}

### 8.6 Events, integrations and configuration  <!-- [if applicable] -->

{Messages published or consumed, with payload; external services; new configuration keys or environment variables by name only, never values.}

## 9. Edge cases and error handling  <!-- [required unless trivial] -->

| Case | Expected behavior |
|---|---|
| {…} | {…} |

## 10. Assumptions, dependencies and risks  <!-- [if applicable] -->

- **Assumption:** {…} (confirmed / unconfirmed)
- **Dependency:** {…}
- **Risk:** {…} → mitigation: {…}

## 11. Test plan  <!-- [required] -->

- **Unit:** {…}
- **Integration / API:** {…}
- **End-to-end / manual:** {…}
- **Regression:** {existing areas to recheck}

## 12. Implementation checklist  <!-- [required] -->

<!-- Ordered, verb-first tasks, each small enough to verify on its own. -->

- [ ] {e.g. Add `<field>` to `<model>` with a migration (§8.4)}
- [ ] {…}
- [ ] Add tests covering AC-1 … AC-n
- [ ] Update docs: {which, or delete this line}

## 13. Rollout and compatibility  <!-- [if applicable] -->

{Deployment order across services, migration timing, feature flag, backward compatibility, rollback plan.}

## 14. Decisions log  <!-- [required] -->

| # | Question | Decision | Why |
|---|---|---|---|
| D-1 | {…} | {…} | {…} |

## 15. Open questions  <!-- [required; must say "None." when Status is Ready] -->

- None.

## 16. Readiness checklist  <!-- [required] -->

<!-- Condensed result of references/readiness-checklist.md. List only the items that applied: ✅ settled · N/A (reason) · ⏳ open (see §15). -->

- ✅ Goal, users/roles and scope are explicit
- ✅ Current behavior verified in code
- ✅ Every FR has at least one testable AC
- ✅ {category- or layer-specific item, e.g. "Reproduction steps confirmed", "All UI states defined", "Migration rollback defined"}
- N/A {item}: {reason}

## References  <!-- [if applicable] -->

- {project docs consulted, related requirement folders, tickets, external links}
