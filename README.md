# Project Setup Guide

## Prerequisites

1. **WSL2** - Required for Windows users. Follow the [Microsoft WSL2 installation guide](https://learn.microsoft.com/en-us/windows/wsl/install) to install and configure it.
2. **VS Code** - Download and install [Visual Studio Code](https://code.visualstudio.com/).
3. **Docker & Docker Compose** - Ensure [Docker and Docker Compose](https://docs.docker.com/engine/install/ubuntu/) are installed. Windows users must install Docker within WSL2.
4. **Git** - Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for version control.

5. **Access:** - Make sure you have proper access to the following required repositories:
   - [angular-fastapi-template-master](https://github.com/smit9924/angular-fastapi-template-master)
   - [angular-fastapi-template-frontend](https://github.com/smit9924/angular-fastapi-template-frontend)
   - [angular-fastapi-template-backend](https://github.com/smit9924/angular-fastapi-template-backend)

## Setting up the Project

1. **Open WSL2 Terminal**
   - Start by opening the WSL2 terminal.

2. **Create Project Directory**
   - Create a new directory for the project:
     ```bash
     mkdir Project
     cd Project
     ```

3. **Clone Repositories**
   - Clone the required repositories by running the following commands inside the `Project` directory:
     ```bash
     git clone https://github.com/smit9924/angular-fastapi-template-master .
     git clone https://github.com/smit9924/angular-fastapi-template-frontend
     git clone https://github.com/smit9924/angular-fastapi-template-backend
     ```

4. **Run Initial Setup Script**
   - To install and configure necessary dependencies, execute the `initialSetup.sh` script:
     ```bash
     bash ./initialSetup.sh
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