# Check the Flutter connection

Use **Profile → Settings → Connection check** to verify that the app can reach NestJS and that Nest can query PostgreSQL and PostGIS. The action sends a readiness request. Preview activity and profile information stay on the device. [Project quickstart](../../README.md#run-the-complete-foundation)

## Laptop setup

From the repository root, run `make setup` once, then run `make api` in one terminal and `make app` in another. From the splash screen, choose **Skip → Explore the preview → Profile → Settings → Connection check**. Press **Check connection** and expect **Connected**. Press **Check again** to issue a fresh request.

To inspect the backend independently with the default port, run the following command.

```bash
curl --fail-with-body -i http://127.0.0.1:3000/api/health/ready
```

Expect HTTP 200, `Cache-Control: no-store`, and `{"status":"ok","database":"up","postgis":"up"}`. If curl succeeds and Flutter fails, check the device's API URL and relaunch with the corrected build configuration. [Device addresses](configuration.md#device-addresses)

## Android over USB

Enable USB debugging, connect and unlock the phone, and authorize the computer. Run `adb devices -l` and use the ID of the entry whose status is `device`. In the following example, set `DEVICE_ID` to that ID.

```bash
adb -s "$DEVICE_ID" reverse tcp:3000 tcp:3000
adb -s "$DEVICE_ID" reverse --list
make app DEVICE="$DEVICE_ID"
```

Use `http://127.0.0.1:3000/api/` in the local Flutter JSON. Forwarding maps the phone's port to the host API. Repeat the mapping after reconnecting USB. If you choose a different API port, update both ports and the JSON. Remove your mapping when finished.

```bash
adb -s "$DEVICE_ID" reverse --remove tcp:3000
```

Android declares internet access in the main manifest. The debug build additionally permits local HTTP. The emulator can use the host alias `10.0.2.2` directly. [Configuration reference](configuration.md#device-addresses)

## Failure and recovery

| Screen state | What to check |
| --- | --- |
| No server configured | Launch the app with a public API URL. The offline preview remains available. |
| Server unavailable | Check the API process, host, port, and USB forwarding. |
| Connection timed out | Check the network and service health, then retry. |
| Database unavailable | Nest returned HTTP 503. Check PostgreSQL and PostGIS, then press **Check again**. |
| Unexpected server response | Verify the response comes from the configured Ploggr readiness endpoint. |
| Server check failed | Inspect the HTTP status. A wrong prefix can produce a 404. |

Use `make validate` for an isolated outage exercise. For a manual check against a disposable development stack, start Nest while the database is healthy. From `backend/`, run `docker compose stop database`. Liveness at `/api/health` still returns 200 and readiness returns 503. Press **Check again** to see **Database unavailable**. Run `npm run db:up` and retry to see **Connected**. These operations retain the volume.

## Automated checks

From the repository root, run a native test against an already running stack with the device-appropriate config file.

```bash
flutter test integration_test/connection_check_test.dart -d linux --dart-define-from-file=config/development.local.json
```

Substitute the Android device ID for `linux` to exercise the same flow on a phone or emulator. For a deliberate database outage, append `--dart-define=EXPECT_DATABASE_UNAVAILABLE=true` and restore the database afterward. The full runner verifies the database and API outages, both recoveries and the offline path. [Foundation validation report](foundation-validation.md)
