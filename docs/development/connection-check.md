# Flutter → backend → database connection

[M1.7 / issue #8](https://github.com/devBuildersunique/ploggr/issues/8) adds
**Profile → Settings → Connection check**. Press **Check connection** to contact
the configured backend. **Connected** means PostgreSQL and PostGIS also passed
the backend's read-only readiness query. No requests run automatically, and no
preview activity, profile, password, or authentication data is sent.

## Laptop setup

Start the database and NestJS using the
[backend guide](../../backend/README.md#first-time-setup). Keep `npm run start:dev`
running. From another terminal, check the default API:

```bash
curl --fail-with-body -i http://127.0.0.1:3000/api/health/ready
```

Expect HTTP `200`, `Cache-Control: no-store`, and:

```json
{"status":"ok","database":"up","postgis":"up"}
```

From the repository root:

```bash
flutter pub get
[ -f config/development.local.json ] || cp config/development.example.json config/development.local.json
```

The current example targets the laptop or a USB-forwarded phone. If your local
file was copied from M1.6's Android Emulator example, edit it to:

```json
{
  "API_BASE_URL": "http://127.0.0.1:3000/api/"
}
```

Launch the desktop app:

```bash
flutter run -d linux --dart-define-from-file=config/development.local.json
```

Advance through onboarding, choose **Explore the preview**, then open **Profile →
Settings → Connection check**. Press the button and expect **Connected**.
**Check again** makes a fresh request. Plain `flutter run` without configuration
still works as an offline preview; its connection button is disabled.

If `flutter` reports `unionfs failed` inside a `newgrp docker` shell, use a normal
terminal or leave that shell with `exit`. On this laptop the installed SDK can
also be invoked directly (this path is installation-specific):

```bash
/opt/flutter/bin/flutter run -d linux --dart-define-from-file=config/development.local.json
```

## Android over USB

Enable developer options and USB debugging, connect a data-capable cable, unlock
the phone, and authorize the laptop. Check its status:

```bash
adb devices -l
```

It must be listed as `device`, not `unauthorized` or `offline`. Replace
`<device-id>` with the entry's first column:

```bash
adb -s <device-id> reverse tcp:3000 tcp:3000
adb -s <device-id> reverse --list
flutter run -d <device-id> --dart-define-from-file=config/development.local.json
```

Use the same `127.0.0.1` URL as the laptop. Forwarding maps the phone's port 3000
to the laptop; NestJS can retain `HOST=127.0.0.1`. Repeat forwarding after a USB
reconnection. If you change the API port, update both forwarding ports and the
Flutter URL together. Remove the forwarding rule when finished:

```bash
adb -s <device-id> reverse --remove tcp:3000
```

The main Android manifest declares Internet access. Debug builds additionally
permit local HTTP through a debug-only network security configuration; release
configuration does not include that allowance. The target SDK is unchanged.
Linux/Android native clients need no browser CORS configuration. iOS/web
validation is outside M1.7. See [device addresses](configuration.md#device-addresses)
for emulator and LAN alternatives.

## Failure and recovery

| Screen state | Next step |
| --- | --- |
| No server configured | Supply the JSON define file and restart Flutter. No request was sent. |
| Server unavailable | Check NestJS, the API address/port, and USB forwarding. |
| Connection timed out | Check server/database availability and retry. |
| Database unavailable | Readiness returned `503`; inspect the database and retry after recovery. |
| Unexpected server response | Confirm the API URL includes `/api/` and points at the correct server. |
| Server check failed | Another HTTP error occurred, such as a wrong route (`404`). |

For a controlled outage test, keep Flutter and NestJS running. Stop a disposable
development database **after** backend startup, from `backend/`:

```bash
docker compose stop database
```

Press **Check again** and expect **Database unavailable**. `/api/health` still
returns `200`; `/api/health/ready` returns `503` with the standard error envelope.
Initial backend startup requires the database to be available.

Restore PostgreSQL from `backend/`:

```bash
npm run db:up
```

Press **Check again** and expect **Connected**. These commands preserve the data
volume but interrupt database access while stopped.

## Automated checks

From the repository root, run the ordinary tests (no backend needed):

```bash
flutter analyze
flutter test
```

From `backend/`, run backend checks and the isolated database integration suite:

```bash
npm run build && npm run lint && npx tsc --noEmit && npm test && npm run test:database
```

The opt-in native test uses real Dio requests against the running stack. From
the repository root, with NestJS and PostgreSQL ready:

```bash
flutter test integration_test/connection_check_test.dart -d linux --dart-define-from-file=config/development.local.json
```

For the USB-authorized phone, first configure forwarding, then run:

```bash
flutter test integration_test/connection_check_test.dart -d <device-id> --dart-define-from-file=config/development.local.json
```

These native tests open Settings and create no domain records. They do not manage
your services. To assert the failure screen with PostgreSQL intentionally stopped,
add `--dart-define=EXPECT_DATABASE_UNAVAILABLE=true` to the native test command.
That declaration is test-only. Restart PostgreSQL and rerun without it to verify
recovery. The [M1.7 maintainer checklist](../../backend/docs/maintenance.md#m17-review-checklist)
describes the API contract and records validation evidence.
