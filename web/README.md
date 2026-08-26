# BridgeApp — Web Frontend (Phase 2)

React + Vite. Three working pages: Home, Login, Registration.

## Running it

You need Node.js 18 or newer. Check with `node -v`; if it's missing, install the
LTS build from nodejs.org.

```bash
cd bridgeapp-web
npm install      # once
npm run dev      # then open http://localhost:5173
```

`npm run build` produces a production bundle in `dist/`.

## Pages

| Route | Page | State |
|---|---|---|
| `/` | Home / hero | Buttons route to register and login |
| `/login` | Login | Validates, authenticates against mock data |
| `/register` | Registration | Customer and seller forms, full validation |

## Demo logins

Password for all: **`Demo@123`**

- `bilal@bridgeapp.demo` — customer
- `ayesha@bridgeapp.demo` — seller
- `admin@bridgeapp.demo` — admin

Wrong password, unknown email, and duplicate registration all produce proper
error messages, so the demo doesn't depend on only typing the happy path.

## Folder layout

```
src/
  api/
    client.js      <- ALL network calls live here (currently mocked)
    validate.js    <- shared validation rules
  components/
    Field.jsx      <- one input: text, email, tel, password, textarea, select
    RoleToggle.jsx <- Customer / Seller switch
    Icons.jsx      <- inline SVG icons
    Logo.jsx
  pages/
    Home.jsx / Login.jsx / Register.jsx  (+ matching .css)
  styles/
    global.css     <- design tokens and shared form styles
public/
  logo.png         <- replace with the original high-res logo
  hero.png         <- replace with the full-resolution artwork
```

## Connecting the backend (Phase 3)

The pages never call `fetch` directly — everything goes through
`src/api/client.js`. To go live:

1. In `client.js`, set `USE_MOCK = false`.
2. In `vite.config.js`, uncomment the proxy line so `/api` reaches Express on
   port 4000.
3. Build the matching Express routes: `POST /api/auth/login` and
   `POST /api/auth/register`.

No page component changes. That was the point of the api folder.

**Repeat every validation rule on the server.** Browser validation is a
convenience for the user, not a security control — anyone can bypass it.

## Known gap to resolve in Phase 3

The registration form collects fields the database has no home for:

| Form field | Status in database |
|---|---|
| Address (customer) | Missing — `profiles.location` exists but is a city, not an address |
| Preferred Services | Missing |
| Business / Shop Name | Missing |
| Business Description | Could map to `profiles.bio` |
| Portfolio upload | Missing (needs file storage, not just a column) |

Either add columns to `profiles`, or trim the form. This has to be decided
before the register endpoint can save a complete signup.

## Accessibility notes

Labels are tied to inputs, errors use `aria-invalid` and `aria-describedby`,
the toggle uses proper tab roles, focus rings are visible, and
`prefers-reduced-motion` is respected. Worth a line in your report.
