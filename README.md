# Project Setup Guide

## Prerequisites

1. **WSL2** - Required for Windows users. Follow the [Microsoft WSL2 installation guide](https://learn.microsoft.com/en-us/windows/wsl/install) to install and configure it.
2. **VS Code** - Download and install [Visual Studio Code](https://code.visualstudio.com/).
3. **Docker & Docker Compose** - Ensure [Docker and Docker Compose](https://docs.docker.com/engine/install/ubuntu/) are installed. Windows users must install Docker within WSL2.
4. **Git** - Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for version control.
5. **PgAdmin4** - Install [PgAdmin4](https://www.pgadmin.org/download/) on your system to connect to the database and access a user-friendly interface for managing database operations

### SSH Key Setup for GitHub

To simplify interactions with GitHub, set up SSH keys:

1. Open a terminal in WSL2.
2. Generate a new SSH key:
   ```bash
   ssh-keygen -t rsa
   ```
   Note: Make sure you are storing ssh keys in default file namely id_rsa and id_rsa.pub.
3. To copy the public part of your SSH key, run the following command:
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```
4. Add the SSH Key to Your GitHub Account

    1. Log into your GitHub account and navigate to **Profile** → **Settings** → **SSH and GPG Keys**.
    2. Click on **New SSH Key** and paste the public key that you copied earlier.
    3. For detailed instructions, refer to the [official GitHub documentation on adding SSH keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

    
Note: If you already have rsa key generated and linked with github account then there is no need to repeat this step.

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
     git clone git@github.com:smit9924/planoluxe.git .
     git clone git@github.com:smit9924/planoluxe-client.git
     git clone git@github.com:smit9924/planoluxe-services.git
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

## Connect to the Database Server Using PgAdmin4

After setting up the project on your local machine and ensuring all containers are running, you may need to connect to your PostgreSQL database server via PgAdmin4 to perform database operations. Follow these steps to connect to the database server with PgAdmin4:

1. **Open PgAdmin4**:  
   On the initial screen, click on the option **"Add New Server"** to connect with your database server.

2. **Configure the Server**:  
   A popup with multiple tabs will appear.

   - **General Tab**:
     Fill following details in Connection tab:
     - **Name**: `planoluxe-db`.

   - **Connection Tab**:  
     Fill following details in Connection tab:
     - **Host name/address**: `127.0.0.1`
     - **Port**: `5432`
     - **Username**: `postgres`
     - **Password**: `password`

3. **Save**:  
   Click the **Save** button at the bottom-right corner of the popup. You will be redirected to the dashboard.

You’re now ready to visualize data and perform DB operation using PgAdmin4!