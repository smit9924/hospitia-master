# Standards

These are the rules every change to Hospitia must follow, for people and AI coding agents alike. Reviewers check pull requests against them.

| Page | Covers |
|---|---|
| [General](general.md) | Rules for every change: follow existing patterns, small focused changes, no secrets |
| [Architecture](architecture.md) | Multi-repo layout, service boundaries, layering, messaging, configuration, internal APIs |
| [Backend (Python/FastAPI)](backend.md) | Service layout, layering, exceptions, messaging, models and migrations, logging, style |
| [Frontend (Angular/TypeScript)](frontend-angular.md) | App structure, TypeScript, Angular, components, state, templates, services |
| [HTML and SCSS](html-and-scss.md) | Template comments, style placement, Material overrides, colors, themes, responsiveness |
| [Accessibility](accessibility.md) | AXE and WCAG AA requirements |
| [Git and pull requests](git.md) | Branches, commits, pull requests, reviews, cross-repository changes |
| [Documentation](documentation.md) | Where docs go, how to write them, how to keep them in sync |

## How standards relate to agent rules

AI coding agents (Claude Code, Cursor) read short rule files generated from `.agents/rules/`. Those rules state the must/must-not points and link here for the reasons and examples. These pages are the source of truth: if a rule and a page disagree, fix the rule.

## Changing a standard

Propose the change in a pull request that updates the page here and, when relevant, the matching agent rule. For a significant change, record the reasoning as an [architecture decision record](../adr/index.md).
