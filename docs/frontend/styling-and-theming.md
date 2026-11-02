# Styling and theming

This page explains how styles are organized in `clients/main/src/styles/` and how the light and dark themes work. The rules you must follow are in [HTML and SCSS standards](../standards/html-and-scss.md).

## Stylesheets

`styles.scss` is the single global entry point (configured in `angular.json`). It loads, in order:

| File | Purpose |
|---|---|
| `_fonts.scss` | Self-hosted font registration; see [Typography](typography.md) |
| `_material-theme-config.scss` | Angular Material 3 theme (`mat.theme`) with the Hospitia palettes, typography and density |
| `_theme-colors.scss` | Brand palettes generated with `ng generate @angular/material:theme-color` (primary `#3D7A57`, "Forest Sage") |
| `_material-*-override.scss` | Global overrides per Material component: buttons, card, checkbox, dialog, form field, menu, paginator, sidenav, snackbar, table, toolbar |
| `_utils.scss` | Utility classes and breakpoints (`xxs` 0, `xs` 320, `sm` 576, `md` 768, `lg` 992, `xl` 1200, `xxl` 1400 px) |
| `colors.scss` | App color and surface tokens that Material doesn't provide (CSS custom properties) |
| `global.scss` | Generic global classes |
| `_app-shell.scss` | Layout of the signed-in shell (sidebar, top bar, content) |
| `_page-patterns.scss` | Shared page building blocks: page container and header, listing card and table, empty states, form card and actions, dashboard tiles, skeletons |

Component SCSS is only for styles that are truly specific to that component.

## Colors and tokens

- Use **Angular Material system tokens** (`var(--mat-sys-*)`) first, for example `--mat-sys-on-surface` or `--mat-sys-primary`.
- When Material has no suitable token, use or add an app token in `colors.scss` (for example `--app-color-page-ground`, `--app-color-card`).
- App tokens use CSS `light-dark()`, so they follow the active theme automatically.
- Never write raw hex or rgb values in components.

The live list of tokens is on the style guide page (`/style-guide`, **Design tokens**).

## Light, dark and system themes

- The body uses `color-scheme: light dark`. The theme preference (`ThemePreference`: `theme-light`, `theme-dark`, `theme-auto`) is applied as a body class that sets `color-scheme`, so every `light-dark()` token and Material token switches together.
- `theme-auto` follows the operating system and is the default when the user hasn't chosen.
- Users choose in **Settings → Display and accessibility** or with the theme toggle; the choice is stored in local storage (`preferredTheme`).
- Every screen must work in both themes. Check contrast in both before you open a pull request.

## Accessibility preferences

**Display and accessibility** also offers **large text** and **high-contrast focus** indicators, stored as `largeTextPreference` and `highContrastFocusPreference` and applied to the root document. Don't fix font sizes or focus styles in ways that break these preferences.

## Icons

SVG icons live in `src/assets/icons/` and are registered by name in `data/icon-list.ts` through the `Icon` service (`MatIconRegistry`). Add a new icon by adding the file and an entry to `icon-list.ts`, then use `<mat-icon svgIcon="name">`. The style guide shows every registered icon.

## Responsive design

Layouts must work on mobile, tablet and desktop. Use the breakpoints from `_utils.scss` and the page patterns, which are already responsive.
