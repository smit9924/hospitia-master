# Frontend standards (Angular / TypeScript)

Rules for code in `hospitia-frontend/clients/`. Write functional, maintainable, performant and accessible code following Angular and TypeScript best practices.

!!! note "Angular version"
    The main app currently depends on Angular 21 (`@angular/core ^21.0.0`). Three rules below cite Angular v22 behaviour: `OnPush` as the default change detection, stable Signal Forms, and the `@Service` decorator. They're kept exactly as agreed.

    TODO (owner): confirm how these three rules apply until the app is upgraded to Angular 22.

## App structure

- The primary app is `frontend/clients/main/`. Future apps also go under `frontend/clients/`.
- Put reusable UI in `components/common/` or the style-guide patterns. Don't duplicate Material wrappers; use the existing services (dialog, snackbar, icon, loader).
- Keep static definitions (API endpoints, app routes, icons, local-storage keys, navigation) in `data/`; keep shared types in `types/`.
- Protect routes with guards; don't scatter ad-hoc auth checks in components when a guard fits.
- Use `environments/` for environment-dependent values; don't hard-code API base URLs in components.

## TypeScript

- Use strict type checking.
- Prefer type inference when the type is obvious.
- Avoid the `any` type; use `unknown` when the type is uncertain.

## Angular

- Always use standalone components over NgModules.
- Must NOT set `standalone: true` inside Angular decorators. It's the default in Angular v20+.
- Do NOT set `changeDetection: ChangeDetectionStrategy.OnPush` explicitly. `OnPush` is the default in Angular v22+.
- Use signals for state management.
- Do NOT use the `@HostBinding` and `@HostListener` decorators. Put host bindings inside the `host` object of the `@Component` or `@Directive` decorator instead.
- Use `NgOptimizedImage` for all static images. (`NgOptimizedImage` doesn't work for inline base64 images.)

### Routing

- Implement lazy loading for feature routes.
- The existing routes in `app.routes.ts` register their components directly (eagerly); a recent change deliberately kept new room-management routes in that style ("use eager route components like the existing routes"). When you extend an existing feature area, match its existing style.

## Components

- Keep components small and focused on a single responsibility.
- Use `input()` and `output()` functions instead of decorators.
- Use `model()` for two-way bound properties with `[(prop)]` syntax instead of pairing `input()` with `output()`.
- Use `computed()` for derived state.
- Use `linkedSignal()` for state derived from multiple reactive sources that must stay synchronized.
- Prefer inline templates for small components.
- Prefer Signal Forms (`@angular/forms/signals`) for new forms. They're stable in Angular v22+ and provide signal-based state, type-safe field access and schema-based validation.
- When not using Signal Forms, prefer Reactive forms to template-driven ones.
- Do NOT use `ngClass`; use `class` bindings instead.
- Do NOT use `ngStyle`; use `style` bindings instead.
- When using external templates or styles, use paths relative to the component TS file.
- Component selectors use the `app-` prefix in kebab-case; directive selectors use the `app` or `custom` prefix in camelCase (enforced by ESLint).

## State management

- Use signals for local component state.
- Use `computed()` for derived state.
- Keep state transformations pure and predictable.
- Do NOT use `mutate` on signals; use `update` or `set` instead.

## Templates

- Keep templates simple and avoid complex logic.
- Use native control flow (`@if`, `@for`, `@switch`) instead of `*ngIf`, `*ngFor`, `*ngSwitch`.
- Use the async pipe to handle observables.
- Don't assume globals (such as `new Date()`) are available.
- Add the review comments described in [HTML and SCSS standards](html-and-scss.md#template-review-comments).

## Services

- Design services around a single responsibility.
- Use the `providedIn: 'root'` option for singleton services.
- Prefer the `@Service` decorator over `@Injectable({providedIn: 'root'})` for new singleton services (Angular v22+).
- Use the `inject()` function instead of constructor injection.

## Internationalization

- Mark user-facing text for translation (`i18n` attributes in templates, `$localize` in TypeScript), as the existing code does, and re-extract with `ng extract-i18n` when you add strings.

## Accessibility

It MUST pass all AXE checks and follow all WCAG AA minimums. See [Accessibility standards](accessibility.md).

## Style and tooling

- ESLint and Prettier must pass (`npm run lint`, `npm run format`); Prettier uses `printWidth` 100 and single quotes.
- Add or update the `*.spec.ts` next to every component, service, guard, pipe or directive you add.
