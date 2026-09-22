# Flutter QR Code Generator

A Flutter web application that generates QR codes from text or URLs, authenticates users through Cloudflare Access, and persists generated codes to Cloudflare D1 through a Cloudflare Worker.

## How to Run

The Cloudflare Worker, D1 database, and Cloudflare Access configuration used for this assessment are already deployed.

### 1. Install Flutter dependencies

From the project root:

```bash
flutter pub get
```

### 2. Run the app

```bash
flutter run -d chrome --web-port=5000 --dart-define=API_BASE_URL=https://qr-code-worker.halilah-dev.workers.dev
```

### 3. Sign in

Select **Sign in with Cloudflare Access**.

Enter a Gmail address and authenticate using the One-Time PIN sent to the email.

After authentication, the Home screen becomes accessible. Generated QR codes are persisted to D1 and can be viewed from the History screen.

### Run tests

```bash
flutter test
```

The project includes a unit test for parsing persisted QR code data and a widget test for the QR display screen.

---

## Setting Up Your Own Cloudflare Access + D1

The following is only required if you want to use your own Cloudflare environment instead of the deployed assessment backend.

### 1. Create a D1 database

From the `worker` directory:

```bash
npx wrangler d1 create qr-code-db
```

Add the generated database ID to the D1 binding in `worker/wrangler.jsonc`.

The Worker expects the binding name:

```text
qr_code_db
```

### 2. Apply the database migration

The required migration is already included under `worker/migrations`.

Apply it to the new D1 database:

```bash
npx wrangler d1 migrations apply qr-code-db --remote
```

### 3. Deploy the Worker

Install the Worker dependencies:

```bash
npm install
```

Then deploy:

```bash
npx wrangler deploy
```

Wrangler will return the URL of the deployed Worker.

### 4. Configure Cloudflare Access

In Cloudflare Zero Trust:

1. Create an Access application protecting the deployed Worker.
2. Create an Allow policy for the users who should have access.
3. Configure an authentication method such as One-Time PIN.
4. Allow `OPTIONS` requests to reach the Worker for CORS preflight requests.

The Flutter app uses `http://localhost:5000` during development, so the Worker's CORS configuration must allow this origin and credentialed requests.

After authentication, Cloudflare provides the `CF_Authorization` cookie containing the Access JWT. The Flutter app uses a credential-enabled `BrowserClient` so the authenticated session is carried through subsequent API requests to the Worker.

Finally, run Flutter using the URL of your own Worker:

```bash
flutter run -d chrome --web-port=5000 --dart-define=API_BASE_URL=https://YOUR-WORKER.workers.dev
```

---

## Decisions Made

### D1 instead of R2

I chose D1 because each generated QR code only needs structured data:

- input text
- creation timestamp

The QR image itself does not need to be stored because it can be regenerated from the saved text.

R2 would be more appropriate if the application needed to persist the generated image files themselves.

### Worker API

The Flutter app does not communicate directly with D1. It uses a Cloudflare Worker with:

- `POST /codes` to persist a generated code
- `GET /codes` to retrieve persisted history
- `GET /auth/check` to check the current authentication session
- `GET /login` for the Access login flow

This keeps database operations and validation in the backend.

### Authentication

The Home screen is placed behind an authentication gate. The app checks the Cloudflare Access session before allowing the user to reach it.

The authenticated Access cookie is also included in API requests, rather than using Access only as a login screen.

### Error handling

The app handles:

- empty input
- failure to save a generated code
- failure to retrieve history
- missing/invalid authentication state

The Worker also validates the submitted text before inserting it into D1.

---

## What I Would Do With More Time

- Add `DELETE /codes/:id` to revoke/delete persisted codes.
- Add QR image saving and sharing.
- Add a light/dark mode toggle.
- Add more tests for API and authentication failure cases.
- Move the frontend origin and login redirect URL into environment configuration instead of using a fixed localhost development URL.
- Add more detailed backend logging and error responses.

### Platform limitation

The current authentication implementation targets Flutter Web and uses `BrowserClient` to carry the Cloudflare Access browser session.

For a native Flutter application, I would implement a platform-appropriate authentication/session flow rather than relying on the browser-specific client.
