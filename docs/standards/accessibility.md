# Accessibility standards

Hospitia is used by organizations whose staff and guests have a wide range of abilities and devices. Accessibility is a requirement, not an enhancement.

## Requirements

- The UI **must** pass all AXE checks.
- The UI **must** follow all WCAG AA minimums, including focus management, color contrast and ARIA attributes.

## What that means in practice

- **Keyboard:** every interactive element is reachable and operable with the keyboard, in a logical order, with a visible focus indicator.
- **Focus management:** when a dialog opens, focus moves into it; when it closes, focus returns to the control that opened it. After navigation, focus starts at a sensible place.
- **Contrast:** text and controls meet AA contrast in **both** light and dark themes. Use theme tokens, not hand-picked colors.
- **Names and roles:** every control has an accessible name; use native elements and Angular Material components before custom ARIA.
- **Forms:** labels for every field; errors are shown next to the field, described in text (not by color alone) and announced.
- **Dynamic content:** snackbars, loaders and other live updates are announced to screen readers.
- **Text size:** layouts work at 200% zoom and with the large-text preference.
- **Images:** meaningful images have alternative text; decorative ones have empty `alt`.

## How to verify

Follow the checklist in [Accessibility in the frontend](../frontend/accessibility.md#how-to-check-a-change), and state in the pull request what you checked.
