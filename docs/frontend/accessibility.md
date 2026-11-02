# Accessibility in the frontend

Hospitia's interface must pass all AXE checks and meet WCAG 2.1 AA. This page explains how the app supports that and how to check your work. The rules themselves are in [Accessibility standards](../standards/accessibility.md).

## What's built in

- **Lint rules:** ESLint runs `angular-eslint`'s template accessibility rules on every HTML template (`npm run lint`).
- **Material components** provide keyboard support and ARIA for form fields, dialogs, menus, tables and paginators. Prefer them to custom controls.
- **Themes:** light and dark themes from tokens, so contrast holds in both. See [Styling and theming](styling-and-theming.md).
- **User preferences:** large text and high-contrast focus indicators in **Settings → Display and accessibility**.
- **Sidebar:** the navigation drawer closes on <kbd>Escape</kbd> from anywhere in the shell.

## How to check a change

1. **Keyboard only:** reach every control with <kbd>Tab</kbd> / <kbd>Shift</kbd>+<kbd>Tab</kbd>, in a logical order, with a visible focus indicator; operate it with <kbd>Enter</kbd> / <kbd>Space</kbd>; close dialogs with <kbd>Escape</kbd>, and confirm focus returns to the control that opened them.
2. **AXE:** run the axe DevTools browser extension (or Lighthouse's accessibility audit, which uses axe) on every changed screen, in light **and** dark theme. Fix every violation.
3. **Screen reader:** check that controls have meaningful names, form errors are announced, and dynamic changes (snackbars, loaders) are announced.
4. **Zoom and large text:** check the screen at 200% zoom and with the large-text preference on.
5. **Lint:** `npm run lint` passes.

Record what you checked in the pull request (the template has a checkbox).
