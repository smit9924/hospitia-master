# Typography

The main app **self-hosts its primary UI font** instead of loading it from Google Fonts at runtime.

## Font files

- The **Roboto** font files were downloaded from Google Fonts.
- They're stored in the app under `src/assets/fonts/Roboto`.
- Self-hosting avoids an external runtime dependency and improves performance, reliability and control over font loading.

## Font registration

Global `@font-face` rules in `src/styles/_fonts.scss` register the local font files as web fonts for the whole application.

## Generic font family name

All `@font-face` declarations use a **generic, semantic font-family name**, `FontFamilyUI`, instead of the physical font name (for example `Roboto`).

Why this matters:

- **Future-proofing:** if the UI font changes, only the `src` URLs in the `@font-face` declarations need to be updated.
- **No refactoring:** no changes are needed in CSS, the Angular Material typography configuration or component styles.
- **Single source of truth:** all typography, including the Angular Material M3 theme (`typography: FontFamilyUI` in `_material-theme-config.scss`), references `FontFamilyUI`.

Use Material's typography tokens (for example `var(--mat-sys-body-medium)`) for text styles rather than setting font families or sizes directly. The style guide page (`/style-guide`, **Typography**) shows the available styles.
