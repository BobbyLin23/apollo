import type { Session } from "@apollo/auth";
import type { Database } from "@apollo/db";

export type Context = {
  session: Session | null;
  db: Database;
};
