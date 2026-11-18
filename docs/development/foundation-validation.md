# M1.8 foundation validation

Run `make validate` from the repository root to exercise the isolated stack. To start the app interactively, follow the root quickstart. [Project quickstart](../../README.md#run-the-complete-foundation) · [M1.8 acceptance criteria](https://github.com/devBuildersunique/ploggr/issues/9)

**Ready for local M2 development on Linux and Android.** The implementation at `0253ccc73c69`, based on M1.7 `e6abeeb`, passed the full runner from a fresh clone and the developer quickstart from a second fresh clone. Both began without local project dependencies, build outputs, environment files, or a pre-initialized database. They used the host's installed SDKs and package caches.

## Validation evidence

Validated on 18 November 2026 with Linux x86-64, Flutter 3.50.0, Dart 3.14.0, npm 11.20.0, Docker Engine 29.9.2, and Compose 5.6.1. The automated run used Node 24.22.3 and Xvfb with software GL. The separate developer setup used Node 26.13.1, a graphical Linux session, and an Android 17 x86-64 emulator (API 37).

| Acceptance check | Observed result |
| --- | --- |
| Locked setup and builds | `flutter pub get --enforce-lockfile` and `npm ci` succeeded. Dart formatting reported zero changes, Flutter analysis reported no issues, and backend lint, type-checking and Nest compilation passed. Linux debug builds and Android debug APK assembly, installation, and regular startup succeeded. |
| Navigation and Riverpod | All 180 unit/widget tests passed, including route rendering, preview-state transitions, cancellation, and retry. The 24 configuration cases also passed with the committed Dart define file. The native tests entered via `main()`, followed onboarding and the preview path, and opened Profile → Settings → Connection check. |
| Database and API | All 45 backend unit/HTTP tests and six real database tests passed. A new volume initialized PostgreSQL 18.7 and PostGIS 3.7.0. The app role executed an SRID 4326 query. The initial migration ran once, rerunning reported zero pending, and migration history survived container recreation. Tests covered restricted role privileges, invalid credentials, unavailable-database startup and pool shutdown. |
| Live UI and configuration | The Linux and Android native tests displayed **Connected** against the real Nest watch server. The second clone used its own Compose project, DB port 55432 and API port 33008. Linux loaded the copied JSON define file. The emulator reached the host through `10.0.2.2`. An unconfigured Linux app opened the preview and displayed **No server configured** with a disabled button. |
| Outages and recovery | With one Linux app open, stopping PostgreSQL left liveness at HTTP 200, readiness at HTTP 503 with the sanitized error envelope, and the screen at **Database unavailable**. Restarting PostgreSQL and pressing **Check again** produced **Connected**. Stopping Nest produced **Server unavailable**. Restarting it and pressing **Check again** restored **Connected**. |
| Rerun and cleanup | The graphical and fresh-clone headless runs both ended with `Foundation validation passed.` Both clones retained a clean Git status. A deliberate SIGTERM during disposable database startup exited nonzero and removed its container, network, and volume. Normal quickstart shutdown retained its volume. The separate development database remained healthy throughout. |

The GitHub Actions workflow passed actionlint 1.7.12. Its Linux validation command was exercised locally under Xvfb. A hosted Actions result requires a pull request or workflow dispatch. The live M1.8 platform evidence covers Linux and the Android emulator. Earlier physical Android evidence is in the [M1.7 record](../../backend/docs/maintenance.md#m17-recorded-validation).

### Developer workflow follow-up

On 18 November 2026, two fresh checkouts of `b4daa69` verified the root commands under Node 24.22.3 on Linux. One ran `make validate` through both outages and recoveries. The other ran `make setup` twice, compared both customized configuration files byte for byte, and started the documented stack with `make api` and `make app`. Native UI checks displayed **Connected** on Linux and the Android 17 emulator (API 37). The emulator also built, installed and launched the ordinary debug APK through `make app DEVICE=emulator-5582`. After shutdown, `make down` retained its named volume.

Before the follow-up, a shell exporting invalid `PORT` and `DB_PORT` values caused all 13 HTTP tests to fail before startup. Giving ordinary Jest tests explicit server and database settings fixed the failure. With the same conflicting values exported, `make check` passed all 180 Flutter tests and all 45 backend tests. Real database tests continued using their separate Compose environment.

## Engineering audit

| Area | Findings and disposition |
| --- | --- |
| Repository and assets | Reviewed the M1.7 inventory of 261 tracked files across the app, backend, six platform runners, tools, tests, assets, and documentation. Removed the superseded orange logo, unused popup wrappers, unused Cupertino icon package, ten redundant directory markers, and obsolete ignore rules for Dart source files. Kept the four in-use images, font and license, design references, and intentional empty architecture directories. |
| Code and architecture | The production app already has a Riverpod scope, feature controllers, a shared Dio provider, and central go_router routes. Nest and its CLI already share TypeORM options. Consolidated duplicate backend port validation. M2 can add a Nest module, explicit migrations, and a Flutter feature using these extension points. |
| Configuration and isolation | Flutter receives only a public API URL. Nest and its CLI read the backend environment, with process variables taking precedence. The ordinary test suite supplies its own configuration. Compose publishes PostgreSQL on loopback, provisions PostGIS as administrator, and connects the API using a non-superuser application role. Android permits development HTTP in the debug manifest, including the emulator and USB/LAN development paths. |
| Developer commands and maintenance | The profile menu, registered routes and detail screens now use the same typed destinations. The root Makefile delegates to Flutter, npm and the existing validation runner. The contributor guide identifies the owning code, tests and documentation for each layer. |
| Tooling and tests | Declared the Flutter floor from the resolved package set and aligned Node engines with the locked build dependencies. Preserved the Dart source language level to avoid unrelated reformatting. The native test now launches the production entry point and navigates to Settings. The isolated runner verifies that the same Flutter session can retry after both kinds of outage. |
| Developer documentation | Replaced the Flutter-only entry instructions with a full-stack quickstart, offline path, architecture map, migration references, verification commands, and contribution guidance. The earlier milestone and design records retain their historical scope. Running the optional visual-capture driver refreshes tracked reference screenshots. |

## Security findings on 18 November 2026

- **npm.** The locked full tree reported 49 high and three moderate package entries across three underlying advisories. The production-only tree reported three moderate entries on `typeorm@0.3.31 → glob@10.5.0 → minimatch@9.0.9`. Entity and migration registrations use explicit classes, and the health API accepts no glob patterns. The high findings come through development tools including Jest, ESLint, and the Nest CLI. The picomatch advisory lists no patch. A non-forced audit-fix dry run proposed zero package changes. Recheck when compatible upstream dependencies are released and before adding any user-controlled file-pattern functionality. [glob advisory](https://github.com/advisories/GHSA-3g3m-2fjr-6pw4) · [minimatch advisory](https://github.com/advisories/GHSA-g3hv-75wg-m249) · [picomatch advisory](https://github.com/advisories/GHSA-fc5q-39xc-vjpf)
- **Flutter and Android.** Dart Pub reported zero advisory-affected, retracted or discontinued entries among 54 packages after cleanup. OSV flagged the project's Kotlin Gradle plugin 2.3.20. Updated it to the patched stable 2.4.21 and added the published SHA-256 for the Gradle distribution. OSV returned no entries for the new plugin version or the declared Android Gradle Plugin 9.1.1. The separate Flutter SDK build tooling still declares a Kotlin 2.4.10 dependency. Use trusted local build caches and recheck the SDK tooling when upgrading Flutter. The Android build warns of future support changes for Gradle 9.3.1 and AGP 9.1.1. [Kotlin advisory](https://github.com/advisories/GHSA-r937-wjx7-w2jp) · [Gradle checksum](https://services.gradle.org/distributions/gradle-9.3.1-all.zip.sha256)
- **Database image.** Grype 0.122.0, using its 17 November database, scanned the official amd64 `postgis/postgis:18-3.7` image at manifest digest `sha256:fe440a27c6567aefa932e988962e5827bb2c29e4b97dac2ca5268f5eafe10262` (Debian 13.7). It reported 29 critical package matches across 15 IDs, 224 high, 190 medium, 59 low, 311 negligible, and 25 unknown. Critical matches span curl, MariaDB client libraries, GDAL, TIFF and XML. The feed listed 25 critical matches as “won’t fix” and four as “not fixed.” One medium match listed an upstream fix in the `gosu` binary’s embedded Go dependency `github.com/moby/sys/user`. The scanned digest was the current published image for this tag. Keep it scoped to local development. Rescan a refreshed compatible image and review deployment exposure before hosting or processing untrusted spatial data. [Published image](https://hub.docker.com/r/postgis/postgis) · [Grype](https://github.com/anchore/grype)
- **Secrets and workflow.** The tracked configuration files contain public settings and local examples. A tracked-file inventory and private-key/token-pattern check found no matching credentials. Local env files, signing material, and build products are ignored. The pull-request workflow uses read-only repository permissions and pins its actions by commit.

To refresh the dependency evidence, run the following from the repository root. npm exits nonzero when it reports advisories. Compare image results using the digest and scanner database date.

```bash
dart pub outdated --show-all --json
(cd backend && npm audit)
(cd backend && npm audit --omit=dev)
docker image inspect postgis/postgis:18-3.7 --format '{{json .RepoDigests}}'
grype docker:postgis/postgis:18-3.7
```

## Handoff to M2

The first identity module can use the existing Nest module, DTO validation, error envelope, explicit TypeORM migrations, and Flutter provider structure. The M1 database contains migration metadata and extension-owned objects. When adding the first identity migration, update the expected migration count and table inventory in `backend/test/database.integration-spec.ts` alongside that schema change. The agreed authentication direction is custom NestJS authentication with JWT. [M1 technical decision](https://github.com/devBuildersunique/ploggr/issues/2#issuecomment-5240945427)

Hosting needs a separate security review, particularly for the database image, credentials, TLS, and Android release signing. Platform runners for iOS, macOS, Windows and web remain in the repository. For a future live macOS or web client, review sandbox outbound networking or browser origin policy and verify on the target before advertising support.
