import { createAuth } from "@apollo/auth";
import { createDb } from "@apollo/db";

import { ENV } from "./env.server";

export const db = createDb(ENV);
export const auth = createAuth(ENV, db);
