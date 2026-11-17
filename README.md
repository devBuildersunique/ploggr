# 🌱 Ploggr

Ploggr is a Flutter-based mobile application that promotes plogging—the practice of picking up litter while walking, jogging, or running.

The goal of Ploggr is to encourage a healthier lifestyle while making a positive impact on the environment through community-driven participation.

---

## ✨ Features

The complete 18-screen green mobile UI is available as an offline preview.
Start with `flutter run`, advance through onboarding, and choose **Explore the
preview** on Login. Sample forms also work with fictional details.

The preview includes camera/report/map flows, a pauseable sample plogging
session, session summaries, clean-ups, challenges, rankings, badges, a local
community feed, and an editable profile. Saved sessions update your impact;
reports, joins, posts, comments, and profile changes last until the app restarts.
No authentication, GPS, camera, live maps, AI detection, or backend calls are made.

See the [implementation notes](docs/design/implementation.md),
[asset provenance and prompts](docs/design/assets.md), and
[validation report](docs/design/validation.md).

Planned features include:

- User Authentication
- Clean and Modern UI
- Live Plogging Sessions
- GPS Route Tracking
- Community Challenges
- Leaderboards and Achievements
- User Profiles

---

## 📱 Built With

- Flutter
- Dart
- NestJS and TypeScript
- PostgreSQL and PostGIS
- TypeORM and Docker Compose

---

## 🧱 Application Architecture

`lib/main.dart` starts the app inside Riverpod's `ProviderScope`, which makes
providers available to the widget tree. `lib/app.dart` builds the root
`MaterialApp.router`; the router provider is in `lib/routes/app_router.dart`.

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/   # App-wide values such as colors
│   ├── theme/       # Material theme configuration
│   ├── services/    # App-wide integrations
│   └── utils/       # App-wide non-UI helpers
├── routes/          # Router and centralized route paths
├── features/        # auth, home, leaderboard, splash, plogging, profile
├── models/          # Domain models shared across features
└── shared/widgets/  # Reusable UI used by multiple features
```

Keep screens and feature-specific state or logic inside
`lib/features/<feature>/`. Feature-owned Riverpod providers can live in a
`providers/` subfolder there. Put cross-feature widgets in
`lib/shared/widgets/`, and reserve `lib/core/` for app-wide foundations that
aren't owned by a feature.

Add destinations to `AppRoutes` in `lib/routes/app_routes.dart` and register
their screens in `lib/routes/app_router.dart`. Navigate with go_router using
those centralized paths. This keeps route definitions in one place while
letting each feature own its screens and behavior.

---

## 🚀 Getting Started

Clone the repository:

```bash
git clone https://github.com/devBuildersunique/ploggr.git
```

Navigate to the project:

```bash
cd ploggr
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## Backend API

The NestJS TypeScript backend lives in [`backend/`](backend/README.md) and runs
independently of Flutter. See its README for development setup, environment
configuration, API conventions, and verification commands. PostgreSQL/PostGIS
runs in Docker Compose; the backend uses TypeORM and explicit migrations.

---

## 📂 Project Status

The frontend design preview, NestJS API foundation (M1.4), and PostgreSQL/PostGIS
database foundation (M1.5) are implemented. The backend connects to PostgreSQL,
uses explicit TypeORM migrations, and provides a process health endpoint.
Flutter currently uses offline preview data; mobile-to-backend integration,
authentication, domain persistence, and real device services remain future work.

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repository.
2. Create a feature branch from `development`.
3. Commit your changes.
4. Open a Pull Request targeting the `development` branch.

---


> *Building a cleaner planet, one step at a time.* 🌍
