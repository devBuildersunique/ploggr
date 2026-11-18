# Ploggr backend

The NestJS API runs on the host. TypeORM connects it to PostgreSQL 18 with PostGIS 3.7 in Docker Compose. The health module exposes process liveness and database readiness. For Flutter and backend development together, use the root quickstart. [Full-stack setup](../README.md#run-the-complete-foundation)

## First-time setup

Use Linux x86-64, Node 24.15+ in the 24.x line, npm, and Docker Engine with Compose supporting `--wait`. All commands in this guide run from **`backend/`**. If you use nvm, run `nvm install` and `nvm use` here. Confirm Docker access and prepare the local environment.

```bash
docker info --format '{{.ServerVersion}}'
npm ci --include=dev
[ -f .env ] || cp .env.example .env
```

Choose local database credentials in `.env` before creating the first volume. Then start the database, run migrations, and check PostGIS.

```bash
npm run db:up && npm run migration:run && npm run db:check
```

A successful check prints `"connectivity": true`, both database versions, and coordinates `[78.4867, 17.385]`. Start the API and leave the terminal running.

```bash
npm run start:dev
```

With defaults, Nest logs `API listening at http://127.0.0.1:3000/api`. To test compiled JavaScript, stop the watch server first, then run the following against the same database.

```bash
npm run build && npm run migration:run:prod && npm run db:check:prod && npm run start:prod
```

The `:prod` suffix selects compiled code. Environment values, hosting, credentials and TLS are configured separately.

## Configuration

| Variable | Default or source | Purpose |
| --- | --- | --- |
| `NODE_ENV` | `development` | Accepts `development`, `test`, or `production`. |
| `HOST`, `PORT` | `127.0.0.1`, `3000` | Nest listening address and port. |
| `DB_HOST`, `DB_PORT` | `127.0.0.1`, `5432` | Host address Nest and the CLI use to reach PostgreSQL. Compose publishes the database on this port on loopback. |
| `DB_NAME` | `ploggr` | Database created on first initialization. |
| `DB_USER`, `DB_PASSWORD` | Required | Application role and password. Choose a role distinct from `postgres`. Passwords are used verbatim. |
| `POSTGRES_PASSWORD` | Required by Compose | Administrator password for database initialization. |
| `COMPOSE_PROJECT_NAME` | Compose directory name | Choose a distinct project and volume for concurrent checkouts. |

Nest and the CLI load the same ignored `.env` from source or compiled code. Process variables take precedence. When the process sets `NODE_ENV=test`, both use the process environment alone. Invalid settings fail startup. The local setup uses loopback TCP and the application role for queries and migrations. [Example configuration](.env.example) · [Client and server configuration](../docs/development/configuration.md)

## Verification

| Command | Expected result |
| --- | --- |
| `npm run check` | Lint, TypeScript checking, and unit/HTTP tests pass without a database. |
| `npm run build` | Compiled JavaScript is written to `dist/`. |
| `npm run test:e2e` | Runs only the ordinary HTTP tests. |
| `npm run test:database` | Creates an isolated Compose project, verifies migrations, permissions, spatial queries, restart and failure behavior, then removes its test resources. |
| `npm run db:check` | Verifies the currently configured database and spatial functions. |

The isolated integration suite rebuilds `dist/`. Use a separate checkout if a server is using that build output. After a hard interruption, inspect the printed `ploggr-test-...` project name before removing that disposable project with `docker compose --env-file .env.example -p <test-project> down --volumes`.

With the API running, use another terminal to inspect its two health endpoints.

```bash
curl --fail-with-body -i http://127.0.0.1:3000/api/health
curl --fail-with-body -i http://127.0.0.1:3000/api/health/ready
```

Liveness returns HTTP 200 and `{"status":"ok"}`. A successful readiness check returns HTTP 200 and `{"status":"ok","database":"up","postgis":"up"}`. After a database outage, liveness stays at 200 and readiness returns a sanitized 503 response. Readiness responses use `Cache-Control: no-store`. [Connection troubleshooting](../docs/development/connection-check.md#failure-and-recovery)

## Inspect the database

Open psql inside the current development container using its configured database and administrator role.

```bash
docker compose exec database bash -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
```

At the psql prompt, run `SELECT version();`, `SELECT PostGIS_Full_Version();`, or `SELECT * FROM migrations;`. Use `\dt` to list tables and `\q` to exit. The foundation contains migration metadata and extension-owned objects such as `spatial_ref_sys`. [Migrations and permissions](docs/maintenance.md#migrations)

## Stop and restart

Stop Nest with Ctrl+C. Run `npm run db:down` to remove the container and retain its named volume. To restart, run `npm run db:up`, `npm run migration:run` and `npm run start:dev` in that order. Use `npm run db:logs` to follow database logs.

## Troubleshooting

| Symptom | Action |
| --- | --- |
| Docker socket permission denied | Check `docker info` in the actual terminal running the commands. On Linux, if your account already belongs to the Docker group, log in again or start a new shell with `newgrp docker`. Otherwise ask the local administrator for Docker access. |
| Connection refused or port occupied | Run `docker compose ps` and `docker compose logs --tail 100 database`. Start the database before the API. For a port conflict, choose a different `DB_PORT` and recreate the container with `npm run db:up`. |
| Authentication fails after editing `.env` | The named volume retains its original role and password. Match those values or intentionally update them through an administrator SQL session. |
| npm reports dependency advisories | Inspect `npm audit` and compare the dependency paths with the current findings. [Foundation security report](../docs/development/foundation-validation.md) |

### Reset disposable development data

**This permanently deletes the selected Compose project's database volume.** Only use it for a database you have decided to discard. Routine shutdown uses `npm run db:down`.

```bash
docker compose down --volumes && npm run db:up && npm run migration:run
```
