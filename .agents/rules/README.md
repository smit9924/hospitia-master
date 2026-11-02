# Agent rules

Short, path-scoped rules for AI coding agents, written once and generated into each tool's format.

- **Source of truth:** `.agents/rules/<name>.md`. Edit rules here only.
- **Generated copies (never edit):**
  - `.claude/rules/<name>.md` for Claude Code (`paths:` frontmatter; no `paths` = always loaded);
  - `.cursor/rules/<name>.mdc` for Cursor (`description`, `globs`, `alwaysApply`);
  - the routing table in `CLAUDE.md`, between the `agent-rules` markers.

After editing, run:

```bash
bash ./scripts/sync_agent_rules.sh          # regenerate every copy
bash ./scripts/sync_agent_rules.sh --check  # report drift only (also run by scripts/check_docs.sh)
```

## Rule file format

```markdown
---
description: One line saying what the rule covers
paths:
  - "backend/services/booking/**"
---

# Title

One sentence on what the rule covers.

- Must / must-not bullets, key paths and commands.

Details: links to the docs pages that explain the reasons and show examples.
```

- `description` is required. `paths` lists globs relative to `hospitia-master`; omit it for an always-on rule.
- File names are kebab-case; this README isn't a rule.
- Keep each rule to about 20–60 lines and the always-on rules to about 150 lines in total. Rules state what to do; the explanations and examples live in `docs/` (see `docs/standards/ai-agents.md`).

## Loading in cloud sessions

Path-scoped rules load automatically when Claude Code runs inside `hospitia-master`. Cloud sessions start in the parent folder, so `.claude/rules/` isn't loaded automatically there; `CLAUDE.md` tells the agent to read the always-on rules and, before editing, the rules whose paths match the files. Verified on 2026-11-02 with Claude Code 2.1.316: see `docs/standards/ai-agents.md`.
