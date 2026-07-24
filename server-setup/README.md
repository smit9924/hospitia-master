# Server Setup Guide

This guide explains how to prepare an Ubuntu/Linux server for deploying the Hospitia application.

> **Assumptions**
>
> * All backend services, frontend services, and the PostgreSQL database will run on the **same server**.
> * The target server is running **Ubuntu/Linux**.

---

## Prerequisites

Ensure the following software is installed on the server before proceeding:

* Git
* Docker
* Docker Compose

---

## Clone the Server Setup Directory

Create a directory for the server setup and clone only the required `server-setup` folder from the repository using Git sparse checkout.

```bash
mkdir server-setup && cd server-setup

git clone --depth 1 --filter=blob:none --sparse git@github.com:smit9924/angular-fastapi-template-master.git .

git sparse-checkout set server-setup
```

---

## Configure Environment Variables

Create the environment file from the provided sample.

```bash
cp .sample.env .env
```

Open the `.env` file and update all variables with values appropriate for your environment.

---

## Start the Infrastructure

Run the following command to start the required infrastructure containers.

```bash
docker compose -f docker-compose.yml up -d
```

---

## Verify the Deployment

Confirm that all containers are running successfully.

```bash
docker compose ps
```

You should see the required infrastructure containers (such as Nginx and PostgreSQL) in the **Up** state.

---

## 🎉 Server Setup Complete

Your server is now ready for application deployment.

Once your frontend and backend services are deployed and connected to the shared Docker network, they will be accessible through the configured Nginx reverse proxy.
