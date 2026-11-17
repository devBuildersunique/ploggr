# Backend maintainer guide

Use this guide to review M1.5/M1.6 or extend the backend. New contributors should
start with [setup and verification](../README.md).

[M1.5 review checklist](#m15-review-checklist) · [M1.6 review checklist](#m16-review-checklist) ·
[Architecture](#architecture) ·
[Migrations](#migrations) · [Structure](#structure) ·
[API conventions](#request-and-response-conventions)

## M1.5 review checklist

[M1.5 / issue #6](https://github.com/devBuildersunique/ploggr/issues/6) establishes
database infrastructure. Authentication, User/Plog/Challenge/Hotspot tables,
Flutter integration, and production deployment are future work.

Check out the proposed branch. From the repository root:

```bash
cd backend
npm ci
npm run build && npm run lint && npx tsc --noEmit && npm test && npm run test:database
```

Docker must be accessible in that shell. No development `.env`, running backend,
or development database is needed for the automated tests. The integration
runner rebuilds `dist/`, so stop servers using compiled output first.

| Requirement | Review | Verification |
| --- | --- | --- |
| Reproducible development database | [Compose service](../compose.yaml), named volume, loopback-only port | Fresh isolated Compose startup; container recreation preserves migration history |
| Backend connects to PostgreSQL | [Shared options](../src/database/database.config.ts), [Nest module](../src/database/database.module.ts) | Real Nest startup, HTTP health response, pool shutdown, unavailable-database startup failure |
| PostGIS is enabled and usable | Image initialization precedes [role setup](../docker/init/20-app-role.sh) | Version query and SRID 4326 spatial operation succeed |
| Configuration is reproducible | [.env.example](../.env.example), [validation](../src/config/environment.ts) | Unit tests cover credentials, ports, defaults, and environment precedence |
| Migrations are established | [Foundation migration](../src/database/migrations/1794873600000-VerifyPostgis.ts) and standalone CLI | Initial run, repeated run, revert/reapply, and compiled migration commands |
| No premature domain schema | Empty entity list; only migration metadata is application-owned | Integration test excludes extension-owned tables and expects only `migrations` in `public` |

The six database tests are in
[database.integration-spec.ts](../test/database.integration-spec.ts). The
[integration runner](../test/run-database-integration.mjs) additionally verifies
compiled commands, persistence, failure exits, and cleanup using an isolated
Compose project, random host port, fixed test credentials, and disposable volume.
It does not run migrations against the development database.

For a manual review of the development instance, follow the
[setup](../README.md#first-time-setup), [HTTP/database checks](../README.md#verification),
and [SQL inspection](../README.md#inspect-the-database). `GET /api/health` is a
process check and does not query PostgreSQL on each request; use `db:check` for
live dependency verification. The application establishes its database connection
before it starts listening.

### Recorded validation

On November 17, 2026, the local validation passed:

- Build, lint, TypeScript checking, and all 35 unit/HTTP tests.
- All six PostgreSQL/PostGIS integration tests.
- Source database check and compiled migration/check commands.
- Migration history surviving container recreation.
- Backend exit status 1 with wrong credentials or an unavailable database.
- Removal of the test project's containers and volume after the suite.

The recorded environment was Linux/x86-64, Node.js 26.13.1, npm 11.20.0, Docker
29.9.2, PostgreSQL 18.7, and PostGIS 3.7.0. Node.js 24 is the development target
in `.nvmrc`; this recorded run did not separately validate Node.js 24. Test counts
and patch versions may change; a new review must rerun the commands above.

## M1.6 review checklist

[M1.6 / issue #7](https://github.com/devBuildersunique/ploggr/issues/7) provides
development configuration on top of M1.5. The
[configuration guide](../../docs/development/configuration.md) documents its
workflow and expected behavior. Flutter still uses offline preview data; network
integration belongs to M1.7.

| Requirement | Review | Verification |
| --- | --- | --- |
| Flutter API URL comes from configuration | [AppConfig](../../lib/core/config/app_config.dart), [provider](../../lib/core/config/app_config_provider.dart), [bootstrap](../../lib/main.dart) | Invalid URLs fail validation; no declaration preserves the preview; provider overrides work |
| Public example and local configuration | [JSON example](../../config/development.example.json) and root ignore rules | Define-file configuration tests pass; local JSON is ignored |
| Backend file policy is consistent | [Shared policy](../src/config/environment-file.ts), Nest module and standalone data source | Absolute backend file path, process precedence, test isolation, source/compiled path checks |
| Secrets remain server-side | Backend example and ignored local files; Flutter example contains only an API URL | No credential values are emitted by validation errors; no local config is staged |
| M1.5 remains functional | Existing database module and migrations | Build/lint/type checking, unit/HTTP tests, and isolated PostgreSQL/PostGIS integration suite pass |

From the repository root, run Flutter checks (no server is needed):

```bash
flutter analyze
flutter test
flutter test --dart-define-from-file=config/development.example.json test/core/config/app_config_test.dart
```

Run the backend command chain under the M1.5 checklist above. The test suites
include [file-policy parity tests](../src/config/environment-file.spec.ts),
[database configuration tests](../src/database/database.config.spec.ts), and
[Flutter configuration tests](../../test/core/config/app_config_test.dart).

The M1.6 branch starts at M1.5 commit `62c5d3a` while upstream PR #61 is pending.
Review its incremental diff against that base. After M1.5 merges, rebase only
the M1.6 commits onto upstream `main` before opening the M1.6 PR; keep M1.5's
existing commits and review separate from new M1.6 work.

### M1.6 recorded validation

On November 18, 2026, local validation passed Flutter analysis and all 148 Flutter
tests, plus all 24 configuration tests with the committed JSON define file.
Backend build, lint, type checking, all 40 unit/HTTP tests, and all six database
integration tests passed. Source and compiled configuration resolved the same
backend `.env` from the repository root, `backend/`, and an unrelated temporary
working directory. Documentation links/anchors, command syntax, example visibility,
and local-file ignore rules were also checked. The isolated test containers and
volume were removed successfully.

This run used Flutter 3.50.0 / Dart 3.14.0 and the Node.js/Docker versions listed
in the M1.5 record above. It verifies configuration and backend/database behavior;
mobile HTTP connectivity remains for M1.7.

## Architecture

`AppModule` loads validated configuration, the database infrastructure, and the
health module. `DatabaseModule` uses `TypeOrmModule.forRootAsync` to expose an
injectable TypeORM `DataSource` globally. The standalone CLI creates a data source
from the same options without starting NestJS.

- NestJS runs on the host. Compose runs only the PostgreSQL/PostGIS database.
- Both entrypoints validate `DB_*` values; process environment variables take
  precedence over `.env`. Both resolve the same backend file independently of
  working directory and skip it when the process environment has `NODE_ENV=test`.
  NestJS additionally validates its server settings.
- Schema synchronization, automatic migrations, and automatic extension
  installation are disabled. The entity list is empty for M1.5.
- Startup makes three connection attempts, with one-second retry delays and a
  five-second connection timeout. Queries/statements also have five-second
  timeouts. Future long migrations must account for those limits explicitly.
- Shutdown hooks close the connection pool. The check CLI also closes its pool
  on completion and exits nonzero on failure without printing credentials.

### Provisioning and permissions

The image tag `postgis/postgis:18-3.7` selects PostgreSQL 18 and PostGIS 3.7; its
upstream patch contents may change. The PostgreSQL 18 volume is mounted at
`/var/lib/postgresql`. Major database upgrades require a deliberate migration;
changing the image tag is not a volume upgrade procedure.

The image's initialization script installs PostGIS in the configured database.
`20-app-role.sh` then creates the application role and grants schema usage/create
privileges. NestJS and migrations use that role, which cannot create databases,
create roles, or act as a superuser. `POSTGRES_PASSWORD` is used only for
administrator provisioning. SQL inspection in the setup guide uses a separate
administrator session inside the container.

Provisioning scripts run only for an empty volume. Changing `.env` credentials
or database names does not alter existing roles/databases. Preserve required data;
use intentional administrator SQL changes or reset disposable development data
as described in [troubleshooting](../README.md#troubleshooting).

## Migrations

Run migrations explicitly before starting the backend. From `backend/`, inspect
and apply pending migrations:

```bash
npm run migration:show
npm run migration:run
npm run migration:show
```

The foundation migration calls `PostGIS_Full_Version()` to assert that privileged
provisioning has already installed PostGIS. Success is recorded in `migrations`.
Extension-owned tables and schemas are expected; no domain tables are created.

### Roll back intentionally

To revert the most recently applied migration, run this separately:

```bash
npm run migration:revert
```

Review that migration's `down()` implementation first. The M1.5 migration removes
only its history entry on rollback and deliberately retains PostGIS. Future
migrations may change or delete application data. To reapply a reverted migration,
run `npm run migration:run`.

### Add a future schema change

Choose one approach; these are alternatives, not consecutive setup steps.

For an empty migration to edit by hand:

```bash
npm run migration:create -- src/database/migrations/DescribeChange
```

For a generated migration, first add the intended entities to the shared
`entities` list in `src/database/database.config.ts`, then compare them against
a development database with all existing migrations applied:

```bash
npm run migration:generate -- src/database/migrations/DescribeChange
```

No generation is needed for M1.5's empty entity list. Review the SQL and both
`up()`/`down()` methods. Import the new migration class into the shared `migrations`
list so NestJS, source CLI tools, and compiled execution use the same definitions.
Keep existing applied migrations unchanged; create a new migration for subsequent
schema changes. Test new migrations against a disposable database.

### Run compiled migrations

After `npm run build`, the following commands load JavaScript from `dist/`:

| Command | Purpose |
| --- | --- |
| `npm run migration:show:prod` | List applied and pending migrations |
| `npm run migration:run:prod` | Apply pending migrations |
| `npm run migration:revert:prod` | Intentionally revert the most recent migration |
| `npm run db:check:prod` | Check PostgreSQL connectivity and PostGIS |

The `:prod` suffix selects compiled execution; it does not change environment
variables, enable TLS, or configure a production deployment.

## Structure

```text
src/
├── main.ts                 # Bootstrap, configured listen address, shutdown hooks
├── app.module.ts           # Root module and shared providers
├── app.setup.ts            # Global prefix and request validation
├── config/                 # Environment validation and defaults
├── database/               # Shared options, Nest module, CLI checks, migrations
├── common/filters/         # Shared HTTP error handling
└── modules/health/         # Health module and controller
test/
├── health.e2e-spec.ts             # Health and shared HTTP policy tests
├── database.integration-spec.ts   # Real PostgreSQL/PostGIS integration tests
├── run-database-integration.mjs   # Isolated Compose test lifecycle
└── setup-env.cjs                  # Configuration for database-free tests
```

Add future features under `src/modules/<feature>/` and import their module in
`AppModule`. Keep controllers, DTOs, and any required services with their feature;
put reusable infrastructure in `common/`. Health is static and needs no service.
The server and HTTP tests use the same `configureApp` function.

## Request and response conventions

- Routes start with `/api`; feature controllers declare only their relative path.
- Requests with bodies use `Content-Type: application/json` and camelCase fields.
- Define validated input using DTO **classes** and `class-validator` decorators.
  The global pipe transforms inputs to DTO instances and rejects undeclared fields
  and invalid values with HTTP `400`. Primitive coercion is not enabled implicitly;
  use explicit parsing pipes or DTO transforms when needed.
- Success responses are JSON objects returned directly by controllers, without a
  global envelope. Use HTTP `200` for reads, `201` for creates, and `204` for actions
  with no response body. Each future endpoint should document its payload.
- Errors use the envelope below. `message` is a string for ordinary errors or an
  array of strings for DTO validation failures. Timestamps are UTC ISO 8601;
  `path` excludes the query string. Handle status codes rather than parsing messages.
- Throw Nest HTTP exceptions for expected client errors. Server failures are logged
  and return a generic message without stack traces or implementation details.

```json
{
  "statusCode": 404,
  "error": "Not Found",
  "message": "Cannot GET /api/missing",
  "path": "/api/missing",
  "timestamp": "2026-11-17T00:00:00.000Z"
}
```

These foundations use Nest's [configuration](https://docs.nestjs.com/techniques/configuration),
[validation](https://docs.nestjs.com/techniques/validation), and
[exception filter](https://docs.nestjs.com/exception-filters) mechanisms.
Authentication, Plog endpoints, and Flutter API integration
are outside this milestone.
