# Project Setup Guide

## Prerequisites

1. **WSL2** - Required for Windows users. Follow the [Microsoft WSL2 installation guide](https://learn.microsoft.com/en-us/windows/wsl/install) to install and configure it.
2. **VS Code** - Download and install [Visual Studio Code](https://code.visualstudio.com/).
3. **Docker & Docker Compose** - Ensure [Docker and Docker Compose](https://docs.docker.com/engine/install/ubuntu/) are installed. Windows users must install Docker within WSL2.
4. **Git** - Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for version control.

5. **Access:** - Make sure you have proper access to the following required repositories:
   - [hospitia-master](https://github.com/smit9924/hospitia-master)
   - [hospitia-frontend](https://github.com/smit9924/hospitia-frontend)
   - [hospitia-backend](https://github.com/smit9924/hospitia-backend)

## Setting up the Project

1. **Open WSL2 Terminal**
   - Start by opening the WSL2 terminal.

2. **Create Project Directory**
   - Create a new directory for the project:
     ```bash
     $ mkdir Project
     $ cd Project
     ```

3. **Clone Repositories**
   - Clone the required repositories by running the following commands inside the `Project` directory:
     ```bash
     $ git clone https://github.com/smit9924/hospitia-master .
     $ mkdir frontend
     $ git clone https://github.com/smit9924/hospitia-frontend ./frontend/.
     $ mkdir backend
     $ git clone https://github.com/smit9924/hospitia-backend ./backend/.
     ```

4. **Run Initial Setup Script**
   - To install and configure necessary dependencies, execute the `scripts/initial_setup.sh` script:
     ```bash
     $ bash ./scripts/initial_setup.sh
     ```

5. **Open Project in VS Code**
   - Open the `Project` directory in Visual Studio Code.

6. **Set Up Dev Containers**
   - Press `Ctrl + Shift + P` to open the Command Palette.
   - Type and select **Dev Containers: Rebuild and Reopen in Container**. This step is only required the first time you open the project in a container.
   - For future sessions, use **Dev Containers: Reopen in Dev Container** instead.

You’re now ready to start working on the project!

## Accessing PgAdmin4 in the Development Setup

PgAdmin4 is already running as part of the development environment. To access it:

1. **Open PgAdmin4**:
   - In your browser, go to [http://localhost:8080](http://localhost:8080).

2. **Login Credentials**:
   - **Email**: `developer@domain.com`
   - **Password**: `password`

Once logged in, you will already be connected to the database server and can view the available databases and their schemas.

> **Note:** If prompted for a password, enter `password`.

You’re now ready to visualize data and perform DB operation using PgAdmin4!


## Claude Code cloud sessions

Cloud sessions on [claude.ai/code](https://claude.ai/code) can't use the devcontainer. The cloud VM acts as the workspace, and only the infrastructure containers run in Docker.

1. **Install the Claude GitHub App** on all 3 repositories: `hospitia-master`, `hospitia-frontend` and `hospitia-backend`.
2. **Create a cloud environment:**
   - Network access: **Trusted**.
   - Setup script: paste the full contents of [`scripts/cloud_env_setup.sh`](scripts/cloud_env_setup.sh).
   - Environment variables: none needed. Each backend service's `.sample.cloud-dev.env` already points Postgres, RabbitMQ and SMTP at `localhost`.
3. **Start a session** with all 3 repositories selected.
4. **Claude runs the bootstrap script**, `bash hospitia-master/scripts/cloud_bootstrap.sh`. It links the sibling repos into `hospitia-master/frontend` and `hospitia-master/backend`, creates missing `.env` files from the cloud variants (`.sample.cloud-dev.env`) of `.sample.env` and starts Postgres, PgAdmin, RabbitMQ, Mailpit and an nginx container (`.devcontainer/docker-compose.cloud.yml`). nginx gives the coding agent the same `*.localhost` routing as the devcontainer, such as `http://main-client.localhost`. See the "Cloud sessions" section of `CLAUDE.md` for endpoints and dev-server commands.
