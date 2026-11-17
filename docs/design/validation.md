# Ploggr redesign validation

Validated on 17 November 2026. This is a complete frontend preview, with the
NestJS backend and database foundation unchanged.

## Delivered screens

1. Splash
2. Onboarding: plog and keep surroundings clean
3. Onboarding: challenges and rewards
4. Onboarding: report litter
5. Login
6. Sign up
7. Home dashboard
8. Scan litter (sample camera)
9. Report litter details
10. Litter map
11. Active plogging session
12. End session details
13. Nearby clean-ups (map and list)
14. Challenges
15. Leaderboard
16. Badges
17. Community (feed and personal posts)
18. Profile

Additional profile destinations: activity, saved litter spots, settings, help,
and about. All are navigable, including from direct routes.

## Reusable design system and architecture

- `core/constants/app_colors.dart`: forest, leaf, primary green, off-white,
  muted text, borders, and semantic accent colors.
- `core/theme`: typography, spacing, radius, shadow tokens, and Material theme.
- `shared/widgets/ploggr_ui.dart`: page shell, cards, primary actions, input
  fields, section headings, segmented filters, stats, litter choices,
  photo component, preview notices, and navigation helpers.
- `shared/widgets/bottom_navigation.dart`: consistent five-position navigation.
- `shared/widgets/eco_art.dart`: wordmark, leaves, landscape/campus art,
  trophies, shields, and local avatars.
- `shared/widgets/preview_map.dart`: pan/zoom illustration, selectable markers,
  and sample route drawing.
- Feature controllers own in-memory session/impact, reports, clean-up joins,
  community posts/reactions/comments, and profile state. Typed fixtures live in
  `core/preview/preview_data.dart`; no backend services are introduced.
- Existing Flutter + material_ui, Riverpod, go_router, app entry point, route
  constants, and feature structure are retained. The router remains disposable
  and can receive a test-only initial-location provider override.

## Automated verification

- `flutter pub get`: passed.
- `dart format`: formatted application, widget tests, integration tests, and tools.
- `flutter analyze`: no issues.
- Widget suite: 124 tests; covers 23 destinations at 320×568, 320×640, 390×844,
  and 480×960 logical pixels, plus 1.6× text at 320×640. Checks reported Flutter
  exceptions and RenderFlex overflows.
- Interaction coverage: onboarding progression; sample login/sign-up validation;
  password visibility; keyboard insets; session start/pause/resume/finish/save;
  duplicate-save protection; resume from an unsaved summary; report type and
  description retention; challenge/ranking filters; bottom navigation; local
  posting; profile destinations; and stale-message navigation regression.
- Android integration: capture all 18 screens, then exercise session save,
  sample capture/report/map, event joining, map/list switching, community
  filtering, and profile navigation on the emulator. Both scenarios passed.
- `flutter build apk --debug`: verified; final artifact at
  `build/app/outputs/flutter-apk/app-debug.apk`.
- The final regular APK was installed separately from the integration harness.
  Splash → onboarding → Skip → Explore the preview → Home was verified with
  Android input and UI inspection; no app runtime exceptions were logged.

The existing Android Gradle Plugin/Kotlin versions produce forward-compatibility
warnings, but the build succeeds. Build tooling versions were not changed.

## Device and visual review

Android API 37 emulator, 1080×2400 pixels at 420 dpi, software rendering.
The captured Flutter surfaces omit native status/navigation bars; the app itself
uses Android's real system bars and SafeArea insets.
The software-rendered emulator displayed a SystemUI startup timeout; after the
system dialog was dismissed, the normal APK launch and navigation worked.
The [native Android Home capture](android-home-native.png) includes real system bars.

See the [18-screen contact sheet](contact-sheet.png) and individual PNGs in
[screenshots](screenshots/). Screens were inspected individually against the
supplied concept for hierarchy, alignment, color, spacing, and consistent cards.
Refinements included larger branding/type, softer illustrated landscapes,
finer map streets and pin-shaped markers, onboarding placement, session map
proportions, narrow-screen wordmark fitting, and bottom navigation sizing.
Device interaction testing exposed a saved-session SnackBar obscuring the camera
shutter; navigation helpers now remove prior-screen feedback before navigating,
and the regression has a dedicated widget test.

Reproduce:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test test_driver tool
flutter analyze
flutter test
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/visual_qa_test.dart -d emulator-5554
flutter build apk --debug
```

Optional deterministic local render previews:
`flutter test tool/render_preview_test.dart` writes to `build/visual-previews/`.

## Preview boundaries and visual differences

- Authentication/social sign-in/password recovery are explanatory previews.
  Forms accept fictional details; no account is created or credentials persisted.
- Camera/gallery/flash/AI detection are simulated with bundled sample photography.
- Maps, coordinates, directions, distance, speed, calories, and events are mock
  data. The session timer runs locally from the reference's sample elapsed time.
- Reports, joins, session impact, posts, reactions, comments, and profile edits
  remain in memory and reset when the app restarts. Nothing is posted online.
- Challenge/rank/badge fixtures demonstrate the intended layouts; actual reward
  rules, notifications, and sync await their backend milestones.
- Custom illustrations, typography, avatars, and the drawn map approximate the
  flattened concept. They are not the original design source assets. Android
  proportions, accessible touch targets, and explicit preview labels also differ.
- Physical-device, iOS, real GPS/camera, authentication, and backend testing are
  outside this frontend milestone. No permissions were added for those services.

Asset paths, generation method, full prompts, and font license are recorded in
[assets.md](assets.md).
