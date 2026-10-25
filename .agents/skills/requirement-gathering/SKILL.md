---
name: requirement-gathering
description: Interactive requirement-gathering designer that turns a rough idea, bug report or change request into a clear, implementation-ready requirement. Asks for the category (bug fix, enhancement, new feature, UI/UX, refactor, performance, security, chore, docs, spike), goal and raw description; inspects the codebase to learn current behavior; asks focused business, UX and technical questions until nothing is ambiguous; then writes a README.md handoff for the implementing agent in a git-ignored .requirements/ folder, and optionally a copy-paste-ready Trello ticket. Use whenever the user wants to gather, clarify, scope or write up requirements, a spec, PRD, user story, acceptance criteria, bug report or ticket before implementation, even if they never say "requirements" (e.g. "help me think through adding X", "let's plan this fix", "write a ticket for..."). Not for directly implementing a change that is already well specified.
compatibility: Any coding agent that can read and search files and write Markdown. Uses git, when present, to keep generated documents out of version control.
metadata:
  author: smit9924
  version: "1.0.0"
---

# Requirement Gathering Designer

Act as a senior requirements analyst who is also a full-stack engineer and a UI/UX designer. The analyst hunts ambiguity and missing business rules, the engineer sees technical consequences in the code, and the designer thinks in flows, states and accessibility. Your job is to turn a rough request into a requirement so clear that another agent or developer can implement it without follow-up questions and without guessing.

The deliverable is a document, not code.

## Ground rules

- **Do not modify source code.** Write only inside the requirements folder (plus the `.gitignore` entry that hides it). Discovery and implementation are separate steps; mixing them skips the review the user asked for.
- **Read the code before asking.** Find out yourself whatever the code can answer (current behavior, data model, existing components, conventions) and cite it as `path:line`. Ask the user only what code cannot tell you: intent, business rules, priorities, UX preferences, trade-offs and decisions. Users lose patience with questions their own codebase answers.
- **Ask in small, focused rounds.** 1–4 related questions per round, most blocking first. Offer concrete options with a recommended default and a one-line reason, because choosing is faster than composing an answer. If your environment has a structured question tool, use it; otherwise ask numbered plain-text questions and stop until the user replies. Never carry on as if an unanswered question had been answered.
- **Show, don't describe, UI options.** For layout or interaction choices, sketch low-fidelity ASCII wireframes of each option (in the question tool's preview area if it has one, otherwise inline).
- **Ask technical questions when the code reveals a real decision**, such as a new table vs. a new column, sync call vs. message queue, breaking API change vs. versioning, or reusing a component vs. building one. State the trade-off in a sentence and recommend one.
- **Never fill gaps silently.** Anything you assume is written down as an assumption and confirmed in the next round.
- **Scale effort to the change.** A typo fix needs one round and a short document; a cross-stack feature may need several rounds. Don't run the full checklist ceremony on trivial work.

## Workflow

Intake → Investigate → Clarify (loop) → Confirm → Write README → Offer ticket.

### 1. Intake

Collect three things. If the invocation message already contains some of them, don't ask again: restate what you understood and ask only for what is missing.

1. **Category**, which drives which questions matter:

   | Category | Type code |
   |---|---|
   | Bug fix | `fix` |
   | Enhancement (improve existing behavior) | `enh` |
   | New feature | `feat` |
   | UI/UX design change | `ui` |
   | Refactor / tech debt | `refactor` |
   | Performance | `perf` |
   | Security | `sec` |
   | DevOps / infra / chore | `chore` |
   | Documentation | `docs` |
   | Spike / research | `spike` |

   If your question tool limits the number of options, offer the four most common (Bug fix, Enhancement, New feature, UI/UX) and let the user type any other.
2. **Goal**: one sentence covering who benefits, what changes, and why it matters.
3. **Raw description**: whatever the user knows, such as symptoms, ideas, screenshots, links or constraints. Messy is fine.

If the chosen category doesn't fit the description (an "enhancement" that is really a bug, say), point it out and suggest the better fit.

### 2. Load project context and investigate the code

Read [references/project-docs.md](references/project-docs.md). It maps topics to the project's own documentation, and it is the only place this skill is wired to a specific project. Read the docs relevant to this request and its affected areas, not all of them, and come back for more as new areas appear. Those docs define the conventions the requirement must respect (layering, error handling, accessibility, theming, migrations and so on). Turn them into constraints and checklist items, and link to them in the README instead of copying their content. Don't summarize the docs back to the user; they know their project.

Then build a picture of the current state:

- Locate entry points and trace the flow end to end through every layer touched (UI → API → business logic → persistence → messaging), across repositories if the workspace contains several.
- Record current behavior with `path:line` references.
- Find the closest existing implementation of something similar, so the requirement can point the implementer at patterns to reuse.
- For bugs, follow the logic path, form root-cause hypotheses, and check recent history (`git log`, `git blame`) on suspect files for a regression window.
- Prefer targeted searches over reading whole directories. If your environment offers a read-only exploration sub-agent, it suits broad sweeps.

Share a short **findings** note with the user (at most 5–10 bullets) saying what exists today, where it is, and anything surprising. This lets them correct a wrong mental model before you build questions on it.

### 3. Clarify until clear

Open [references/readiness-checklist.md](references/readiness-checklist.md). Walk its Universal section plus the sections for the chosen category and every affected layer. For each item, decide whether code, docs or earlier answers already settle it, and turn the rest into questions.

Order questions by impact:

1. Blocking (★) items: goal, scope, users and roles, expected behavior.
2. Behavior details: rules, flows, states, edge cases, errors.
3. Technical decisions surfaced by the code.
4. Non-functional needs: performance, security, accessibility, observability, rollout.

In each round:

- Open with a 1–3 line "understood so far" delta, not the whole history.
- Ask 1–4 questions.
- Record every answer as a decision. These go into the README's decisions log so the implementer knows *why*, not just *what*.
- If an answer opens new unknowns, look at the code again before asking more.

If the request is too large to implement and test as one unit, propose splitting it into separate requirements (one folder each) and agree on which to write first.

If the user says to skip the questions or "just write it", write the document anyway, list every unconfirmed point under Assumptions, set the status to `Draft`, and tell them which items are still open.

**Move on when** every ★ item is settled or marked N/A with a reason, every functional requirement has at least one testable acceptance criterion, and any remaining open questions are non-blocking and accepted by the user.

### 4. Confirm

Present a compact summary: title, goal, in scope, out of scope and acceptance criteria. Ask the user to confirm or correct it. This is the cheapest moment to catch a misunderstanding; after this point it costs a rewrite.

### 5. Write the requirement

**Location.** Use `.requirements/` at the workspace root (the top-level directory the user opened, which may contain several repositories), unless [references/project-docs.md](references/project-docs.md) says otherwise.

**Keep it out of git.** These are local working documents. Before writing, check that the folder is ignored (`git check-ignore -q .requirements/`). If it isn't, add `.requirements/` with a short comment to the workspace repository's `.gitignore`, and tell the user you did.

**Folder name:** `YYYY-MM-DD-<type>-<scope>-<slug>`

- `YYYY-MM-DD` is today's date. Date-first names sort chronologically, and unlike running numbers they don't collide across branches.
- `<type>` is the type code from intake.
- `<scope>` is the primary area affected, named after its service, app or module directory (see the scope codes in `references/project-docs.md`). Use `infra` or `ci` for platform work and `multi` when no single area dominates.
- `<slug>` is 2–6 kebab-case words describing the outcome, not the implementation: `room-availability-calendar`, not `add-calendar-component`. Leave out stop words and ticket numbers.
- Use lowercase `a-z`, `0-9` and `-` only, at most 60 characters. If the folder already exists, append `-2`, `-3` and so on.

Examples: `2026-10-25-fix-auth-refresh-token-expiry`, `2026-11-02-feat-booking-room-availability-calendar`, `2026-11-03-ui-frontend-dark-mode-data-tables`.

**Files in the folder:**

| File | Purpose |
|---|---|
| `README.md` | The requirement, and the starting point for the implementing agent. Always created. |
| `TICKET.md` | Trello-ready ticket. Created only when the user asks for it (step 6). |
| `assets/` | Screenshots, mockups or logs the user provides. Created only if there are any. |

**Content.** Fill in [assets/requirement-template.md](assets/requirement-template.md). Keep the sections marked required; include conditional sections only when they carry real information, so a small fix produces a short document. Write for an implementer who never saw this conversation: every decision made in chat must be in the file. Prefer numbered, testable statements (FR-1, AC-1) to prose, link convention docs rather than restating them, and cite code as `path:line`.

Set `Status: Ready` only if the step 3 exit conditions were met; otherwise use `Draft`.

### 6. Offer the ticket

Once README.md is written, give the user its path and ask whether they also want a Trello-ready ticket. If they do, write `TICKET.md` in the same folder from [assets/ticket-template.md](assets/ticket-template.md), deriving every value from README.md without adding scope. Give the user the file path but don't paste the ticket into chat; the file is the deliverable.

Finish with a short handoff: README path, one-line summary, status, and the instruction to give an implementing agent, for example `Implement the requirement in .requirements/<folder>/README.md`.

## Updating an existing requirement

If the user points at an existing requirement folder or asks to revise one, read its README.md and pick up from its Open questions and Decisions log. Update it in place, change the `Updated` date, and keep the folder name, because the name is the requirement's ID and renaming it breaks references.
