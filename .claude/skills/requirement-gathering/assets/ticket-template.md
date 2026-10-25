<!--
Trello ticket template.
- Derive every value from README.md in the same folder. Don't add scope or new requirements.
- Trello card descriptions render Markdown (headings, bold, lists, links, inline code) but NOT tables, so keep tables out of the description.
- Pasting several lines into a checklist's "Add an item" box creates one item per line. Checklist blocks are therefore plain lines, with no "- [ ]" prefixes or blank lines.
- Keep the card title under about 70 characters so it reads well on the board.
- Keep the description self-contained: .requirements/ is git-ignored, so teammates can't open the README.
- Delete all HTML comments in the final file.
-->

# Trello ticket: {title}

Source: [README.md](README.md) · Generated: {YYYY-MM-DD}

Copy each block into the matching Trello field.

## 1. Card title

```text
{type}({scope}): {Outcome in plain words}
```

## 2. Description

````markdown
**Goal:** {one sentence}

{2–3 sentence summary: what changes, for whom, and why.}

### Scope
**In scope**
- {item}

**Out of scope**
- {item}

### Acceptance criteria
- **AC-1** Given {context}, when {action}, then {result}.
- **AC-2** {…}

### Notes
- {key technical constraint, dependency or risk; 3–5 bullets at most}
````

## 3. Checklist: Implementation

```text
{Verb-first task from README §12}
{Verb-first task}
{Verb-first task}
```

## 4. Checklist: QA / Acceptance

```text
AC-1: {short form of the acceptance criterion}
AC-2: {…}
Regression: {area to recheck}
```

## 5. Labels

`{category, e.g. feature | enhancement | bug | ui-ux | refactor | performance | security | chore | docs | spike}` · `{scope}` · `{priority}`
