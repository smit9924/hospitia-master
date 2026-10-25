# Agent Skills

Shared, tool-agnostic skills that follow the open [Agent Skills specification](https://agentskills.io/specification).

- **Source of truth:** `.agents/skills/`. This is the shared location that several agents scan (for example Codex, Gemini CLI, Cursor and GitHub Copilot; check your tool's docs).
- **Claude Code** reads `.claude/skills/`, which holds a copy. Don't edit the copy. Edit the skill here, then run:

  ```bash
  bash ./scripts/sync_agent_skills.sh          # copy into tool-specific folders
  bash ./scripts/sync_agent_skills.sh --check  # report drift only
  ```

| Skill | Purpose |
|---|---|
| [`requirement-gathering`](requirement-gathering/SKILL.md) | Interactive requirement gathering, producing `.requirements/<id>/README.md` and an optional Trello-ready `TICKET.md` |
