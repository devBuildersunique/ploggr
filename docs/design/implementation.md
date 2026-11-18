# Flutter preview design

This design record describes the 18-screen redesign delivered on 17 November 2026. For the current app, API and database setup, start with the [project README](../../README.md). For the results and images from the design review, see [visual validation](validation.md).

## Starting point

Before the redesign, the app had seven routes covering splash, login, signup, home, leaderboard, session and summary. Riverpod and go_router were in place. The screens held local mock state, the theme was empty, orange and brown styling was duplicated, and two navigation actions were inactive. The old splash logo was the only bundled artwork.

## Implementation stages

1. Kept the app entry point, central routes and feature directories. Moved shared colors, typography, theme and widgets into the design system.
2. Implemented the splash, three onboarding pages and keyboard-safe authentication previews.
3. Added the home, sample camera, litter report, map, session and summary screens.
4. Built the cleanup, challenge, leaderboard, badge, community and profile screens with typed fixtures and Riverpod controllers.
5. Checked navigation, interactions, compact layouts and large text, then captured the Android screens and built the debug APK.

## Reference screen interpretation

| Screen | Composition |
| --- | --- |
| Splash | Botanical corner, dark green wordmark, two-line motto, layered park |
| Onboarding 1 | Park clean-up illustration, centered heading/body, dots, next |
| Onboarding 2 | Large green trophy in pale circle, leaves, dots, next |
| Onboarding 3 | Hands supporting seedling, centered copy, Get Started |
| Login | Botanical accent, wordmark, welcome heading, outlined fields, social row |
| Sign up | Back, centered title, five outlined fields, green action |
| Home | Greeting, pale impact card, three stats, two actions, challenge, shortcuts |
| Scan | Full sample photo, corner viewfinder, caption, shutter/gallery/flash |
| Report | Photo, six litter choices, coordinates, optional description, save |
| Litter map | Two tabs, pale street map, green/red pins, selected litter card |
| Session | Timer, three metrics, route map, pause/stop, nearby alert |
| Summary | Date/distance/time, weight stepper, litter chips, photos, save |
| Nearby | Map/list tabs, green pins, event distance/date/attendees/join |
| Challenges | Three filters, illustrated cards, time/progress indicators |
| Leaderboard | Time filters, compact rows, medals, highlighted self |
| Badges | Large leaf shield, earned count, six achievement tiles |
| Community | Feed/My Posts, avatar rows, photo post, reactions, compose |
| Profile | Avatar/name/handle, three stats, five destinations, bottom nav |

## Design decisions

Feature controllers own preview state. The app bundles artwork and fonts, draws sample maps locally, and identifies simulated services in the UI. Safe areas, scrollable forms, constrained widths, wrapping controls and 48 dp targets support phones and enlarged text. [Asset provenance](assets.md)
