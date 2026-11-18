# Development configuration

[M1.6 / issue #7](https://github.com/devBuildersunique/ploggr/issues/7) establishes
configuration for Flutter, NestJS, and PostgreSQL/PostGIS. Start here when choosing
an API address or setting up a new development environment.

[Backend setup](../../backend/README.md#first-time-setup) ·
[Flutter setup](#flutter-setup) · [Device addresses](#device-addresses) ·
[Validation](#validation) · [Maintainer checklist](../../backend/docs/maintenance.md#m16-review-checklist)

## Which configuration do I need?

| Work | Configuration | Required services |
| --- | --- | --- |
| Run the existing Flutter offline preview | None; use `flutter run` | None |
| Configure Flutter's manual connection check | Ignored `config/development.local.json` | Backend and database for live checking |
| Run the backend against the development database | Ignored `backend/.env` or process variables | PostgreSQL/PostGIS via Docker Compose |
| Run backend unit/HTTP tests | Explicit test configuration supplied by the tests | None |
| Run database integration tests | Isolated configuration supplied by the runner | Docker access |

M1.6 established Flutter's API configuration. M1.7 adds a Dio client and a manual
**Settings → Connection check** that queries the backend and PostgreSQL/PostGIS.
See the [connection guide](connection-check.md) for laptop and Android USB setup.
Other screens continue using local preview data. No requests run automatically.

## Backend setup and precedence

Follow the [backend setup guide](../../backend/README.md#first-time-setup) and its
[complete variable reference](../../backend/README.md#configuration).
`DB_USER` and `DB_PASSWORD` are required by NestJS and database tools;
`POSTGRES_PASSWORD` is separately required by Compose for its administrator role.
The remaining server/database settings have documented local defaults.

The existing [backend example](../../backend/.env.example) remains the template:

- Source and compiled Node.js entrypoints resolve the same `backend/.env` file,
  independently of their current working directory.
- Existing process environment values win over that file. An explicit invalid
  process value causes validation failure; it does not fall back to a file value.
- If the process sets `NODE_ENV=test`, both NestJS and database CLI tools skip
  `.env`. Tests and the integration runner provide their own values.
- A missing file is allowed when required settings are supplied by the process.
- Compose reads `.env` from `backend/` under the documented commands and also
  gives process environment values precedence. Continue running npm/Compose
  commands from `backend/`; application file resolution does not change Compose's
  own working-directory rules.

If upgrading an existing M1.4/M1.5 checkout, preserve your `.env` and copy only
missing keys from the example. No variables are renamed in M1.6. Choose database
credentials before creating the volume: changing `.env` does not update existing
database roles. See [troubleshooting](../../backend/README.md#troubleshooting)
before resetting any data you need.

For a one-off backend override from `backend/`:

```bash
PORT=3001 npm run start:dev
```

`HOST` is the address NestJS listens on. `DB_HOST` is where NestJS finds PostgreSQL.
Neither is the address Flutter should blindly copy; use the table below for the
Flutter device's view of the development computer.

## Flutter setup

Run these commands from the repository root after installing Flutter dependencies:

```bash
flutter pub get
[ -f config/development.local.json ] || cp config/development.example.json config/development.local.json
```

Edit your local JSON for the intended device. The current example targets the
laptop or an Android phone using USB forwarding:

```json
{
  "API_BASE_URL": "http://127.0.0.1:3000/api/"
}
```

Launch with the file:

```bash
flutter run --dart-define-from-file=config/development.local.json
```

Use `-d linux` for the local desktop target if multiple devices are available.
The file is input to the Flutter compiler, not a runtime asset. Stop and rerun
the application after changing it; hot reload does not update build declarations.
Use the same `--dart-define-from-file` option for a configured Flutter build.
No additional package, asset declaration, or native build flavor is needed.

### API URL rules

`API_BASE_URL` is the only Flutter configuration key in this milestone:

- Omitted: `AppConfig.apiBaseUrl` is null and the offline preview still works.
- Supplied: require a nonempty absolute HTTP/HTTPS URL with a hostname and valid
  port, without credentials, query parameters, fragments, or whitespace.
- A missing trailing slash is added. Include the backend's `/api/` prefix in the
  configured address so the relative `health/ready` route resolves correctly.
- Invalid supplied values throw a `FormatException` before the widget tree is
  created. The message names `API_BASE_URL` without echoing the supplied value.

The immutable `AppConfig` is available through `appConfigProvider`. `main()`
validates and installs it at startup; tests can override the provider with
explicit values. A configured URL allows the manual check; it does not trigger
requests at startup.

## Device addresses

These examples use the default backend port 3000 and `/api/` prefix. Adjust both
the backend port and Flutter URL together when choosing another port.

| Flutter target | `API_BASE_URL` | Backend listening address |
| --- | --- | --- |
| Linux desktop on the development computer | `http://127.0.0.1:3000/api/` | Default `HOST=127.0.0.1` |
| Physical Android phone with `adb reverse tcp:3000 tcp:3000` | `http://127.0.0.1:3000/api/` | Default `HOST=127.0.0.1` |
| Android Emulator on that computer | `http://10.0.2.2:3000/api/` | Default `HOST=127.0.0.1` |
| Physical device on the same LAN | `http://<computer-LAN-IP>:3000/api/` | Set `HOST=0.0.0.0` and restart NestJS |

For a physical device, replace the placeholder with the computer's actual LAN
address and ensure the local network/firewall permits the backend port. `0.0.0.0`
is a listening address, not a destination URL. A device's `127.0.0.1` points at
that device, unless USB forwarding maps the API port. M1.7 adds Android debug
HTTP policy and validates laptop/USB-phone connectivity. The emulator and LAN
rows are alternative addresses, not a claim those network paths were tested.

## Public configuration and secrets

- Commit public templates: `config/development.example.json` and
  `backend/.env.example` contain examples only.
- Keep local values out of Git: `config/*.local.json`, `.env`, and `.env.*` are
  ignored, with `.env.example` explicitly allowed.
- Flutter build declarations can be inspected in the distributed application.
  Put only public settings such as the API URL there, even if the local file is
  ignored. Never put database passwords, signing keys, or server secrets in it.
- Backend credentials belong in the ignored backend `.env` or the process
  environment. Do not publish `.env` files or dump configuration into logs/PRs.

Confirm the local files are ignored without printing their contents:

```bash
git check-ignore backend/.env config/development.local.json
```

## Validation

From the repository root:

```bash
flutter analyze
flutter test
flutter test --dart-define-from-file=config/development.example.json test/core/config/app_config_test.dart
```

The normal suite checks the configuration-free preview; the second configuration
test run checks the JSON-to-compiler-to-provider path using the public example.
Both work without a backend or database. URL parsing tests also cover invalid
values, port limits, credential exclusion, and relative API path resolution.

From `backend/`, with dependencies installed and Docker available:

```bash
npm run build && npm run lint && npx tsc --noEmit && npm test && npm run test:database
```

See the [M1.6 review checklist](../../backend/docs/maintenance.md#m16-review-checklist)
for the evidence expected before merging. These checks validate configuration and
preserve the M1.5 database foundation. For M1.7's live Flutter-to-backend test,
use the [connection guide](connection-check.md#automated-checks).
