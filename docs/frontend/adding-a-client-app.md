# Adding a client app

New Angular applications belong under `hospitia-frontend/clients/`, next to `clients/main`. Use this checklist when you add one (for example a guest-facing booking site).

1. **Create the app** in `clients/<app-name>/` with the Angular CLI version used by `clients/main` (Angular 21), standalone components, SCSS and the same `eslint.config.js` and Prettier settings.
2. **Reuse the conventions** of `clients/main`: the `src/app` layout (`components/`, `data/`, `guards/`, `interceptors/`, `services/`, `types/`), the `src/styles` structure and theme tokens, and environment files for every API base URL.
3. **Choose ports:** a free local dev port (main uses 8001) and a free production container port (main uses 9001).
4. **Route it locally:** add an nginx site in `.devcontainer/nginx/conf.d/` (for example `<app>.localhost`); cloud sessions pick up the `*.localhost` name automatically. Add the origin to `ALLOWED_ORIGINS` in the backend `.sample.env` and `.sample.cloud-dev.env` files of every service it calls.
5. **Add CI/CD:** `clients/<app-name>/jenkins/` (copy `clients/main/jenkins/`: `Dockerfile`, `Jenkinsfile`, `nginx.conf`, `scripts/validate-repo.sh`) and a job in `hospitia-master/jenkins/job-dsl/frontend/<app-name>.groovy`, listed in `jenkins/casc/jobs.yaml`.
6. **Route it in production:** add a site in `server-setup/nginx/conf.d/`.
7. **Add VS Code tasks** for serve, lint and format in `.vscode/tasks.json`.
8. **Document it:** a page under `docs/frontend/` (and in `mkdocs.yml`), [Ports and hostnames](../reference/ports-and-hostnames.md), the frontend README stub, and an agent rule in `.agents/rules/` if it needs app-specific rules.
