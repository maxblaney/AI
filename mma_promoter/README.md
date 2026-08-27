# MMA Promoter

A mobile management sim where you run an MMA organization as promoter/CEO:
sign fighters, build fight cards, run events, and manage the books. You
never fight — you manage the business and creative direction of the
promotion.

This is the **v1 vertical slice**: one weight class, a generated talent
pool, sign/release, event booking, fight simulation, finances, and two
random event types (injuries, contract disputes). Everything else in the
original design doc (multiple weight classes, rivalries, sponsors, staff,
title belts, media deals, org tier progression beyond the data model) is
intentionally out of scope for now.

## Stack

- **Flutter (Dart)** for the UI — one codebase for iOS + Android, and
  well-suited to list/table/dashboard-heavy management-sim UI.
- **Drift** (on top of `sqlite3`) for local relational persistence —
  fighters, contracts, events, fights and random events are all genuinely
  relational, so a real SQL layer beats a document/key-value store here.
- **provider** for state management — a single `GameController`
  (`ChangeNotifier`) is the one source of truth the UI reads from and
  writes through.
- Game logic (fight resolution, event finances, random events) lives in
  plain Dart classes under `lib/domain/`, with **zero Flutter or database
  imports**, so it's unit-testable in isolation. See `test/domain/`.
- No backend, no multiplayer, fully offline.

## Getting started

```bash
flutter pub get

# Regenerates lib/data/db/database.g.dart from lib/data/db/tables.dart.
# The generated file is committed, so this is only needed after you change
# the schema — but run it once after cloning to be safe.
dart run build_runner build --delete-conflicting-outputs

flutter run
```

Run the domain unit tests with:

```bash
flutter test
```

### Environment note

This scaffold was built and validated (`flutter analyze`, `flutter test`)
in a sandbox without an Android/iOS toolchain or a display, so it hasn't
been run in an actual mobile simulator yet. Do that first before building
on top of it — `flutter run -d <device>` on a machine with Xcode/Android
Studio set up.

It *has* been driven end-to-end in a browser (see "Web preview" below),
which exercises the same UI and game logic as mobile — everything except
the native SQLite persistence.

### Web preview

`flutter build web` works and was used to smoke-test the full loop (sign
fighters, book a card, run an event, resolve a random event) with headless
Chromium. Two things make this possible that don't apply to the real
mobile build:

- **`--web-renderer html`** — the default CanvasKit renderer fetches its
  `.wasm` runtime from Google's CDN at startup, which won't work offline
  or behind a restrictive network. The HTML renderer needs no such fetch.
- **In-memory persistence** — Flutter web has no `dart:io`, so the Drift
  SQLite backend can't run there. `lib/data/db/connection.dart`
  conditionally exports a native (`connection_native.dart`, real SQLite)
  or web (`connection_web.dart`, stub) implementation, and
  `main.dart` constructs `GameController.inMemory()` instead of the
  default `GameController()` when `kIsWeb` is true — same UI, same domain
  logic, volatile state that resets on reload. See
  `lib/data/repositories/repository_contracts.dart` and
  `lib/data/repositories/in_memory/`.

```bash
flutter build web --release --web-renderer html
cd build/web && python3 -m http.server 8765
# open http://localhost:8765 in a browser
```

This is a preview path, not a target platform — the real deliverable is
the native mobile app with real persistence.

## Architecture

```
lib/
  core/utils/         # Small cross-cutting helpers (id generation)
  data/
    models/           # Plain Dart domain models (Fighter, Organization,
                       #   Event, Fight, Contract, RandomEvent, enums)
    db/                # Drift schema (tables.dart), generated code, and
                       #   the AppDatabase with query methods
    repositories/     # Bridge DB rows <-> domain models; the only layer
                       #   that imports both drift and the plain models.
                       #   repository_contracts.dart defines the interfaces
                       #   GameController depends on; in_memory/ holds the
                       #   volatile web-preview implementations.
    seed/              # Starting roster / organization generation for a
                       #   brand-new game
  domain/
    simulation/        # FightResolver — resolves a matchup from stats +
                       #   RNG into a FightResult. Pure Dart, seedable.
    finance/            # EventFinanceCalculator — attendance/PPV/revenue/
                       #   expenses/reputation from a resolved card
    events/              # RandomEventEngine — generates and resolves
                       #   injuries / contract disputes
  presentation/
    state/              # GameController: owns the DB + repos + domain
                       #   engines, exposes plain state to widgets
    screens/            # dashboard, roster (list + profile), event
                       #   booking, event results, finance
    widgets/            # Shared widgets (fighter list tile, random event
                       #   dialog)
```

Data flows one way: **UI reads `GameController` state → calls a
`GameController` method → which calls a repository → which calls
`AppDatabase` → streams flow back up and rebuild the UI.** Domain engines
(`FightResolver`, `EventFinanceCalculator`, `RandomEventEngine`) never
touch the database directly; `GameController` is the only place that wires
domain logic to persistence.

### Why a single `GameController` instead of one provider per feature?

For this scope (one save, one screen at a time cares about roster +
org + events together), a single app-wide controller is simpler to reason
about than wiring up five separate providers with cross-dependencies. If
the app grows enough that this becomes a bottleneck, it's a fine seam to
split along (e.g. a dedicated `RosterController`).

## What's next (post-MVP, not built yet)

- Multiple weight classes and a bigger talent pool per class
- Rivalries/storylines that feed into hype and ticket sales
- Sponsors, staff hiring, media deals
- Title belts and championship lineage
- Org tier progression unlocking bigger venues/sponsors (the data model
  has `ReputationTier` and reputation points; nothing currently gates
  content behind them)
- More random event types (positive drug tests, callouts, poaching, media
  controversies, weigh-in incidents — the `RandomEventType` enum already
  has slots for these)
- A real calendar/clock instead of "book now, simulate whenever"
