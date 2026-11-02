# HTML and SCSS standards

Rules for Angular templates and styles in the frontend. [Styling and theming](../frontend/styling-and-theming.md) explains the stylesheet structure these rules refer to.

## Template review comments

In Angular HTML templates, add concise review comments for identifiable UI elements and sections, following the existing convention. Common labels in the code are `Section:`, `Form:`, `TEXT FIELD:`, `BUTTON:`, `TABLE COLUMN:`, `TEXT:`, `MENU ITEM:`, `SEARCH:` and `STATE:`.

```html
<!-- Form: Login -->
<form [formGroup]="loginForm">
  <!-- TEXT FIELD: Email -->
  <mat-form-field>…</mat-form-field>

  <!-- BUTTON: Login -->
  <button mat-flat-button type="submit">…</button>
</form>
```

## Where styles go

When writing HTML and SCSS, follow this order:

1. **Reuse first.** Check `src/styles/global.scss` and `src/styles/_utils.scss` (and the page patterns in `_page-patterns.scss`) for an existing generic, reusable class and use it.
2. **Promote if reusable.** If the styling should be generic and useful elsewhere, add a reusable class to the appropriate global or utils stylesheet and use that.
3. **Otherwise component-scoped.** Write styles in the component's own SCSS only when they're truly component-specific.
4. **Material overrides.** Global Material component styling goes in dedicated files under `src/styles/` (for example `_material-buttons-override.scss`, `_material-dialog-override.scss`, `_material-snackbar-override.scss`, `_material-toolbar-override.scss`, `_material-theme-config.scss`). Don't put Material overrides in component SCSS or `global.scss`.
5. **No hard-coded colors.** Define colors in `src/styles/colors.scss`. Prefer Angular Material color palette and theme tokens to raw hex or rgb values.
6. **Themes.** The app supports light and dark themes; styles must work in both. Use theme tokens and CSS variables, not light-only assumptions.
7. **Responsive.** Layouts and UI must work across viewports (mobile, tablet, desktop).

## Templates and accessibility

- Use semantic HTML (`button` for actions, `a` for navigation, headings in order, `label`s or `mat-label` for every field).
- Every icon-only control needs an accessible name (`aria-label`).
- See [Accessibility standards](accessibility.md).
