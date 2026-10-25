# Requirement Readiness Checklist (Definition of Ready)

Use this checklist to decide what still needs to be known before a requirement is ready for implementation.

**How to use it**

- Always walk **A. Universal**. Then walk the **B** section for the category and every **C** section for an affected layer.
- Settle each item from code, project docs or the user. It ends up in one of three states: ✅ settled, **N/A** with a reason, or ⏳ open (listed under Open questions).
- Items marked ★ are blocking: don't set `Status: Ready` while any ★ item is open.
- The *italic hints* are example questions. Rephrase them for the actual context and offer concrete options with a recommendation.
- Record the condensed result in the README's "Readiness checklist" section, listing only the items that applied.

## Contents

- A. Universal
- B. By category: fix · enh · feat · ui · refactor · perf · sec · chore · docs · spike
- C. By affected layer: API/backend · data · messaging/integrations · frontend · notifications · cross-cutting NFRs · testing
- D. Exit criteria

---

## A. Universal (every requirement)

- ★ **Goal** stated in one sentence: who benefits, what changes, why it matters.
- ★ **Category** confirmed and consistent with the description.
- ★ **Current behavior verified in code** with `path:line` references, not assumed.
- ★ **Users and roles**: who is affected, and who can see or do what. *Which roles can trigger this? Should anyone be blocked?*
- ★ **Scope boundaries**: explicit in-scope and out-of-scope lists. *Is X part of this, or a follow-up?*
- ★ **Testable acceptance criteria**: Given/When/Then, each traceable to a functional requirement.
- **Priority** (Must / Should / Could) and any deadline or driver behind it.
- **Small enough** (INVEST: Independent, Negotiable, Valuable, Estimable, Small, Testable) to build and verify on its own; otherwise split it.
- **Terminology** matches the domain and codebase (the same names as models, UI labels and existing docs).
- **What and why, not how**: the requirement describes behavior; implementation goes in technical notes only as constraints or guidance.
- **Assumptions** listed, each confirmed or marked unconfirmed.
- **Dependencies**: other teams, services, tickets, external APIs, data or design input.
- **Risks** with mitigations.
- **Definition of done** agreed: tests, docs and review expectations.

## B. By category

### Bug fix (`fix`)

- ★ **Steps to reproduce**: numbered and minimal.
- ★ **Expected vs. actual** behavior.
- ★ **Environment**: local, dev, staging or production; browser/device; user role; data conditions; version or commit.
- **Frequency** (always or intermittent) and **since when**. Check `git log` / `git blame` for a regression window.
- **Severity and impact**: users affected, data loss or corruption, available workaround.
- **Evidence**: error messages, logs, request IDs, screenshots (saved under `assets/`).
- **Root-cause hypothesis** from code inspection (`path:line`), clearly labelled as a hypothesis.
- **Regression test** that would have caught it.
- **Data repair**: do records already affected need fixing? *Should existing bad data be corrected, or only new data handled?*

### Enhancement (`enh`)

- ★ **Baseline**: current behavior documented, including what must stay unchanged.
- ★ **Delta**: before → after, stated explicitly.
- **Backward compatibility** for existing users, stored data, API clients and bookmarks/links.
- **Knock-on impact** on existing tests, docs, settings and related screens.

### New feature (`feat`)

- ★ **User stories**: *As a <role>, I want <capability>, so that <benefit>.*
- ★ **Primary flow** end to end (happy path), plus the key alternative and failure flows.
- **MVP vs. later**: what is deliberately left for a later phase.
- **Entry points**: navigation, triggers, links, notifications.
- **Data lifecycle**: create, read, update, delete; ownership; retention; soft vs. hard delete.
- **Success measure**: how we know it works for users (metric, event or observable outcome).

### UI/UX design change (`ui`)

- ★ **Flow and screens** affected, with a design reference (mockup, screenshot, Figma link) or an agreed textual or ASCII layout.
- ★ **All states** defined: default, loading, empty, error, success, disabled, partial data, long content/overflow.
- **Responsive** behavior on mobile, tablet and desktop.
- **Accessibility** at the project's standard (WCAG AA at minimum): keyboard path, focus order and focus return, labels/ARIA, contrast, screen-reader announcements for dynamic changes.
- **Theming**: works in every supported theme (for example light and dark) using design tokens rather than hard-coded colors.
- **Copy**: exact labels, helper text, validation and error messages, confirmations; localization needs.
- **Reuse**: existing components, styles and patterns to use instead of building new ones.
- **Interaction details**: validation timing, destructive-action confirmation, undo, optimistic updates.

### Refactor / tech debt (`refactor`)

- ★ **Motivation and target**: what is wrong today and what measurably improves (duplication, coupling, complexity, readability).
- ★ **No behavior change**, and how that is verified (existing tests, or characterization tests added first).
- **Boundaries**: modules in and out of scope; incremental steps; how long old and new code coexist.

### Performance (`perf`)

- ★ **Baseline and target**, both measured the same way (for example p95 latency, query time, payload size, bundle size, LCP).
- **Load profile**: data volumes, concurrency, peak periods.
- **Evidence of the bottleneck**: profiling output, query plans, network traces.
- **Trade-offs accepted**: caching staleness, memory, complexity.

### Security (`sec`)

- ★ **Issue**: affected asset, attack scenario, exploitability, severity.
- **Controls**: authentication, authorization, input validation, output encoding, secrets handling, data exposure, audit logging.
- **Disclosure**: keep exploit detail to what the fix needs, and note if the document must stay private.

### DevOps / infra / chore (`chore`)

- **Environments** affected and the order changes roll out in.
- **Configuration**: new or changed settings and environment variables, by **name only** (never values or secrets).
- **CI/CD** pipeline changes; **rollback** plan; downtime expectations.

### Documentation (`docs`)

- **Audience**, **location**, and what is missing, wrong or outdated.

### Spike / research (`spike`)

- ★ **Question to answer** and the **decision it informs**.
- **Timebox**, **expected output** (decision record, proof of concept, comparison) and **decision criteria**.

## C. By affected layer

### API / backend

- **Endpoints**: method, path, request and response schemas, status codes, error format, pagination, filtering and sorting.
- **Access**: authentication and authorization per endpoint; public vs. internal.
- **Business rules and validation**: what is enforced, and in which layer (per the project's layering rules).
- **Concurrency**: idempotency, double-submit, race conditions, transactions.
- **Compatibility**: is this a breaking change? Which clients are affected? Versioning?
- **Conventions**: project exception, layering and configuration patterns (link the doc).

### Data / database

- **Model changes**: entities, fields, types, nullability, defaults, constraints, indexes, foreign keys and their delete behavior.
- **Migration**: forward and rollback, backfill, handling of existing rows, ordering relative to deployments.
- **Data classification**: personal or sensitive data, retention, deletion.
- **Growth**: expected volume and its query impact.

### Messaging / async / integrations

- **Events**: name, producer, consumers, payload schema and versioning.
- **Delivery**: ordering, retries, idempotent consumers, dead-letter handling, outbox or transactional guarantees.
- **External services**: contract, auth, rate limits, timeouts, failure modes and fallbacks.

### Frontend

- **Routing and guards**: new or changed routes and who can reach them.
- **State and data**: where state lives, API calls, caching, loading and error handling.
- **Forms**: fields, validation rules (client and server must match), submit behavior, error display.
- Any visual change also pulls in the **UI/UX** items in section B.

### Notifications (email, in-app, other channels)

- **Trigger**, **recipients**, **channel**, **content/template**, **localization**, **opt-out** and **failure handling**.

### Cross-cutting non-functional requirements

- **Performance**: measurable targets where they matter.
- **Security and privacy**: least privilege, PII handling, audit trail.
- **Reliability**: behavior when dependencies fail; retries and timeouts.
- **Observability**: logs (no secrets or PII), metrics, alerts, correlation/trace IDs.
- **Configuration**: environment-specific values come from configuration, never hard-coded.
- **Rollout**: feature flag, deployment order across services, backward compatibility, rollback.
- **Documentation**: which docs must be updated alongside the change.

### Testing

- **Levels**: unit, integration/API, end-to-end, manual QA scenarios.
- **Test data** and fixtures needed.
- **Regression areas** to recheck.

---

## D. Exit criteria (ready to write)

- Every ★ item is ✅ or N/A with a reason.
- Every functional requirement has at least one acceptance criterion, and every acceptance criterion is testable.
- The user has confirmed the summary (scope and acceptance criteria).
- The requirement doesn't contradict the code, or any contradiction is called out explicitly.
- Remaining open questions are non-blocking and the user has accepted them.
