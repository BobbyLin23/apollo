# Apollo verification map

This directory is the maintained source for verifying Apollo's web app. Read this index, then use the matching feature file.

## Baseline preconditions

- Run `.cursor/skills/verify-apollo/scripts/launch.sh` and then `.cursor/skills/verify-apollo/scripts/doctor.sh`.
- Doctor prints `doctor: ok`, web `http://localhost:3001/`, and health `{"result":{"data":"OK"}}`.
- Drive only that instance. Ports 3000 and 3001 cannot host a second copy.
- Use a fresh browser tab. A tab that already holds a session cookie makes `createContext` query the database on every tRPC call.
- Sign-up, sign-in, and dashboard need the configured database. If it refuses the connection, those journeys fail.

## Driving conventions

- Start every recipe from the baseline unless its preconditions say otherwise.
- Prefer the accessible name from `browser_snapshot` over CSS selectors or screen coordinates.
- Click and fill with the snapshot `ref` passed to `browser_click` and `browser_fill`.
- Treat shell commands as literal, including the health JSON.
- Leave files in `.cursor/skills/verify-apollo/artifacts/` in place during cleanup.

## Proof and skip reporting

- Capture the user action and the resulting state, not only the final screen.
- UI proof includes the accessibility snapshot and a screenshot that shows the heading named in the feature.
- API proof includes the curl body saved next to that snapshot.
- Account proof includes the dashboard welcome line and the text `API: This is private`.
- Record the feature id and the entry point with the artifacts.
- An unreachable path is a failure. Write the attempted step and the unmet precondition in the report. Do not mark a different entry point as covering it.

## Feature entry contract

Each feature file has an H1, one opening paragraph, then `Sub-features`, `How to get to it (user POV)`, `Driving it with Cursor browser`, and `Gotchas`.

## Features

- [API status](./api-status.md) covers the home page connection indicator and the public health query.
- [Sign up](./sign-up.md) covers creating an account and landing on the dashboard.
- [Sign in](./sign-in.md) covers the existing-account form, a bad password, and a successful sign-in.
- [Dashboard](./dashboard.md) covers the signed-in page and the redirect when there is no session.
- [Theme](./theme.md) covers light, dark, and system from the header control.
