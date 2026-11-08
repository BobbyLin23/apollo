# Sign in

Sign in opens an existing account's dashboard and rejects a wrong password without leaving the form.

## Sub-features

- `signin-open` shows the welcome-back form.
- `signin-reject` stays on the form for a bad password.
- `signin-submit` opens the dashboard for the matching account.

## How to get to it (user POV)

- Open `/login` and choose `Already have an account? Sign In`.
- After a signed-out visit, the header `Sign In` button lands on create-account first. Choose `Already have an account? Sign In` from there.

## Driving it with Cursor browser

Preconditions:

- `doctor.sh` printed `doctor: ok`.
- The database is reachable.
- An account exists for `verify-apollo@example.test` with password `verify-pass` and name `Verify User`. If sign-up did not create it, this journey fails. Do not insert a row by hand.

- **Open sign-in.** From `Create Account`, choose `Already have an account? Sign In`. The heading is `Welcome Back`. Fields are named `Email` and `Password`.
- **Reject a bad password.** Fill `Email` with `verify-apollo@example.test` and `Password` with `wrong-pass`. Choose `Sign In`. The heading stays `Welcome Back` and a toast shows the server error. The dashboard heading does not appear.
- **Sign in.** Fill `Password` with `verify-pass`. Choose `Sign In`. The heading is `Dashboard`, the page contains `Welcome Verify User`, and it contains `API: This is private`.
- **Proof.** Save the snapshot to `.cursor/skills/verify-apollo/artifacts/sign-in/dashboard.aria.txt` and a screenshot to `.cursor/skills/verify-apollo/artifacts/sign-in/dashboard.png`. Both show `Welcome Verify User`.

## Gotchas

- `/login` defaults to create-account. A heading of `Create Account` means this journey has not reached sign-in.
- Client validation rejects a password shorter than 8 characters before the request. Use `wrong-pass`, which is long enough to be sent.
- A toast that says `Sign in successful` is not proof. The welcome line is the proof.
- Signing in does not create the account. A missing user is a failed precondition, not a reason to run sign-up inside this feature and relabel it.
