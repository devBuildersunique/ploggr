# Ploggr backend

Minimal NestJS TypeScript API foundation for [M1.4 / issue #5](https://github.com/devBuildersunique/ploggr/issues/5).
Run it independently of the Flutter application. No database or external service is required.

## Development

Use Node.js 24 (see `.nvmrc`) and npm. Run these commands from the repository root:

```bash
cd backend
nvm use                 # Optional, if you use nvm
npm ci
cp .env.example .env
npm run start:dev
```

The development server watches TypeScript files and restarts on changes.
Stop it with Ctrl+C. For a compiled run:

```bash
npm run build
npm run start:prod
```

Configuration is loaded from `backend/.env` when commands run from `backend/`.
Existing process environment variables take precedence. `.env` files are ignored;
the committed `.env.example` contains only non-secret defaults.

| Variable | Default | Meaning |
| --- | --- | --- |
| `NODE_ENV` | `development` | `development`, `test`, or `production` |
| `HOST` | `127.0.0.1` | Listening hostname or IP; use `0.0.0.0` for containers |
| `PORT` | `3000` | Integer from 1 to 65535 |

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
can serve requests; it does not check external dependencies.

## Structure

```text
src/
├── main.ts                 # Bootstrap, configured listen address, shutdown hooks
├── app.module.ts           # Root module and shared providers
├── app.setup.ts            # Global prefix and request validation
├── config/                 # Environment validation and defaults
├── common/filters/         # Shared HTTP error handling
└── modules/health/         # Health module and controller
test/
└── health.e2e-spec.ts      # Health and shared HTTP policy tests
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
Authentication, PostgreSQL/PostGIS, Plog endpoints, and Flutter API integration
are outside this milestone.
