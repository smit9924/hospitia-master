---
description: Accessibility requirements for frontend UI - AXE and WCAG AA
paths:
  - "frontend/**/*.{ts,html,scss}"
---

# Frontend: accessibility

- The UI MUST pass all AXE checks.
- The UI MUST follow all WCAG AA minimums, including focus management, color contrast and ARIA attributes.
- Every interactive element is keyboard-reachable in a logical order with a visible focus indicator; dialogs move focus in and return it to the opener on close.
- Contrast meets AA in both light and dark themes (use theme tokens).
- Every control has an accessible name (labels / `mat-label`, `aria-label` for icon-only buttons); prefer native elements and Angular Material components to custom ARIA.
- Form errors are shown in text next to the field (not by color alone) and announced; dynamic changes (snackbars, loaders) are announced.
- Layouts work at 200% zoom and with the large-text and high-contrast-focus preferences.
- Meaningful images have alt text; decorative images have empty `alt`.
- Verify: keyboard-only pass, AXE in both themes, `npm run lint` (template accessibility rules).

Details: `docs/standards/accessibility.md`, `docs/frontend/accessibility.md`.
