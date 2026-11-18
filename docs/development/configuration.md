# Development configuration

Run `make setup` from the repository root to install dependencies and create the two local files listed below. Rerunning setup preserves your edits. The offline preview works without either file. [Project quickstart](../../README.md#run-the-complete-foundation)

| Consumer | Committed example | Local file | When changes take effect |
| --- | --- | --- | --- |
| NestJS, database CLI and Compose | [Backend environment](../../backend/.env.example) | `backend/.env` | Restart Nest or rerun the CLI. Container initialization settings apply to a new volume. |
| Flutter | [Public build configuration](../../config/development.example.json) | `config/development.local.json` | Stop and relaunch the app with the define file, or rebuild the artifact. |

## Backend setup and precedence

Nest and the database CLI resolve `backend/.env` from both the TypeScript source and compiled JavaScript entry points. Existing process variables take precedence. An invalid explicit value fails validation. When the process sets `NODE_ENV=test`, both skip the file and use the supplied test environment. Automated database tests provision their own Compose project.

Run direct backend and Compose commands inside `backend/`. For example, `PORT=3001 npm run start:dev` overrides the API port for a single run. `HOST` controls where Nest listens. `DB_HOST` tells Nest where to reach PostgreSQL. The client-facing API address depends on the device.

Choose the application role, database name and both passwords before creating the database. Initialization scripts run once on a fresh volume. Changing an existing role's password requires an administrator SQL change. Multiple checkouts running concurrently need distinct Compose project names and host ports. [Backend variables](../../backend/README.md#configuration) · [Database troubleshooting](../../backend/README.md#troubleshooting)

## Flutter setup

The default local file targets a Linux desktop or a USB-forwarded Android device.

```json
{
  "API_BASE_URL": "http://127.0.0.1:3000/api/"
}
```

Run `make app` from the root. It selects Linux and passes the JSON with `--dart-define-from-file`. Use `make app DEVICE=emulator-5554` with your actual device ID and URL. Use the same Flutter flag for a configured build. The API URL is compiled into the app, so changing it requires a restart or rebuild.

### API URL rules

`AppConfig` accepts an absolute HTTP or HTTPS URL with a hostname and valid port. Credentials, whitespace, a query string, and fragments are rejected at startup. Validation errors name the key without echoing its value. Include the backend's `/api/` prefix. The parser normalizes a missing trailing slash so the relative path `health/ready` preserves that prefix.

When the key is omitted, Flutter runs the offline preview and the connection button is disabled. A configured app sends its first readiness request when the user taps **Check connection**. Tests can override `appConfigProvider` explicitly.

## Device addresses

| Flutter target | API URL with default port | Nest setting |
| --- | --- | --- |
| Linux desktop | `http://127.0.0.1:3000/api/` | `HOST=127.0.0.1` |
| Android emulator | `http://10.0.2.2:3000/api/` | `HOST=127.0.0.1` |
| Physical Android device with USB forwarding | `http://127.0.0.1:3000/api/` | `HOST=127.0.0.1` |
| Device on the same LAN | `http://<computer-LAN-IP>:3000/api/` | `HOST=0.0.0.0` |

For LAN access, use the computer's actual address and allow the API port on the trusted local network. Database access stays on loopback. M1.8 verified Linux and the Android emulator. M1.7 verified a USB-forwarded Android phone. [USB forwarding](connection-check.md#android-over-usb) · [Validation evidence](foundation-validation.md#validation-evidence)

## Public configuration and secrets

Flutter build defines are visible to anyone with the app. Use them only for public settings. Keep database credentials on the server. Git ignores local environment files, local JSON, and signing material. Check those rules from the repository root without printing file contents.

```bash
git check-ignore backend/.env config/development.local.json
```

## Validation

After setup, run `make check` from the repository root. To verify the public JSON-to-provider path specifically, run the following command. The full `make validate` workflow also runs this case.

```bash
flutter test --dart-define-from-file=config/development.example.json test/core/config/app_config_test.dart
```
