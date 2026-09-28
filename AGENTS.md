# AGENTS.md

## Project Overview

Flutter countries trivia game. MVVM architecture with Provider. Shows a flag, user picks the correct country from 4 options. Scoring: 1st try = 10pts, 2nd = 8pts, 3rd = 5pts, fail = 0pts.

## Branch & PR Rules

- **Default branch is `develop`** — all PRs target `develop`, not `main`
- `main` is reserved for stable releases
- Feature branches: `feature/TXXX-short-description` (e.g., `feature/T004-country-model`)
- PR checklist (required before raising):
  - `flutter analyze` passes
  - `flutter test` passes
  - Successful run on Android emulator (screenshot/recording attached)
  - Successful run on iOS simulator (screenshot/recording attached)
  - No visual regressions

## Commands

```bash
flutter analyze          # Lint check
flutter test             # Run all tests
flutter test test/path   # Run single test file
flutter pub get          # Install dependencies
```

## Architecture

```
lib/
├── core/           # Constants, errors, utils (no dependencies on other layers)
├── data/           # Models, datasources (remote API, local SharedPreferences), repository impl
├── domain/         # Entities, abstract repository interfaces
├── presentation/   # Providers (ViewModels), screens, widgets
└── services/       # Persistence service, cache config
```

**Layer dependencies flow downward**: presentation → domain ← data. Domain has no dependencies on data or presentation.

## Key Constraints

- **Persistence**: Solved country codes and total points stored in SharedPreferences. Keys defined in `lib/core/constants/storage_constants.dart`
- **API**: REST Countries v2 (`https://restcountries.com/v2/all`). Flags from `https://flagcdn.com/w320/{iso}.png`
- **Image caching**: `cached_network_image` with custom `FlagCacheManager` (30-day stale, 500 max objects) in `lib/services/cache_config.dart`
- **State management**: Provider with `ChangeNotifier`. Main ViewModel is `GameProvider` in `lib/presentation/providers/`
- **Solved flags**: Filtered out before each round. Never presented again across sessions.

## Ticket System

Work is tracked as tickets in `docs/master_plan.md` (Section 12). Tickets are grouped into waves — tickets within a wave are parallelizable, waves are sequential. Always check the master plan for current ticket status and dependencies.

## Testing

- Unit tests: `test/unit/`
- Widget tests: `test/widget/`
- Integration tests: `test/integration/`
- Run single test: `flutter test test/path/to_test.dart`
- Emulator verification required for all UI tickets before PR
