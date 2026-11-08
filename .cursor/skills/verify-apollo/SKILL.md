---
name: verify-apollo
description: "Drive the Apollo web app the way a user does and prove home, auth, dashboard, and theme behavior. Use when a change touches apps/web, the Hono API, or session routing and needs evidence from the running app."
---

# Verify Apollo

Apollo's primary surface is the web app at `http://localhost:3001/`. The API listens at `http://localhost:3000/`. The Expo app in `apps/native` is a second surface (`bun run dev:native` from the repo root). This skill does not drive it: that needs a simulator, and it shares this API.

Ports are fixed by `apps/web/vite.config.ts` (`3001`), Bun's dev server (`3000`), and the checked-in env URLs `VITE_SERVER_URL`, `BETTER_AUTH_URL`, and `CORS_ORIGIN`. Two copies cannot run side by side. If either port is taken, `launch.sh` exits and leaves the occupant alone.

Auth features need the database named by `apps/server/.env`. `@apollo/db` connects with the Neon HTTP driver. Against the local Postgres URL, a session lookup requests `https://localhost/sql`. With Postgres not accepting connections, that lookup fails with `ECONNREFUSED`, and sign-up, sign-in, and dashboard cannot be proved. Report that failure. Do not switch the journey to a cookieless health check and call the account flow verified.

## Launch

From the repo root:

```bash
.cursor/skills/verify-apollo/scripts/launch.sh
```

The script starts `bun run dev` in `apps/server` and `apps/web` in a new session, so the servers keep running after the script exits. It writes logs and pids under `.cursor/skills/verify-apollo/run/`, and returns when all of these are true:

- `apps/server` logged `Started development server`
- `apps/web` logged `localhost:3001`
- `curl -fsS http://localhost:3000/` prints `OK`
- `curl -fsS http://localhost:3000/trpc/healthCheck` prints `{"result":{"data":"OK"}}`

Ready means the home API can answer, not that sign-in works. There is no separate seed step. The web app has no local data directory; account rows live in the configured database.

Teardown is `cleanup.sh` below. A failed launch kills the processes it started.

## Doctor

```bash
.cursor/skills/verify-apollo/scripts/doctor.sh
```

Run this first whenever a drive looks wrong. It is read-only. It requires the pid files from the latest `launch.sh`, checks those processes are still alive, checks ports 3000 and 3001 are still owned by that process tree, and repeats the `OK` and health JSON checks. A missing pid file means this run did not start the instance. Do not drive it.

Doctor does not prove the database. The last line says so.

## Drive

API status is driven by `.cursor/skills/verify-apollo/scripts/capture-home.sh`. It opens the home page in Google Chrome with a throwaway `--user-data-dir`, so a session cookie already in the daily browser cannot force a database lookup. The other features use the Cursor IDE browser. Lock the tab, then act through snapshot refs. Do not click by coordinates. Do not call CDP `Input.*`. A tab that already holds a session cookie will fail those journeys when Postgres refuses `https://localhost/sql`. Report that failure.

1. `browser_tabs` with action `list`. Then `browser_navigate` with url `http://localhost:3001/` and `newTab` true when a tab already exists.
2. `browser_lock` with action `lock`.
3. `browser_snapshot`. Match controls by role and accessible name. Click or fill with `browser_click` / `browser_fill` and the snapshot `ref`.
4. After each action, snapshot again and wait until the feature file's expected text is present. Status text goes `Checking...` then `Connected` or `Disconnected`. Wait for the settled word.
5. `browser_take_screenshot` for the proof image. Copy the returned file onto the path in the feature file if the tool did not write that path.
6. `browser_lock` with action `unlock` when the drive is finished.

Shell checks that are part of a journey:

```bash
curl -fsS http://localhost:3000/trpc/healthCheck
```

The feature map is `.cursor/skills/verify-apollo/features/README.md`. A proof of one entry point is incomplete when the map lists others. Drive the entry point the task names.

## Evidence

Write proof under `.cursor/skills/verify-apollo/artifacts/<feature-id>/`. Cleanup must not delete that directory.

Standards:

- Exercise the page a user opens. Do not call `createCaller`, set React state, or hit a test-only route.
- Capture the action and the resulting state. A final screenshot alone is not enough.
- For API status, keep the curl body next to the snapshot that shows `Connected`.
- For sign-up and sign-in, the resulting state is the dashboard heading plus the welcome line, and a second view is `privateData`'s message `This is private` on that page. A success toast is not persistence.
- For theme, the resulting state is the `html` class and `localStorage["vite-ui-theme"]`, read with `browser_cdp` method `Runtime.evaluate`. Do not use CDP storage commands.
- There is no dry-run mode. A request that returns 500 because the database refused the connection is a failed journey.

## Cleanup

```bash
.cursor/skills/verify-apollo/scripts/cleanup.sh
```

This kills the pid trees `launch.sh` recorded when their commands still contain `bun`, then deletes `.cursor/skills/verify-apollo/run/`. It does not delete `.cursor/skills/verify-apollo/artifacts/`. After cleanup, confirm the artifact files are still on disk and that 3000 and 3001 are no longer owned by those pids.

Keep the feature map current with `/maintain-verification-skill`.
