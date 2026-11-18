.DEFAULT_GOAL := help
.PHONY: help setup api app check validate down

DEVICE ?= linux

help:
	@printf '%s\n' \
	  'make setup     Install locked dependencies and create missing local config files' \
	  'make api       Start PostgreSQL, apply migrations and run the Nest watch server' \
	  'make app       Run the configured Flutter app (DEVICE defaults to linux)' \
	  'make check     Analyze and test Flutter and the backend without Docker' \
	  'make validate  Run the full isolated Linux foundation checks' \
	  'make down      Stop the development database and keep its volume'

setup: backend/.env config/development.local.json
	flutter pub get --enforce-lockfile
	npm --prefix backend ci --include=dev

backend/.env:
	cp backend/.env.example "$@"

config/development.local.json:
	cp config/development.example.json "$@"

api:
	npm --prefix backend run db:up
	npm --prefix backend run migration:run
	npm --prefix backend run start:dev

app:
	flutter run -d "$(DEVICE)" --dart-define-from-file=config/development.local.json

check:
	flutter analyze --no-pub
	flutter test --no-pub
	npm --prefix backend run check

validate:
	node tool/validate_foundation.mjs

down:
	npm --prefix backend run db:down
