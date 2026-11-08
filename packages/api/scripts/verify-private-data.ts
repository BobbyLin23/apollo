import { TRPCError } from "@trpc/server";

import type { Context } from "../src/context.ts";
import { appRouter } from "../src/routers/index.ts";

const SEED = 20261108;
const SESSION_COUNT = 128;

type GateUser = { id: string; name: string; email: string };

function mulberry32(seed: number) {
  let state = seed >>> 0;
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = Math.imul(state ^ (state >>> 15), 1 | state);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function token(rand: () => number, length: number) {
  const alphabet = "abcdefghijklmnopqrstuvwxyz0123456789";
  let out = "";
  for (let i = 0; i < length; i++) {
    out += alphabet[Math.floor(rand() * alphabet.length)];
  }
  return out;
}

const db = {} as Context["db"];
const failures: string[] = [];

function callerFor(session: Context["session"]) {
  return appRouter.createCaller({ session, db });
}

async function checkNullSession() {
  try {
    const data = await callerFor(null).privateData();
    failures.push(
      `1. Call privateData with no session. 2. protectedProcedure should reject it as UNAUTHORIZED before any user payload. 3. The call returned ${JSON.stringify(data)}.`,
    );
  } catch (error) {
    if (error instanceof TRPCError && error.code === "UNAUTHORIZED") return;
    const name = error instanceof Error ? error.name : "unknown";
    const message = error instanceof Error ? error.message : String(error);
    failures.push(
      `1. Call privateData with no session. 2. protectedProcedure should throw TRPCError UNAUTHORIZED. 3. The call threw ${name}: ${message}.`,
    );
  }
}

async function checkSession(user: GateUser) {
  const session = { user } as Context["session"];
  try {
    const data = await callerFor(session).privateData();
    const sameUser =
      data.message === "This is private" &&
      data.user?.id === user.id &&
      data.user?.name === user.name &&
      data.user?.email === user.email;
    if (!sameUser) {
      failures.push(
        `1. Call privateData for session user ${user.id} (${user.email}). 2. The response should be "This is private" for that same user. 3. Got ${JSON.stringify(data)}.`,
      );
    }
  } catch (error) {
    const name = error instanceof Error ? error.name : "unknown";
    const message = error instanceof Error ? error.message : String(error);
    const code = error instanceof TRPCError ? ` ${error.code}` : "";
    failures.push(
      `1. Call privateData for session user ${user.id} (${user.email}). 2. The response should be that user's payload. 3. The call threw ${name}${code}: ${message}.`,
    );
  }
}

const rand = mulberry32(SEED);
const users: GateUser[] = [];
for (let i = 0; i < SESSION_COUNT; i++) {
  users.push({
    id: `user_${token(rand, 8)}`,
    name: `Name ${token(rand, 6)}`,
    email: `${token(rand, 8)}@example.test`,
  });
}

await checkNullSession();
for (const user of users) {
  await checkSession(user);
}

if (failures.length > 0) {
  console.error(`fail: privateData gate (${failures.length} case${failures.length === 1 ? "" : "s"})`);
  for (const failure of failures) console.error(failure);
  process.exit(1);
}

console.log(
  `pass: privateData refused a null session and returned the session user for ${SESSION_COUNT} seeded sessions (seed ${SEED})`,
);
