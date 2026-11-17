# Ploggr backend

NestJS TypeScript API foundation with PostgreSQL/PostGIS infrastructure for
[M1.5 / issue #6](https://github.com/devBuildersunique/ploggr/issues/6).
Run NestJS on the host and the database in Docker Compose, independently of Flutter.
No domain entities or business tables are introduced by this milestone.

## Development

Use Node.js 24 (see `.nvmrc`), npm, and Docker Engine with Docker Compose.
The development database image targets Linux/x86-64. Your shell must have access
to the Docker daemon (`docker info` should succeed). Run from the repository root:

```bash
cd backend
nvm use                 # Optional, if you use nvm
npm ci
[ -f .env ] || cp .env.example .env
```

Review `.env` before the first database startup. The command above preserves any
existing configuration. Start the database, apply migrations, and verify PostGIS:

```bash
npm run db:up && npm run migration:run && npm run db:check
```

The `&&` chain stops if any step fails. `db:up` waits for the database to become
healthy; the first run also downloads the image. `db:check` should print
`"connectivity": true`, PostgreSQL/PostGIS version strings, and a point with
coordinates `[78.4867, 17.385]`. Once those steps succeed, start the backend:

```bash
npm run start:dev
```

The development server watches TypeScript files and restarts on changes.
`Found 0 errors` means compilation succeeded. With the default configuration,
`API listening at http://127.0.0.1:3000/api` means the server is ready.
Keep this terminal running and use another terminal for the checks below.
Stop the backend with Ctrl+C; this does not stop the Docker database.

For a compiled run against the same database:

```bash
npm run build
npm run migration:run:prod
npm run db:check:prod
npm run start:prod
```

## Configuration

Configuration is loaded from `backend/.env` when commands run from `backend/`.
Existing process environment variables take precedence. `.env` files are ignored;
the committed `.env.example` contains only non-secret defaults.

| Variable | Default | Meaning |
| --- | --- | --- |
| `NODE_ENV` | `development` | `development`, `test`, or `production` |
| `HOST` | `127.0.0.1` | Listening hostname or IP; use `0.0.0.0` for containers |
| `PORT` | `3000` | Integer from 1 to 65535 |
| `DB_HOST` | `127.0.0.1` | Database hostname used by host-run NestJS and CLI tools |
| `DB_PORT` | `5432` | Host database port; also used by Compose to publish port 5432 |
| `DB_NAME` | `ploggr` | Development database created on first initialization |
| `DB_USER` | Required | Application role created on first initialization |
| `DB_PASSWORD` | Required | Application password, used verbatim |
| `POSTGRES_PASSWORD` | Required by Compose | Administrator password; never used by NestJS |

`.env.example` credentials are **development examples only**. Set your own values
in `.env`; never commit actual credentials. `DB_USER` must differ from the
administrator role `postgres`. Standard identifier names such as `ploggr` are
recommended. Compose, NestJS, and database CLI tools all give process environment
variables precedence over `.env`. Run commands from `backend/` so they use the
same file. Database CLI tools validate only `DB_*`; NestJS also validates server
configuration. Local connections use no TLS; hosted/production configuration is
outside this milestone.

Invalid configuration fails startup. The `/api` prefix is fixed centrally in
`src/app.setup.ts`, so all feature controllers share it.

## Verification

From `backend/`:

```bash
npm run build
npm run lint
npm test
npm run test:e2e        # HTTP tests only; also included in npm test
```

With the server running in a separate terminal:

```bash
curl --fail-with-body -i http://127.0.0.1:3000/api/health
```

Expected: HTTP `200`, JSON content type, and `{"status":"ok"}`.
Adjust the host/port if overridden. This endpoint checks that the API process
can serve requests; it does not check external dependencies. You can also open
`http://127.0.0.1:3000/api/health` in a browser. The `/api` prefix by itself is not
a page; use `/api/health`.

To verify the running development database separately:

```bash
npm run db:check
docker compose ps
```

Ordinary unit and HTTP tests need no database and do not read `.env`. HTTP tests
replace the database module explicitly. To exercise the real infrastructure:

```bash
npm run test:database
```

This command starts a separate randomly named Compose project, uses its own
test credentials, random host port, and disposable volume, and cleans it up on
completion. It checks spatial queries, permissions, migration run/re-run/revert,
Nest startup/shutdown, compiled CLI commands, persistence across container
recreation, and startup failures for invalid credentials/unavailable PostgreSQL.
It does not touch the development database. If interrupted before cleanup,
use the printed `ploggr-test-...` project name with
`docker compose --env-file .env.example -p <test-project> down --volumes`.

M1.5 validation on November 17, 2026 passed all 35 unit/HTTP tests and all six
database integration tests, along with build, lint, and TypeScript checking.
The integration runner also verified compiled migration/check commands,
persistence after container recreation, startup failure handling, and test
container/volume cleanup.

## Inspect the database

From `backend/`, open an administrator SQL session inside the development
container. This uses the configured database name, without installing psql on
the host or putting passwords in command arguments:

```bash
docker compose exec database bash -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
```

At the psql prompt:

```sql
SELECT version();
SELECT PostGIS_Full_Version();
SELECT * FROM migrations;
\dt
\q
```

`migrations` contains the recorded foundation migration. PostGIS-owned tables,
such as `spatial_ref_sys`, are expected. There are no User, Plog, Challenge, or
Hotspot tables. `\q` closes psql; the backend and database keep running.

## Database lifecycle and migrations

The pinned `postgis/postgis:18-3.7` image initializes PostGIS in the application
database. Its initialization runs before `docker/init/20-app-role.sh`, which
creates an application role with schema usage/create privileges and no superuser,
role creation, or database creation privileges. Only this role is used by NestJS
and migrations. PostGIS extension installation requires administrator privileges
and belongs to provisioning, not application startup.

The first migration calls `PostGIS_Full_Version()` and records success. It fails
if PostGIS was not provisioned. Reverting it removes the migration record but
does not drop shared PostGIS infrastructure. Apart from extension-owned tables
and schemas, only the `migrations` metadata table is created.

NestJS and the standalone TypeORM data source share connection options and
validation. Schema synchronization, automatic migrations, and automatic extension
installation are disabled. The backend attempts connection three times with
one-second retry delays and a five-second connection timeout, then exits if
unavailable. Shutdown hooks close its connection pool. `db:check` runs `SELECT 1`,
reports PostgreSQL/PostGIS versions, and round-trips an SRID 4326 point through
PostGIS. It exits nonzero on failure without printing credentials.

Run migrations explicitly before starting the backend. From `backend/`:

```bash
npm run migration:show
npm run migration:run
npm run migration:revert
# Future schema work: create an empty migration or generate one after adding entities.
npm run migration:create -- src/database/migrations/DescribeChange
npm run migration:generate -- src/database/migrations/DescribeChange
```

Register future entities and migrations in `src/database/database.config.ts`
so NestJS, the CLI, and compiled runs use the same definitions. An empty entity
list is intentional for M1.5; no generation is needed yet. After `npm run build`,
the `migration:show:prod`, `migration:run:prod`, `migration:revert:prod`, and
`db:check:prod` commands load compiled JavaScript without ts-node. The `:prod`
suffix means compiled execution; it does not change environment variables or
make the local development credentials suitable for deployment.

```bash
npm run db:logs              # Follow database logs
npm run db:down              # Stop/remove container; preserve data
npm run db:up                # Start again and wait for readiness
```

The named volume is mounted at `/var/lib/postgresql`, as required by PostgreSQL
18. Initialization scripts run only on an empty volume. Editing `.env` passwords,
database names, or role names does not change an existing database: use deliberate
administrator SQL changes or reset disposable local data. If port 5432 is in use,
choose another `DB_PORT` before starting Compose and restart the backend.

## Troubleshooting

### Docker permission denied

If `db:up` reports permission denied for `/var/run/docker.sock`, Compose could
not access Docker. First check whether your account is already in the Docker group:

```bash
getent group docker
```

If your username is listed, run the following **by itself** to open a shell with
the updated group membership:

```bash
newgrp docker
```

If your username is not listed, a local administrator can add it:

```bash
sudo usermod -aG docker "$USER"
```

Then log out and back in, or run `newgrp docker` in the terminal you will use.
Existing IDE processes retain their old groups until restarted. From `backend/`
in a shell with Docker access, retry:

```bash
docker info
npm run db:up && npm run migration:run && npm run db:check
```

### Connection refused or authentication failed

`ECONNREFUSED 127.0.0.1:5432` usually means no database is listening on the
configured address. Check Docker access, `docker compose ps`, and
`docker compose logs --tail 100 database`, then start the database before running
migrations. If the port is occupied, change `DB_PORT` in `.env` and recreate the
container with `npm run db:up` before restarting the backend.

For authentication failures, check that `.env` matches the credentials used when
the volume was first initialized. Editing `.env` alone does not change a stored
password. Use an intentional administrator SQL update or the disposable-data
reset below; do not delete a volume containing data you need.

### npm installation warnings

Dependency deprecation notices and `npm audit` summaries are separate from Docker
permission or connection errors. Use `npm audit` to inspect dependency findings;
avoid blindly applying `npm audit fix --force`, which may change dependency major
versions. A successful `npm ci` does not start the database.

### Reset disposable development data

**Destructive local reset:** the following permanently deletes this Compose
project's development database. Do this only when its data can be discarded:

```bash
docker compose down --volumes
npm run db:up
npm run migration:run
```

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
