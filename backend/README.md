# Ploggr backend

NestJS TypeScript API foundation with PostgreSQL/PostGIS infrastructure for
[M1.5 / issue #6](https://github.com/devBuildersunique/ploggr/issues/6).
M1.6 adds consistent environment-file loading and public Flutter configuration;
see the [configuration guide](../docs/development/configuration.md).
M1.7 adds a live database readiness endpoint used by Flutter's manual Settings
check; see the [connection guide](../docs/development/connection-check.md).
Run NestJS on the host and the database in Docker Compose, independently of Flutter.
No domain entities or business tables are introduced by this milestone.

```text
Browser / curl → NestJS on the host (:3000) → PostgreSQL + PostGIS in Docker (:5432)
```

[First-time setup](#first-time-setup) · [Configuration](#configuration) ·
[Verification](#verification) · [Inspect the database](#inspect-the-database) ·
[Stop and restart](#stop-and-restart) · [Troubleshooting](#troubleshooting) ·
[Maintainer guide](docs/maintenance.md)

## First-time setup

These commands assume a Bash-compatible shell on Linux/x86-64, the environment
validated for this milestone. Before starting, install Git, Node.js 24 (see
[.nvmrc](.nvmrc)), npm, and Docker Engine with the Docker Compose plugin supporting
`up --wait`. Docker must be running, and `docker info` must succeed in your shell.
Flutter and a host PostgreSQL/psql installation are not required for backend work.

Clone the repository using the [root setup instructions](../README.md).
For review, check out the feature/PR branch before continuing. From the repository root:

```bash
cd backend
```

If you use nvm, run `nvm use` here. Otherwise ensure `node --version` reports
Node.js 24. Install the locked dependencies and create local configuration:

```bash
npm ci
[ -f .env ] || cp .env.example .env
```

Review `.env` before the first database startup. The command above preserves any
existing configuration. If upgrading from M1.4, copy any missing `DB_*` and
`POSTGRES_PASSWORD` entries from [.env.example](.env.example) into your existing
`.env`. Choose the database name and credentials before creating its volume.

**All remaining terminal commands in this guide run from `backend/`.** Start the
database, apply migrations, and verify PostGIS:

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
Run `cd backend` in the second terminal if it starts at the repository root.
Stop the backend with Ctrl+C; this does not stop the Docker database.

For a compiled run against the same database, stop the watch server first so the
two processes do not compete for port 3000:

```bash
npm run build && npm run migration:run:prod && npm run db:check:prod && npm run start:prod
```

The `:prod` suffix selects compiled JavaScript; it does not change `NODE_ENV` or
provide production hosting, TLS, or production credentials.

## Configuration

NestJS and database CLI tools resolve `backend/.env` independently of their
working directory, for both source and compiled execution. Continue running
npm/Compose commands from `backend/` as shown in this guide.
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
Both NestJS and the database CLI skip `.env` when the process environment sets
`NODE_ENV=test`. Required values must then be supplied explicitly. For Flutter's
API URL, device-specific addresses, and the shared configuration policy, see the
[configuration guide](../docs/development/configuration.md).

## Verification

Choose a check based on what you want to verify:

| Check | Command | Expected result |
| --- | --- | --- |
| Compile the server | `npm run build` | Exit 0; JavaScript written to `dist/` |
| Lint source and tooling | `npm run lint` | Exit 0 |
| Type-check source and tests | `npx tsc --noEmit` | Exit 0 |
| Unit and HTTP tests | `npm test` | All tests pass, with no database needed |
| HTTP tests only | `npm run test:e2e` | Subset of `npm test`; no server needs to be running |
| Current development database | `npm run db:check` | `"connectivity": true` and PostGIS versions/point |
| Isolated database integration | `npm run test:database` | Tests pass and `Database integration checks passed.` |

For the complete automated review, after `npm ci` and with Docker access:

```bash
npm run build && npm run lint && npx tsc --noEmit && npm test && npm run test:database
```

The integration suite rebuilds `dist/`; stop any server using compiled output
before running it. It uses its own configuration, so a development `.env` and
development database are not required.

To check the development HTTP endpoint, keep `npm run start:dev` running in the
first terminal and execute this in the second:

```bash
curl --fail-with-body -i http://127.0.0.1:3000/api/health
```

Expected: HTTP `200`, JSON content type, and `{"status":"ok"}`.
Adjust the host/port if overridden. This endpoint checks that the API process
can serve requests; it does not check external dependencies. You can also open
`http://127.0.0.1:3000/api/health` in a browser. The `/api` prefix by itself is not
a page; use `/api/health`.

For a live PostgreSQL/PostGIS check through HTTP:

```bash
curl --fail-with-body -i http://127.0.0.1:3000/api/health/ready
```

Expected: HTTP `200`, `Cache-Control: no-store`, and
`{"status":"ok","database":"up","postgis":"up"}`. A failed readiness query returns
HTTP `503` in the existing error envelope, without driver details or versions.
The process check continues returning `200` when PostgreSQL becomes unavailable
after backend startup. Follow the [connection guide](../docs/development/connection-check.md)
to verify both paths from the Linux or Android app.

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

The [maintainer checklist](docs/maintenance.md#m15-review-checklist) maps the
milestone requirements to implementation files and verification evidence.

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

## Stop and restart

The database uses a named Docker volume. Choose the command you need:

| Action | Command | Effect |
| --- | --- | --- |
| Stop the backend | Ctrl+C in its terminal | Stops NestJS; database keeps running |
| Stop the database | `npm run db:down` | Removes its container; preserves its data volume |
| Restart the database | `npm run db:up` | Starts it and waits for readiness |
| Follow database logs | `npm run db:logs` | Keeps streaming until Ctrl+C; does not stop the database |

For a routine restart, run `npm run db:up`, `npm run migration:run` to apply any
new migrations, and `npm run start:dev` in that order.

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
docker compose down --volumes && npm run db:up && npm run migration:run
```

For architecture, migrations, API conventions, and the review checklist, see the
[maintainer guide](docs/maintenance.md).
