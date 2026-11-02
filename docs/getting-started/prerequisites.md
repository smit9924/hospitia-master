# Prerequisites

This page lists what you need before you set up Hospitia locally with the dev container. For Claude Code cloud sessions, see [Claude Code cloud sessions](cloud-sessions.md) instead.

## Tools

| Tool | Why | Install |
|---|---|---|
| **WSL2** (Windows only) | The dev container and scripts run in Linux. | [Microsoft WSL2 guide](https://learn.microsoft.com/en-us/windows/wsl/install) |
| **Docker and Docker Compose** | Runs the dev container and Postgres, PgAdmin, RabbitMQ and Mailpit. On Windows, install Docker inside WSL2. | [Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/) |
| **Git** | Cloning the three repositories. | [Installing Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) |
| **Visual Studio Code** | Opens the workspace in the dev container and provides tasks and debug configurations. | [Visual Studio Code](https://code.visualstudio.com/) |

You do **not** need Python, Node.js or uv on your machine: the dev container provides Python 3.13, Node.js 20, uv and nginx.

## Access

You need read access (and write access to contribute) to all three repositories:

- [hospitia-master](https://github.com/smit9924/hospitia-master)
- [hospitia-frontend](https://github.com/smit9924/hospitia-frontend)
- [hospitia-backend](https://github.com/smit9924/hospitia-backend)

The repositories are private. Ask a maintainer for access; see [Governance](../community/governance.md).

## Next step

[Local setup (dev container)](local-setup.md)
