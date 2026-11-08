# API status

API status shows whether the web app can reach the public health query. The user sees Connected, Checking, or Disconnected under the API Status heading.

## Sub-features

- `status-home` shows the indicator on the home page.
- `status-connected` settles on Connected when `healthCheck` returns OK.
- `status-api` matches that screen to the raw health response.

## How to get to it (user POV)

- Open `http://localhost:3001/`.
- Choose the `Home` link in the header from any other page.

## Driving it with Cursor browser

Preconditions:

- `doctor.sh` printed `doctor: ok`.
- The browser tab has no session cookie.

- **Open home and prove it.** Run `.cursor/skills/verify-apollo/scripts/capture-home.sh`. It opens `http://localhost:3001/` in a throwaway Chrome profile, waits until the rendered page contains the `API Status` heading, the text `Connected`, and the header links `Home` and `Dashboard`, then writes `.cursor/skills/verify-apollo/artifacts/api-status/home.aria.txt`, `home.png`, and `health.json`. `health.json` is exactly `{"result":{"data":"OK"}}`. `Checking...` or `Disconnected` makes the script exit non-zero.

## Gotchas

- A tab that already has a session cookie sends a batched `healthCheck`. `createContext` then queries Postgres through the Neon HTTP driver at `https://localhost/sql`. If that connection is refused, the batched call returns 500 and the page shows `Disconnected` even though a cookieless curl still prints `{"result":{"data":"OK"}}`. Use a fresh tab. Do not call the cookieless curl a substitute for a `Disconnected` screen.
- `Connected` does not prove sign-in. The health query is public and does not read the database when no session lookup runs.
- The ASCII banner is not the page heading. Assert `API Status`.
