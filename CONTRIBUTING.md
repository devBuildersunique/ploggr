# Contributing to Ploggr

Start by running the project and reaching **Connected** in the preview. For a Flutter-only change, the offline preview and widget tests are sufficient to start development. [Project quickstart](README.md#run-the-complete-foundation)

## Start a change

Fork the repository on GitHub, clone your fork, and add the upstream remote once. Replace `YOUR-ACCOUNT` with your GitHub account.

```bash
git clone https://github.com/YOUR-ACCOUNT/ploggr.git
cd ploggr
git remote add upstream https://github.com/devBuildersunique/ploggr.git
git fetch upstream
git switch -c feature/short-description upstream/main
```

For a stacked milestone, use its specified predecessor as the branch base and identify that branch and commit in the pull request. M1.8 was built on `feature/m1.7-stack-communication` at `e6abeeb`. The README explains how to get its checkout before merge. [Checkout instructions](README.md#get-a-checkout)

## Work in the owning layer

| Change | Implementation and verification |
| --- | --- |
| Flutter screen or navigation | Put the screen and its state in `lib/features/<feature>/`. Reuse Riverpod providers, shared widgets, and central route paths. Cover the interaction in `test/`. The connection test in `integration_test/` exercises the production entry point on a device. |
| Nest endpoint | Keep controllers, services and DTOs together in `backend/src/modules/<feature>/`. Register the module in `AppModule` and exercise its public behavior with unit or HTTP tests. [Backend conventions](backend/docs/maintenance.md#request-and-response-conventions) |
| Database schema | Register the entity and migration in the shared TypeORM configuration. Review both directions and run `npm --prefix backend run test:database` against a disposable database. [Migration workflow](backend/docs/maintenance.md#migrations) |
| Configuration or developer commands | Update the appropriate example and the guide that owns it. Keep machine-specific settings in the ignored local files. Treat every Flutter build define as public. [Configuration reference](docs/development/configuration.md) |
| Artwork or typography | Keep bundled asset paths, provenance and the font license together. The Android capture driver refreshes tracked screenshot references. Run it when intentionally updating them. [Asset provenance](docs/design/assets.md) · [Visual validation](docs/design/validation.md) |

## Check and submit

1. Use `make check` for everyday changes. To format Dart you edited, run `dart format` on the affected files. Run `make validate` for changes to startup, public configuration, migrations, health endpoints or the connection flow.
2. Review `git diff` and `git status --short` before committing. Include lockfile updates with dependency changes and add a regression test when existing coverage would miss the behavior.
3. Push your feature branch to your fork and open a pull request targeting upstream `main` for ordinary work. Link the issue, describe the user-visible behavior or developer workflow, and list the commands and platforms you verified. For a UI change, include an appropriate screenshot. For a schema change, explain migration and rollback effects.
