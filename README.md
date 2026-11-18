# Ploggr

Ploggr is a Flutter app for people who pick up litter while walking or jogging. The 18-screen preview lets you try a session, report sample litter, join a cleanup, and explore community and profile screens. Preview activity stays in memory until the app restarts. The live M1 integration is **Profile → Settings → Connection check**, which asks a NestJS server to verify PostgreSQL and PostGIS.

## Get a checkout

For ordinary development, clone the upstream repository. While the foundation changes are under review, check out the milestone branch from the repository that contains it. A plain clone of upstream `main` only includes milestones already merged.

```bash
git clone https://github.com/devBuildersunique/ploggr.git
cd ploggr
```

For M1.8 review, use the following clone command. Set `M18_SOURCE` to the local checkout path or fork URL containing the branch. M1.8 builds on `feature/m1.7-stack-communication` at `e6abeeb`.

```bash
git clone --branch feature/m1.8-foundation-validation "$M18_SOURCE" ploggr-m18
cd ploggr-m18
```

## Run the complete foundation

Use a Linux x86-64 machine with Git, curl, Flutter 3.50.0 (Dart 3.14), Node 24.15 or later in the 24.x line, npm, and Docker Engine with Compose supporting `up --wait` and `start --wait`. The published PostGIS image targets amd64. For the Linux app, install clang, CMake, Ninja, pkg-config and GTK 3 development headers and use a graphical session. For Android, install the Android SDK, configure an emulator or USB device, and check `flutter doctor -v`. [Flutter Linux setup](https://docs.flutter.dev/platform-integration/linux/setup)

**Terminal 1 — database and API.** Start in the repository root. If you use nvm, run `nvm install` and `nvm use` inside `backend/` to select its version. Set your local database passwords in the copied file before the first startup. Nest uses the application role. Compose uses the separate administrator password to initialize the volume.

```bash
cd backend
npm ci
[ -f .env ] || cp .env.example .env
docker info --format '{{.ServerVersion}}'
npm run db:up && npm run migration:run && npm run db:check
npm run start:dev
```

The database check prints PostgreSQL and PostGIS versions and the coordinates `[78.4867, 17.385]`. Keep this terminal running once Nest prints `API listening at http://127.0.0.1:3000/api`.

**Terminal 2 — Flutter.** Start in the repository root.

```bash
curl --fail-with-body http://127.0.0.1:3000/api/health
curl --fail-with-body http://127.0.0.1:3000/api/health/ready
flutter pub get --enforce-lockfile
[ -f config/development.local.json ] || cp config/development.example.json config/development.local.json
flutter run -d linux --dart-define-from-file=config/development.local.json
```

The first request returns `{"status":"ok"}`. The second returns `{"status":"ok","database":"up","postgis":"up"}` after a spatial SQL query. In Flutter, choose **Skip → Explore the preview → Profile → Settings → Connection check → Check connection**. **Connected** confirms the full path. **Check again** runs a fresh query.

- **Android emulator.** Use `flutter devices` to find its ID. Run `flutter run -d <emulator-id> --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/`. For a USB device, use adb reverse and the same loopback configuration as Linux. [Device and recovery guide](docs/development/connection-check.md)
- **Offline preview.** Run `flutter pub get --enforce-lockfile`, then `flutter run` without defines. This needs only Flutter and a supported device. The connection screen shows **No server configured**.
- **Configuration.** The API and database bind to loopback by default. Process variables override `backend/.env`. Flutter reads the public `API_BASE_URL` at build time. If ports are occupied, change `DB_PORT` or `PORT` before startup and match the API port in the Flutter JSON. When running two checkouts at once, also choose a distinct `COMPOSE_PROJECT_NAME` in each new backend environment file so each database gets its own volume. Keep credentials in the ignored backend configuration. [Configuration reference](docs/development/configuration.md)
- **Shutdown.** Quit Flutter with `q`, stop Nest with Ctrl+C, and run `npm run db:down` from `backend/`. The named volume retains your data. [Database operations and troubleshooting](backend/README.md)

## How the project fits together

```text
Flutter screen → Riverpod controller → Dio → GET /api/health/ready
                                                  ↓
                                         NestJS health service
                                                  ↓
                                      TypeORM → PostgreSQL 18 + PostGIS 3.7
```

| Area | Where to work |
| --- | --- |
| Flutter entry and navigation | `lib/main.dart` validates configuration and creates the Riverpod scope. `lib/app.dart` mounts the router. Add paths and screens in `lib/routes/`. |
| Screens, state and networking | Keep screens, controllers, and services with their feature in `lib/features/`. The connection feature shows the full HTTP path. Shared configuration, networking, preview data and theme live in `lib/core/`, reusable widgets in `lib/shared/widgets/`. |
| Backend | Register feature modules from `backend/src/modules/` in `AppModule`. Controllers expose routes under `/api`. Services own application logic. Common bootstrap, validation and exception handling also apply in HTTP tests. |
| Database | Compose provisions the database and application role. TypeORM options are shared by Nest and the CLI. Create and register explicit migrations in `backend/src/database/`. Schema synchronization is disabled. [Migration guide](backend/docs/maintenance.md#migrations) |
| Tests and assets | Flutter unit/widget tests are in `test/`, device checks in `integration_test/`, backend tests beside their modules and in `backend/test/`. Bundled artwork and the font live in `assets/`. [Design notes](docs/design/implementation.md) · [Asset provenance](docs/design/assets.md) |

Authentication, identity persistence, and access tokens belong to M2. The agreed direction is custom authentication in NestJS with JWT. The current login and signup screens accept preview input. [Foundation decisions](https://github.com/devBuildersunique/ploggr/issues/2#issuecomment-5240945427)

## Test and verify

From the root of a fresh checkout, with Docker access and a Linux graphical session, run the same command as pull-request CI. On a headless Linux machine use `xvfb-run -a node tool/validate_foundation.mjs` with Xvfb and xauth installed.

```bash
node tool/validate_foundation.mjs
```

It installs locked dependencies, runs static checks and tests, builds the app and API, and starts a disposable database and backend on separate ports. The Linux app checks a healthy stack, retries through database and backend outages, and recovers in the same session. Expect `Foundation validation passed.` The runner rebuilds local dependency and build directories. Use a separate checkout if you have an active build or watch server.

| Faster check | Command |
| --- | --- |
| Flutter analysis and unit/widget tests, root | `flutter analyze && flutter test` |
| Backend lint, types, build and unit/HTTP tests, inside `backend/` | `npm run lint && npm exec -- tsc --noEmit && npm run build && npm test` |
| PostgreSQL, migrations and PostGIS only, inside `backend/` | `npm run test:database` |
| Native UI against an already running stack, root | `flutter test integration_test/connection_check_test.dart -d linux --dart-define-from-file=config/development.local.json` |
| Android debug APK, root | `flutter build apk --debug` |

The M1.8 report records the tested platforms, dependency findings, recovery evidence, and M2 handoff. [Foundation validation report](docs/development/foundation-validation.md)

## Contribute

Fork the project, branch from an up-to-date upstream `main`, and open your pull request against `devBuildersunique/ploggr:main`. For a stacked milestone, branch from its stated predecessor and identify the base commit in the description so reviewers can inspect the incremental diff. Link the issue, describe observable changes, include the commands and results you verified, and update the setup or architecture docs when behavior changes.
