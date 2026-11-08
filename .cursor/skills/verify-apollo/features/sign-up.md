# Sign up

Sign up creates an email account and opens the dashboard as that person. The login page opens on the create-account form.

## Sub-features

- `signup-open` shows the create-account form.
- `signup-switch` moves to sign-in and back without creating an account.
- `signup-submit` stores the account and shows the dashboard welcome line.
- `signup-invalid` keeps the user on the form when the name, email, or password is rejected.

## How to get to it (user POV)

- Choose `Sign In` in the header. The page heading is `Create Account`.
- Open `http://localhost:3001/login`.
- From the sign-in form, choose `Need an account? Sign Up`.

## Driving it with Cursor browser

Preconditions:

- `doctor.sh` printed `doctor: ok`.
- The database accepts the Neon HTTP connection used by `@apollo/db`. If it does not, stop and report the failure.
- No account already uses `verify-apollo@example.test`. If create-account returns "user already exists", this journey fails. Do not sign in as that user and count it as sign-up.

- **Open the form.** Choose `Sign In`. Run `browser_snapshot`, then `browser_click` on the button named `Sign In`. The heading is `Create Account`. Fields are named `Name`, `Email`, and `Password`.
- **Switch away and back.** Choose `Already have an account? Sign In`. The heading becomes `Welcome Back`. Choose `Need an account? Sign Up`. The heading returns to `Create Account` and the fields are empty.
- **Reject a short password.** Fill `Name` with `Verify User`, `Email` with `verify-apollo@example.test`, and `Password` with `short`. Choose `Sign Up`. The URL stays on `/login`, red text says `Password must be at least 8 characters`, and no dashboard heading appears.
- **Create the account.** Fill `Password` with `verify-pass`. Choose `Sign Up`. The heading becomes `Dashboard`, the page contains `Welcome Verify User`, and it contains `API: This is private`.
- **Proof.** Save the snapshot to `.cursor/skills/verify-apollo/artifacts/sign-up/dashboard.aria.txt` and a screenshot to `.cursor/skills/verify-apollo/artifacts/sign-up/dashboard.png`. Both show `Dashboard` and `Welcome Verify User`.

## Gotchas

- The header button is named `Sign In` even though `/login` first renders `Create Account`.
- A success toast that says `Sign up successful` is not proof. The dashboard welcome line is the proof.
- Name must be at least 2 characters, email must be an email address, and password must be at least 8 characters. Those messages render under the fields in red.
- If the database refuses `https://localhost/sql`, the form stays on `/login` and a toast shows the server error. Record that response. Do not mark sign-up verified from the home page health query.
