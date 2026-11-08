# Dashboard

Dashboard greets the signed-in user and shows the private API message. Without a session, the app leaves the page and shows the login form instead.

## Sub-features

- `dashboard-open` shows the greeting and the private API line for a signed-in user.
- `dashboard-redirect` sends a signed-out user to the login form.
- `dashboard-header` reaches the same page from the header link.

## How to get to it (user POV)

- Choose `Dashboard` in the header.
- Open `http://localhost:3001/dashboard`.
- Land here after a successful sign-up or sign-in.

## Driving it with Cursor browser

Preconditions:

- `doctor.sh` printed `doctor: ok`.
- For `dashboard-open`, the browser is signed in as `Verify User` (`verify-apollo@example.test`). If sign-in did not establish that session, this journey fails.
- For `dashboard-redirect`, the browser has no session. Sign out first if the header shows a menu named `Verify User`: open that menu and choose `Sign Out`. The app returns to `/`.

- **Signed-in entry.** Choose the `Dashboard` link. The heading is `Dashboard`, the page contains `Welcome Verify User`, and it contains `API: This is private`.
- **Direct URL.** Run `browser_navigate` with url `http://localhost:3001/dashboard` while still signed in. The same heading, welcome line, and API line are present.
- **Signed-out entry.** After `Sign Out`, choose `Dashboard` again. The path is `/login` and the heading is `Create Account`. `Dashboard` and `This is private` are absent.
- **Proof.** Save the signed-in snapshot to `.cursor/skills/verify-apollo/artifacts/dashboard/signed-in.aria.txt` and a screenshot to `.cursor/skills/verify-apollo/artifacts/dashboard/signed-in.png`. Save the signed-out snapshot to `.cursor/skills/verify-apollo/artifacts/dashboard/signed-out.aria.txt`. The signed-in files show `Welcome Verify User`. The signed-out snapshot shows `Create Account` and does not show `This is private`.

## Gotchas

- The redirect target is the create-account form, not the welcome-back form. `Create Account` is the expected signed-out heading.
- The client redirect is not the server gate. `API: This is private` is the private query's message. If the heading renders and that line is missing or is an error toast, the journey fails.
- While the session request is in flight the header shows a skeleton instead of `Sign In` or the user's name. Wait until one of those is visible before choosing `Dashboard`.
