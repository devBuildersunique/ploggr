# Ploggr reference redesign

## Repository audit
The original app has seven routes: splash, login, signup, home, leaderboard,
session, summary. ProviderScope and a disposable Riverpod GoRouter provider
establish the application boundary. Screens hold local mock state; there is
no authentication, camera, GPS, map, or API integration to migrate. The theme
is empty, orange/brown styling is duplicated, two navigation actions are
inactive, and only the original orange logo is bundled. Backend is out of scope.

## Implementation stages
1. Preserve app entry point, router provider, route constants, existing screen
   classes, and feature structure. Centralize tokens, theme, and shared widgets.
2. Implement splash, three onboarding pages, and keyboard-safe auth previews.
3. Implement home, sample camera, litter details/map, session and summary.
4. Implement nearby clean-ups, challenges, leaderboard, badges, community,
   and profile with typed fixtures and Riverpod application controllers.
5. Verify all routes, interactions, compact/standard/large layouts and large
   text; run Android, capture screens, inspect visually, analyze, test, build APK.

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

## Decisions
Flutter, its existing material_ui package, Riverpod, and go_router are preserved. Tokens and common components are centralized.
Feature controllers own preview state. No credentials are stored. All artwork
and fonts are bundled; maps are local illustrative canvases. A Preview label
and contextual notices identify simulated services. SafeArea, scrollable
forms, constrained widths, wrapping controls, and 48dp targets support phones
and enlarged text. Device frames and fake status bars are excluded.
