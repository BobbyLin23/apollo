---
name: verify-private-data
description: "Prove Apollo's privateData tRPC gate. Use after changes to protectedProcedure, privateData, or packages/api session checks, and when a caller might read private data without a session."
---

# Verify privateData

`privateData` must refuse a caller with no session, and when a session is present it must return that session's user. A break leaks account data to anyone who can hit `/trpc`, even if the dashboard redirect still looks fine.

The check runs the real `protectedProcedure` and `privateData` through `appRouter.createCaller`. It is not a model of the if statement. TypeScript in this repo has no installed proof assistant, and this machine has no Java runtime, so TLA+ is not the rerunnable tool. The question is how the procedure behaves for every session value it branches on, which is a generated-input check of the code.

## When a change touches this

Read the diff of these files before trusting an old pass:

- `packages/api/src/index.ts` — `protectedProcedure`
- `packages/api/src/routers/index.ts` — `privateData`

Coverage was last confirmed at commit `4aeada4224be0868399562062fd24f58360d98f0`. If either file differs from that commit, the check needs another look. Move the commit in this skill forward only after you re-read both functions and confirm this skill still describes them.

`apps/server/src/context.ts` `createContext` and `apps/web/src/routes/_auth/route.tsx` `beforeLoad` are outside this check. A pass says nothing about cookie parsing, `auth.api.getSession`, or the React redirect.

## Run

From the repo root, with Bun (the repo pins `bun@1.4.2`; the command is the same on later 1.4 patch versions):

```bash
bun packages/api/scripts/verify-private-data.ts
```

Exit 0 and a `pass:` line means every case held. Exit 1 prints each failure as a short sequence: the call, the expected result, and what happened. The generator is seeded (`20261108`, 128 sessions plus one null session), so a rerun hits the same users.

The stub `db` is never read. `privateData` does not touch it. Do not point this check at a live database to make it pass.

## What holds, and what does not

Holds, for the seeded set:

- `session: null` throws `TRPCError` with code `UNAUTHORIZED` and returns no user payload.
- A session object returns `message: "This is private"` and `user.id`, `user.name`, and `user.email` from that same session.

Does not hold outside that:

- Better Auth token lookup, password checks, cookie names, or a down database. Those fail in `createContext` before this gate.
- A truthy session whose `user` is missing. `protectedProcedure` only tests `!ctx.session`. `getSession` is typed as `Session | null`, and this check builds sessions the procedure actually reads.
- The browser route guard. An unauthenticated visit to `/dashboard` is a separate promise.

## Tell a bug from a bad run

A returned payload for a null session, an error other than `UNAUTHORIZED` for a null session, or a user that is not the session user is a bug in the covered functions. Report it in those words. Do not weaken the check or edit product code to turn a failure into a pass.

An import error, a missing `node_modules`, or a Bun crash before `pass:` or `fail:` is a setup failure. Fix the environment and rerun the same command.

If `Session` gains required fields that this fixture does not set, re-read `privateData` and `protectedProcedure`. Extend the fixture only for fields those functions read. Do not drop the null session case.

## After an intended change

1. Re-read `protectedProcedure` and `privateData`.
2. Run the command above.
3. If you changed the gate on purpose, update the sentences in this skill so they still match the code, then run again.
4. Replace the sync commit with the new commit only after that pass.

Keep the map honest across later edits with `/maintain-formal-verification-skill`.
