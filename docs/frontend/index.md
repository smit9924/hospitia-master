# Frontend overview

The frontend lives in the [`hospitia-frontend`](https://github.com/smit9924/hospitia-frontend) repository. Every Angular app is under `clients/`; today there's one, the main app in `clients/main`. It uses Angular 21, Angular Material 21, standalone components and signals. For how the pieces fit together at runtime, see [Frontend architecture](../architecture/frontend.md).

## Source layout (`clients/main/src`)

```text
src/
├── app/
│   ├── app.config.ts       # providers: router, HttpClient + interceptors, error handler, initializer
│   ├── app.routes.ts       # every route, its guards and requiredPermission
│   ├── components/         # UI, one folder per feature
│   ├── data/               # constants: api-routes, app-routes, icon-list, localstorage-keys, sidebar-navigation, app-constants
│   ├── directives/         # reusable DOM behaviour (custom-mat-tooltip, validators)
│   ├── error/              # global error handler
│   ├── guards/             # auth-redirection, permission, organization-onboarding
│   ├── interceptors/       # loader, http-config, auth, active-organization
│   ├── pipes/              # e.g. floor-label
│   ├── services/           # shared logic: auth, profile, dialog, snackbar, icon, loader, layout, localstorage, organization, room, …
│   └── types/              # enums, interfaces, models
├── assets/                 # fonts (Roboto), icons (SVG), images, logo
├── environments/           # environment.ts (dev), environment.prod.ts
├── locale/                 # i18n: messages.en-US.xlf, messages.hi.xlf
└── styles/                 # global styles, utilities, colors, Material theme and overrides
```

### Components by feature

| Folder | Contains |
|---|---|
| `auth/` | Login, signup, forgot/reset password, verify email |
| `common/` | App shell, sidebar, top bar, navbar, footer, page header, search bar, banner, theme toggle, generic dialog and snackbar |
| `dashboards/` | Admin, owner, manager, customer dashboards and the shared overview |
| `listing/`, `user-creation/` | User listings and creation forms per role |
| `organization/`, `onboarding/` | Organization types, organizations, selection dialogs, onboarding |
| `room/`, `room-type/`, `room-amenity/`, `currency-unit/` | Room setup |
| `profile/`, `settings/` | Profile, settings (display and accessibility, change password, privacy) |
| `errors/`, `loaders/` | 403, 404, account-setup-failed; spinners and loaders |
| `landing-page/` | Public landing page |
| `style-guide/` | Living style guide at `/style-guide`: design tokens, typography, icons, UI patterns |

## Working on the app

```bash
cd frontend/clients/main
npm ci
npm start                 # ng serve on 0.0.0.0:8001 → http://main-client.localhost
npm run lint              # ESLint (angular-eslint, typescript-eslint, prettier)
npm run format            # Prettier
npm test                  # unit tests (Vitest via @angular/build:unit-test)
npm run build-production  # production build
```

In a cloud session, run `export PATH=/opt/node20/bin:$PATH` first.

## Conventions in short

- Reusable UI goes in `components/common/` or the style-guide patterns; use the existing dialog, snackbar, icon and loader services instead of new Material wrappers.
- Constants go in `data/`, shared types in `types/`.
- Protect routes with guards rather than checks in components. See [Routes and guards](../guides/routes-and-guards.md).
- Environment-dependent values come from `environments/`; never hard-code API base URLs in components (use `data/api-routes.ts`).
- Component selectors use the `app-` prefix (kebab-case); directive selectors use `app` or `custom` (camelCase). ESLint enforces both.

The full rules are in [Angular and TypeScript standards](../standards/frontend-angular.md), [HTML and SCSS standards](../standards/html-and-scss.md) and [Accessibility](accessibility.md).

## More

- [Styling and theming](styling-and-theming.md)
- [Typography](typography.md)
- [Accessibility](accessibility.md)
- [Adding a client app](adding-a-client-app.md)
