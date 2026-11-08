# Theme

Theme switches the site among light, dark, and system from the header. The choice is stored under `vite-ui-theme` and applied as a class on `html`.

## Sub-features

- `theme-open` opens the theme menu from the header.
- `theme-light` sets light and removes the dark class.
- `theme-dark` sets dark and adds the dark class.
- `theme-system` stores system and follows the OS preference.

## How to get to it (user POV)

- Choose `Toggle theme` in the header. It is the icon button beside `Sign In` or the account menu.
- The menu items are `Light`, `Dark`, and `System`.

## Driving it with Cursor browser

Preconditions:

- `doctor.sh` printed `doctor: ok`.
- The home page is open. No account is required.

- **Open the menu.** Run `browser_snapshot` and `browser_click` the button named `Toggle theme`. Menu items `Light`, `Dark`, and `System` are visible.
- **Choose light.** Click `Light`. Run `browser_cdp` with method `Runtime.evaluate` and params `{"expression":"JSON.stringify({theme:localStorage.getItem('vite-ui-theme'),dark:document.documentElement.classList.contains('dark')})","returnByValue":true}`. The result is `{"theme":"light","dark":false}`.
- **Choose dark.** Open `Toggle theme` again and click `Dark`. The same expression returns `{"theme":"dark","dark":true}`.
- **Choose system.** Open `Toggle theme` again and click `System`. The stored theme is `system`. `dark` is true when `matchMedia('(prefers-color-scheme: dark)').matches` is true, and false otherwise.
- **Proof.** Save the light-mode snapshot to `.cursor/skills/verify-apollo/artifacts/theme/light.aria.txt`, a screenshot to `.cursor/skills/verify-apollo/artifacts/theme/light.png`, and the evaluate result to `.cursor/skills/verify-apollo/artifacts/theme/light.json`. The JSON file is `{"theme":"light","dark":false}`.

## Gotchas

- The button's visible contents are icons. Its accessible name is `Toggle theme` from the screen-reader label. Do not click the sun or moon glyph by position.
- The default theme is dark (`defaultTheme="dark"` on the root provider). The first paint can be dark before `localStorage` is read. Assert the evaluate result after the click, not the first paint.
- `Runtime.evaluate` is the read. CDP storage methods are denied in the Cursor browser and are not a substitute.
