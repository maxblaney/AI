# MMA Promoter

A mobile management sim where you run an MMA organization as promoter/CEO:
sign fighters, build fight cards, run events, and manage the books. You
never fight — you manage the business and creative direction of the
promotion.

This is the **v1 vertical slice, extended**: all 8 real weight classes, a
generated talent pool with nationality-matched names, roster
filter/sort, create-from-scratch and edit-stats for any fighter,
sign/release, event booking (with a real venue picked from a fixed list
and a player-set ticket price), fight simulation, finances, a choice of
starting cash/reputation tier at new-game setup, and two random event
types (injuries, contract disputes). Everything else in the original
design doc (rivalries, sponsors, staff, title belts, media deals, org
tier progression beyond the data model) is intentionally out of scope
for now.

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

## Game systems

- **Weight classes**: `WeightClass` has the real 8 divisions (Flyweight
  125 → Heavyweight 265). The starting roster spreads fighters across all
  of them, and fights can only be booked between fighters in the same
  division (see `event_booking_screen.dart`'s locked-class dropdowns).
- **Venues**: `Venue` is a fixed list of 7 real locations (Regional USA up
  to New York/Manchester), each with its own capacity and rental cost —
  no abstract "tier" anymore. See `lib/data/models/enums.dart`.
- **Ticket pricing**: set per-event at booking time, pre-filled with a
  suggested price per venue. Pricing above the suggestion softens
  attendance demand, pricing below it boosts demand (mild elasticity
  curve in `EventFinanceCalculator`).
- **PPV eligibility**: tied to the org's reputation tier (National/
  International only), not the venue — a small promotion doesn't get a
  PPV deal just by renting a big room.
- **New-game setup**: `NewGameScreen` — name your promotion and pick a
  starting tier (Local $10k / Regional $100k / National $1M /
  International $10M), which sets opening cash and fanbase. Replaces the
  old silent auto-seed; `GameController.needsNewGame` gates it.
- **Roster filter/sort**: `RosterScreen` filters by nationality, weight
  class and style, and sorts by name/age/weight class/wins/popularity —
  same controls on both the signed roster and the talent pool.
- **Create/edit fighters**: `FighterEditorScreen` is shared by both —
  create drops a brand-new fighter into the talent pool; edit preserves
  id/contract and lets you change everything else, including record and
  weight class.
- **Nationality-matched names**: fighter names are generated from
  per-nationality name pools (32 nationalities, `roster_seed.dart`), so a
  Brazilian fighter gets a Brazilian-sounding name, not a
  randomly-assembled mismatch.
- **Height/weight**: every fighter has a plausible height and walk-around
  weight generated per weight class (see `generatePhysicalStats`), shown
  on their profile and editable in the fighter editor.
- **New game starts empty**: nobody's on "My Roster" at the start of a
  save — the whole generated pool starts in the talent pool, and you sign
  who you want.
- **Card structure**: the first 5 fights booked are the "Main Card," the
  rest are "Prelims" (`Fight.mainCardSize`). Main-card fights can be
  designated Main Event or Co-Main Event (mutually exclusive). Each fight
  gets its own round count (3 or 5) and title implications (None /
  Championship / Interim), set when you add it.
- **Weight-class-first booking**: the Add Fight dialog makes you pick a
  weight class before it'll show you fighters — you physically can't book
  a mismatched fight.
- **Round-by-round simulation**: `FightResolver` scores the fight round by
  round (not one dice roll) and stops early on a finish. Right after
  running an event, tap "Round-by-Round" on any fight in the results to
  replay it as an animated blue (fighter A) / red (fighter B) bar per
  round (`FightBreakdownScreen`). This data isn't persisted, so it's only
  available immediately after simulating — not after navigating away and
  back.
- **Injuries from fighting**: separate from the pre-existing injury random
  event, every resolved fight can itself leave a fighter with a minor or
  major injury (worse for the fighter who lost by KO/TKO). An injury from
  fighting never "heals" a fighter back to healthy — it only matches or
  worsens whatever they already had.
- **Fight of the Night / Performance of the Night**: after an event
  completes, award either from the results screen. Bonus scales with the
  org's reputation tier (Local $500 → International $100k), paid out of
  org cash, and gives the winner(s) a popularity/morale bump. One award of
  each per event.
- **Fight history**: a fighter's profile lists their past fights (opponent,
  method, round, event/date) next to their contract, queried live from
  every event's card.

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

- Real contract negotiation — right now signing is you unilaterally
  setting terms; there's no counter-offer, no leverage from a win streak,
  no agent. The only two-way negotiation is the reactive contract-dispute
  random event.
- Morale affecting anything mechanical — it's tracked and displayed but
  doesn't currently feed into fight performance, injury odds, or dispute
  odds.
- Rivalries/storylines that feed into hype and ticket sales
- Sponsors, staff hiring, media deals
- Title belts and championship lineage
- Reputation tier progression during play — `ReputationTier` is fixed at
  new-game setup and tracked via `reputationPoints`, but nothing currently
  promotes an org from e.g. Regional to National as points accumulate.
- A talent pool that replenishes — it's a fixed batch generated once at
  new-game setup; it only shrinks (as you sign fighters) or grows via
  your own "Create Fighter." No organic prospect pipeline yet.
- More random event types (positive drug tests, callouts, poaching, media
  controversies, weigh-in incidents — the `RandomEventType` enum already
  has slots for these)
- A real calendar/clock instead of "book now, simulate whenever"
