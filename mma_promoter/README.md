# MMA Promoter

A mobile management sim where you run an MMA organization as promoter/CEO:
sign fighters, build fight cards, run events, and manage the books. You
never fight — you manage the business and creative direction of the
promotion.

This is the **v3 vertical slice**: all 8 real weight classes, a generated
talent pool with nationality-matched names that replenishes over time,
roster filter/sort, create-from-scratch and edit-stats for any fighter
across a 56-attribute fighting/physical/mental model plus fighting style
and tendencies, sign/release, event booking (with a real venue picked from
a fixed list and a player-set ticket price), a position-based fight
simulation with live play-by-play, box score and judges' scorecards, an
Elo-based rankings system, a career-history/accolades
screen, retirement, a potential ceiling that shifts with streaks, finances,
a choice of starting cash/reputation tier at new-game setup, and two random
event types (injuries, contract disputes). Everything else in the original
design doc (rivalries, sponsors, title-belt lineage, media deals, org tier
progression beyond the data model) is intentionally out of scope for now.

## Stack

- **Flutter (Dart)** for the UI — one codebase for iOS + Android, and
  well-suited to list/table/dashboard-heavy management-sim UI.
- **Drift** (on top of `sqlite3`) for local relational persistence —
  fighters, contracts, events, fights and random events are all genuinely
  relational, so a real SQL layer beats a document/key-value store here.
- **provider** for state management — a single `GameController`
  (`ChangeNotifier`) is the one source of truth the UI reads from and
  writes through.
- Game logic (fight resolution, event finances, random events, career
  progression) lives in plain Dart classes under `lib/domain/`, with
  **zero Flutter or database imports**, so it's unit-testable in
  isolation. See `test/domain/`.
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
which exercises the same UI, game logic and persistence layer as mobile —
the web build runs the same schema and repositories on sqlite3-wasm.

### Saves

Games persist on every platform, and there's nothing to press — the game
saves continuously as you play, because every change is written straight
to the database rather than held in memory and flushed later. Close the
tab, come back tomorrow, and you resume where you left off.

**Multiple saves.** You can keep as many promotions going as you like and
switch between them freely. The gear icon on the dashboard opens the
saves list; each entry shows its week, tier, bankroll and roster size, and
tapping one loads it. Starting a new promotion never disturbs an existing
one, and launching the app reopens whichever save you played last.

Saves live in a single database, with every game-state row tagged by the
id of the organization it belongs to (`SaveScope`, and the `saveId`
columns in `tables.dart`). The repositories read that scope on every
query, so a save can only ever see its own fighters, events, inbox and
random events — `test/data/multi_save_test.dart` drives real SQLite to
prove two saves stay disjoint. Deleting a save removes its fighters,
contracts, events, fights, inbox and random events in one transaction.

- **Native** — on-device SQLite via `sqlite3_flutter_libs`.
- **Web** — the same schema, mappers and repositories running on sqlite3
  compiled to WebAssembly. Drift stores the database file through the
  browser, preferring OPFS and falling back to IndexedDB. This needs
  `web/sqlite3.wasm` and `web/drift_worker.js`, both committed in `web/`
  and copied into the build automatically.

Two consequences worth knowing:

- The save lives in **that browser, on that machine**. It isn't in the
  cloud and doesn't follow you to another device, and clearing site data
  for the origin deletes it. Private/incognito windows generally discard
  it when the window closes. If the browser refuses storage entirely, the
  app says so on startup instead of hanging on a spinner.
- Because saves are real now, **a schema change without a migration would
  break them**. `AppDatabase.migration` is the place for that: any change
  to `tables.dart` bumps `schemaVersion` and adds its step. The
  round-trip tests in `test/data/persistence_round_trip_test.dart` run
  the real schema against in-memory SQLite and will fail if a model field
  never made it into the table or the mappers. v2 (multiple saves) is the
  worked example: it adds the `saveId` columns and then backfills them
  from the single existing organization, so a game already in progress is
  adopted into its own save instead of being orphaned behind an id
  nothing points at. `test/data/migration_test.dart` builds an old
  database by hand and checks exactly that, for v1 and for the v5 belt
  backfill. One wrinkle worth knowing: v5 replaced the `is_champion` /
  `is_interim_champion` flags with a set of belts, so the v3 migration
  step creates those two columns with raw SQL rather than
  `m.addColumn` — the Dart schema no longer has them to reference. On an
  upgraded database the dead columns stay put (dropping a column in
  SQLite means rebuilding the table, and they're harmless with a
  default); a fresh database never gets them.

The `sqlite3.wasm` that works here is the one **bundled with the drift
package** (`.pub-cache/.../drift-<version>/extension/devtools/build/`),
not the release asset from the sqlite3.dart repo — the latter is built
from a different commit and fails at load with
`Import #0 "dart" "localtime": function import requires a callable`. If
you upgrade drift, recopy that file from the new version's cache folder.

### Web preview

`flutter build web` works and was used to smoke-test the full loop (sign
fighters, book a card, run an event, resolve a random event) with headless
Chromium. Two things make this possible that don't apply to the real
mobile build:

- **`--web-renderer html`** — the default CanvasKit renderer fetches its
  `.wasm` runtime from Google's CDN at startup, which won't work offline
  or behind a restrictive network. The HTML renderer needs no such fetch.
- **WebAssembly SQLite** — Flutter web has no `dart:io`, so the native
  SQLite backend can't run there. `lib/data/db/connection.dart`
  conditionally exports `connection_native.dart` or
  `connection_web.dart`, the latter opening the same schema on
  sqlite3-wasm. Saves persist; see "Saves" above. (The in-memory
  repositories under `lib/data/repositories/in_memory/` are still used by
  tests via `GameController.inMemory()`.)

```bash
flutter build web --release --web-renderer html --no-web-resources-cdn \
  --pwa-strategy=none
cp tool/service_worker_tombstone.js build/web/flutter_service_worker.js
cd build/web && python3 -m http.server 8765
# open http://localhost:8765 in a browser
```

`--no-web-resources-cdn` avoids a runtime fetch to Google's CDN for
CanvasKit/font assets, so the built app has no external dependency at
all — useful offline and behind restrictive networks, and used for the
GitHub Pages deploy too.

**`--pwa-strategy=none` and the tombstone worker are not optional for the
deploy.** Flutter's default web build ships a caching service worker, and
once it is registered in someone's browser it keeps serving what it
cached. That is bad enough on its own, but the failure mode is worse than
it sounds: Chrome caches the *service worker script itself* for up to 24
hours, so the browser never re-fetches it, never notices a new build, and
serves a weeks-old app indefinitely. This actually happened — a fix
shipped, deployed and verified was invisible to the person who asked for
it, and reported as not done.

`--pwa-strategy=none` stops the app caching anything, but still generates
and registers an empty worker at `flutter_service_worker.js`. Copying
`tool/service_worker_tombstone.js` over that empty file is what cleans up
after the old one: it deletes every cache the previous worker built and
reloads any open tab, once. It deliberately does not call
`unregister()` — the page re-registers on every load, so that would
install-unregister-reload forever.

A browser already stuck on the old worker needs **one hard reload**
(Ctrl/Cmd+Shift+R) to break out, because only that bypasses the HTTP
cache pinning the stale script; after that it heals and stays healed.
Left alone it recovers on its own once Chrome's 24-hour script cache
expires.

This is a preview path, not a target platform — the real deliverable is
the native mobile app with real persistence.

## Game systems

- **A save opens as a going concern.** A new promotion starts with **20
  fighters already under contract in every division** (160 in all), each
  between 70 and 95 overall, alongside the usual pool of ~400 free
  agents. `generateSignedRoster` draws from a higher, narrower band than
  the talent pool — no journeymen making up the numbers — weighted so
  most of a division is a solid roster fighter (72-78), with contenders
  (79-85), a title picture (86-91) and the odd genuine draw (92-95).
  Contract terms are staggered 2-5 fights so the whole roster doesn't come
  up for renewal at once, and the opening contracts cost nothing up front
  — signing normally charges the show money as a bonus, and 160 of those
  would bankrupt the save before week one.

  **The band is set by the starting tier**
  ([`ReputationTierInfo.signedRosterOverall`](lib/data/models/enums.dart)):
  Local 48-68, Regional 56-78, National 70-95, International 75-99. This
  is not decoration — purses scale hard with overall, so a roster of
  80-overall fighters costs more per card than a local promotion takes at
  the gate all year. A single 70-95 band across every tier put Local
  **$70,760** and Regional **$67,295** in the red on the *cheapest* card
  they could assemble; scaling the roster to the tier keeps all four
  playable and makes the choice say something about the kind of promotion
  you're running rather than just how much cash you happen to have.

  Net on an 8-bout card built from the cheapest half of your own roster,
  measured per tier: Local **+$8,910**, Regional **+$4,300**, National
  **+$49,505**, International **+$572,449**. Booking the *most expensive*
  half loses money at every tier, which is the intended matchmaking
  tension — you cannot main-event your best fighters every week and stay
  solvent.
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
- **Card size and star power drive revenue**: demand is built from a
  *total* card draw, not an average. Each booked bout is worth something
  on its own, and each fighter adds more on top of that with diminishing
  returns (two 40-popularity fighters draw less than one 80). This was a
  real bug before: card popularity was averaged, so adding a fight never
  helped and adding a low-profile prelim actively cut demand. Both the
  gate and PPV buys move on it.
- **PPV eligibility**: tied to the org's reputation tier (National/
  International only), not the venue — a small promotion doesn't get a
  PPV deal just by renting a big room.
- **New-game setup**: `NewGameScreen` — name your promotion and pick a
  starting tier (Local $10k / Regional $100k / National $1M /
  International $10M), which sets opening cash and fanbase. Replaces the
  old silent auto-seed; `GameController.needsNewGame` gates it.
- **Roster filter/sort**: `RosterScreen` filters by nationality, weight
  class and style, and sorts by name/age/weight class/wins/popularity/
  overall — same controls on both the signed roster and the talent pool.
- **Create/edit fighters**: `FighterEditorScreen` is shared by both —
  create drops a brand-new fighter into the talent pool; edit preserves
  id/contract and lets you change everything else, including record and
  weight class.
- **Nationality-matched names**: fighter names are generated from
  per-nationality name pools (33 nationalities, `roster_seed.dart`), so a
  Brazilian fighter gets a Brazilian-sounding name, not a
  randomly-assembled mismatch. The three largest contingents — USA,
  Brazil and Russia, ~60% of the pool between them — have deliberately
  deep pools (roughly 2,000-2,600 first/last combinations each, including
  Brazilian compound given names like "João Vitor" and "Luiz Felipe"),
  which keeps duplicate names across a 400-fighter roster down around 2%.
  The smaller nationalities still run 10×10 pools, so what duplicates
  remain cluster there.
- **Weighted nationality mix**: generated fighters aren't drawn uniformly
  across all 33 nationalities — `_regionWeights` skews the pool toward
  where the sport's real talent base comes from: ~35% USA, ~12.5% each
  Brazil/Russia/Europe, ~5% Australia/New Zealand, ~22.5% spread across the
  rest. Each region's share splits evenly across its member nationalities
  (Europe alone covers 14 countries). Manual creation in the fighter editor
  is unaffected — its nationality dropdown stays a plain alphabetical list.
- **No roster cap**: there's no limit on how many fighters you can sign or
  how big the talent pool grows — it's bounded only by cash for signing
  bonuses.
- **Starting talent pool**: 50 fighters per weight class (400 total) at
  new-game start. Stat generation uses a weighted talent-tier system
  (`_rollStatCenter` in `roster_seed.dart`) so the pool averages roughly a
  72 overall, with a genuine best-of-the-best slice reaching the low-to-mid
  90s and a vanishingly rare (~0.5%) legend tier that's the only way to see
  a 95+ overall.
- **Generated records**: a fighter's record is evidence of how good they
  are, so it's derived from their skill rather than rolled beside it
  (`_rollFightCount`/`_rollRecord` in `roster_seed.dart`). The stat tier
  is rolled first, mapped to an expected career win rate
  (`_winRateByCenter`, ~48% at the bottom of the pool up to ~92% for a
  legend), then jittered — so a good fighter can still have had a rough
  run, but a 94 overall no longer turns up 10-28. Measured across 16,000
  generated fighters, average win rate climbs 50% → 55% → 62% → 70% →
  78% → 86% across the OVR bands, and 90+ fighters average about 15-3.
  Two hard floors finish it: **nobody is generated more than 4 losses
  below .500** (so no 5-10 records — a fighter that far underwater would
  have been cut long before), and nobody with a real career is winless.
  ~87% still land in a believable 4-30 career fights and ~86% still have
  a winning record. Age is generated to roughly fit the fight count so a
  22-year-old never shows up with a 40-fight résumé.
  `test/data/generated_records_test.dart` asserts all of this at scale.
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
- **Position-based fight simulation**: `FightResolver` doesn't roll dice
  for a winner — it simulates the fight. The bout moves between
  **standing, clinch and ground** positions (guard → half guard → side
  control → mount → back) on a real 5-minute-per-round clock. Each
  exchange, fighters pick an action from their tendencies (strike, shoot a
  takedown, close the clinch, circle out) and execute it with their
  individual stats. Damage, fatigue, leg damage, body damage and cuts all
  accumulate; a hurt fighter gets swarmed; a stalled ground position gets
  stood up by the referee. If nobody finishes it, three judges score it.
  See "Simulation model" below.
- **Live play-by-play**: every fight produces a full commentary feed
  ("Silva DROPS Okafor with a left hook!", "The referee stands them up for
  a lack of action"), a fluctuating momentum bar on a countdown clock, a
  UFC-style **box score** (significant strikes split head/body/leg,
  takedown accuracy, submission attempts, control time, knockdowns,
  reversals) and the three **judges' scorecards**. Tap "Watch Live" on any
  fight in the results right after simulating — with 1x/2x/4x speed and a
  skip button (`FightBreakdownScreen`). This data isn't persisted, so it's
  only available immediately after simulating.
- **Realistic judging**: three judges — drawn from a commission pool of
  four (Kyle Gates, Eric Parsons, Lucas Craft, Pablo Llorente), so the
  panel changes fight to fight — each draw their own striking- vs
  grappling-weighting bias, so close rounds genuinely divide a panel,
  which is what produces split and majority decisions instead of every
  fight being unanimous (`judging.dart`).
- **10-8 rounds mean something.** `JudgePanel.dominanceOf` scores how
  overwhelming a round was on a 0-100 curve built from what the unified
  rules ask a judge to weigh — **impact** (knockdowns, near finishes,
  one-way damage), **dominance** (what the loser managed in reply) and
  **duration** — and each judge writes a 10-8 once it clears *their own*
  bar, drawn per fight. Two knockdowns is a 10-8 on every card; otherwise
  a round also has to show real impact, so one won on control alone is a
  10-9 however wide the points gap.

  Per-judge bars matter as much as the height of them: a marginal 10-8
  now lands on one card and not the other two, which is how the sport
  works and wasn't possible when the test was a shared boolean. The
  result is **2.7% of scored rounds** and **~7% of decisions** carrying a
  10-8 anywhere, with 80% of the ones that appear being unanimous. The
  original rule scored off the points margin and made **68%** of rounds
  10-8s; the first fix got that to 7.7% of rounds, which still meant one
  in six decisions had one.
- **Scorecards survive a finish.** Judges score each round as it ends, so
  a second-round knockout still has a scored first round — and it's often
  the interesting part, because the fighter who got stopped was sometimes
  ahead. The Scorecards tab shows them with a line saying how far the
  fight got. Only *completed* rounds are scored; a first-round finish has
  no cards at all.
- **Submissions match the sport's mix**: rear-naked chokes are 38.5% of
  all taps, guillotines 17.4%, armbars 13.1%, and a calf slicer is a
  rounding error (`submissions.dart`). Each hold carries both its target
  share and the positions it can genuinely be applied from — you can't
  take someone's back from inside their guard — and a per-hold weight
  reconciles the two, since a hold reachable from positions the sim
  visits constantly would otherwise overshoot. The weights are fitted
  against the simulator; `test/domain/submission_mix_test.dart` measures
  the real output and fails if a change to the ground game skews it.
- **56-attribute fighter model**: **23 Fighting** stats across striking
  (punching, kicking, power, speed, accuracy, defense, head movement,
  blocking, footwork), wrestling/clinch (takedowns, takedown defense,
  wrestling, clinch striking, clinch control, clinch defense) and ground
  (top control, ground & pound, guard retention, sweeps, scrambling,
  submission offense, submission defense, grappling); **11 Physical**
  (cardio, durability, chin, body toughness, leg toughness, strength,
  athleticism, recovery, explosiveness, flexibility, grip strength);
  **8 Mental** (fight IQ, composure, aggression, discipline, confidence,
  heart, adaptability, killer instinct); and **14 Tendencies**. Plus
  **reach**, which is a real edge at striking range. Every one of these is
  read individually by the resolver.
- **Fighting style & tendencies**: every fighter has one `FightingStyle`,
  drawn from a weighted mix (`_styleWeights` in `roster_seed.dart`) rather
  than uniformly at random — Well-Rounded (16%), Wrestling-Heavy/Counter
  Striker (12% each) and Pressure Fighter/Boxer/Kickboxer/Wrestler (10%
  each) are the common archetypes; Brawler/Point Fighter/Muay Thai/BJJ
  (5% each) are the rarer ones — and 14
  `Tendencies` dials (0-100: striking/takedown/kick/clinch frequency,
  submission attempts, ground & pound, position control, stand-up
  preference, wall work, aggression, counter striking, head hunting,
  body/leg attacks). `roster_seed.dart` correlates generated stats *and*
  tendencies with style, so a wrestler's sheet actually reads like a
  wrestler's.
- **Grappling game plans**: three tendencies — `positionControl`,
  `groundAndPound` and `submissionAttempts` — are normalised against each
  other every time a fighter ends up on top, which is what makes two
  wrestlers with identical takedown stats fight completely differently.
  The seed generator gives each fighter one of four plans (**grinder**,
  **ground striker**, **submission hunter**, **scrambler**), weighted by
  style with real spread inside each: most BJJ players hunt the tap, most
  wrestlers ride position, a wrestling-heavy fighter is more likely to
  posture up and hit, and a pure striker just wants back to his feet.
- **Fighter headshots**: every fighter has a pixel-art portrait
  (`assets/fighters/` — 48 of them, sliced from contributed sprite sheets), shown
  wherever a fighter appears — Roster, Fighter Profile, Rankings.
  `rollHeadshot` (`lib/domain/cosmetics/fighter_headshots.dart`) assigns
  one at generation time from per-nationality skin-tone odds
  (deep/medium/tan): Nigeria and Cameroon skew heavily deep, Northern and
  Eastern Europe sit entirely at the light end (there's no meaningful
  population of, say, Black Russian or Black Polish fighters in reality),
  and genuinely mixed rosters — the USA, Brazil, the Caribbean — get a
  real spread. Any nationality not in the table falls back to the
  lightest available art.
  **Known gap**: the 48-portrait set spans deep to tan, with no pale,
  East Asian or South Asian art, so `tan` is doing double duty as
  "lightest available" for nationalities it isn't really a match for
  (Japan, South Korea, China, Scandinavia). The fix is more art, not
  reweighting — adding a tone means one new `SkinTone` value, its asset
  list in `_headshotsByTone`, and updated `_nationalityToneWeights`.
  `FighterAvatar` renders them at `FilterQuality.none` — nearest-neighbour,
  so the pixels stay square and crisp when scaled up from their native
  32×32 instead of being smeared by Flutter's default smooth filtering —
  on a cool steel-blue studio-backdrop gradient with a soft rim. The
  backdrop is cool by design: the art is warm, so a cool ground gives the
  strongest complementary separation (compared side by side against
  neutral and warm greys, warm backdrops muddied the darker skin tones).
  It still falls back to an initial-letter circle for fighters saved
  before portraits existed.
- **Condition and sharpness**: every roster row carries two readings.
  **Condition** (Peak / Healthy / In-Shape / Injured / Battered) is
  physical freshness — it falls with hard fights, more for a long war than
  a quick finish, and recovers a little every week of rest. An actual
  injury outranks freshness, so the bottom two tiers come straight from
  [InjuryStatus]. **Sharpness** (Sharp / Prepared / Uneasy / Not Prepared
  / Out of Shape) is how ready they are, driven by camp length — the gap
  between the card being booked and the event. Eight weeks is a full camp
  and the only way to be Sharp; book someone on two weeks' notice and
  they'll show up Not Prepared. With nothing booked it falls back to ring
  rust: a fighter idle for a year drifts to Out of Shape.
  **Neither feeds the fight simulation yet** — they're indicators of the
  state of your roster, not modifiers on outcomes. Wiring them into the
  resolver would change how every fight resolves, which is a decision to
  make deliberately rather than a side effect of showing a label.
- **Booking needs two available fighters at a weight**, and the Book
  Event screen now says so. Previously Add Fight simply greyed out with
  no explanation, which reads as the game being broken; it now names the
  actual shortfall (nobody signed, only one signed, too many injured,
  someone serving a suspension, or no division with two available
  fighters) and what to do about it.
- **Roster search**: a search box above both roster tabs, matching name
  or nationality, plus a "12 of 400 free agents" count so it's obvious
  when the rest are hidden rather than missing. The talent pool is 400
  fighters deep (50 per division) in one alphabetical list, and the only
  tools before this were a sort sheet and a filter sheet behind app-bar
  icons — which also apply to *both* tabs at once, so a filter set on My
  Roster silently emptied the Talent Pool. A banner now says so, with a
  one-tap Clear.
- **Hype rating** (`HypeCalculator`): the booking dialog's matchup
  preview carries a hype bar, 0-100, with a band (Filler → Decent Scrap →
  Solid Draw → Big Fight → Must-See) and the four factors behind it —
  **Stars** (combined draw, weighted toward the bigger name, with a
  little credit for raw skill), **Even** (straight off the betting line:
  a pick'em is the best fight there is, a lock the worst), **Violence**
  (power, aggression, killer instinct, striking frequency and head
  hunting, minus positional control — a fighter whose plan is to hold
  someone down works against it) and **Stakes** (a belt, a champion in a
  non-title fight, win streaks, both men ranked). Whichever factor is
  weakest is named underneath, so a short bar tells you what to fix
  rather than just that something is wrong. Setting Title Implications
  moves the bar live.
- **Booked fights can be edited and reordered.** Tapping a bout on the
  card (or its pencil) reopens the same dialog with everything pre-filled
  and saves in place, keeping its slot and its main-event flag. Up/down
  arrows move a bout through the running order — and since the main
  card/prelim split is positional, moving one into the top five promotes
  it.
- **A champion at home is always defending.** Any fight involving the
  champion of the division it's booked in is forced to a title fight
  (`TitleFightRules`), with the control locked and a line saying whose
  belt is on the line. An interim champion forces an interim bout; the
  two meeting is a unification for the real belt. A champion fighting
  *up* a division isn't defending anything, so nothing is forced there —
  the rule keys off the fight's weight class, not the fighter's home one.
  Enforced again at confirm time, since a fighter can win a belt between
  a card being built and booked.
- **Fighters can cross one division.** A fighter may be booked at their
  own weight or one class either side, flagged in the picker with an
  arrow and the weight they're leaving. This is a normal career move in
  MMA and it's also the only route to a second belt — see double champs
  below. Two divisions in one jump is not offered.
- **Record book**: the History tab's leaderboards are scoped to fights
  that happened *on this promotion's cards*. A fighter who arrives 10-2
  and goes 6-0 for you counts as 6 fights, not 18 — their record
  elsewhere is not your promotion's history. 18 categories (fights, wins,
  finishes, KO/TKOs, submissions, decisions, longest win streak, title
  wins, bonuses, shortest average and most total fight time, control
  time, knockdowns, significant strikes, takedowns landed, takedown
  accuracy and defense, main events), built by `RecordBook` from
  persisted per-fight box scores. Rate categories carry a minimum
  (5 takedown attempts, 3 fights) so one lucky takedown can't top the
  accuracy chart, and a leaderboard nobody has scored on is hidden rather
  than shown as a wall of zeroes. Four more boards sit alongside them:
  **Biggest Upsets** (priced off the line as it stood pre-fight, which is
  stamped onto the fight at simulation time because it can't be
  recovered afterwards), **Double Champs**, **Most PPV Buys in One
  Event** and **Highest Revenue in One Event**. The last two name a show
  rather than a fighter, so their rows don't open a profile.
- **Pound-for-pound respects the belt.** P4P spans every division, so
  it can't just put the eight champions on top — but a champion ranked
  below someone he holds the belt over reads as broken, because if the
  contender were really better he'd have the belt. So a belt is worth
  exactly what it needs to be: `PoundForPound` lifts a champion just past
  the best contender in the division he holds and no further, capped at
  150 Elo (60 for an interim belt). His position against *other*
  divisions is still earned on Elo, and a contender more than the cap
  clear of his own champion stays above him — the extreme case. Champions
  are marked on the P4P list with a gold belt icon, a CHAMP / DOUBLE
  CHAMP / INTERIM tag, and a subtitle naming the title rather than just
  the weight.
- **Championships**: belts are held **per division**, as a set on the
  fighter rather than a single flag — which is what makes a double champ
  reachable. Winning a championship fight takes that division's belt off
  whoever held it and leaves any other belt the winner holds alone; an
  interim belt is tracked separately since it doesn't displace the
  undisputed champion, and a draw leaves the belt where it is. A champion
  who wins a second division's title appears in both divisions'
  rankings, labelled with his home weight in the one he visited. In a divisional ranking the champion sits above the
  contenders as **C** (interim as **iC**) with the rest numbering from 1;
  pound-for-pound applies the credit rule above instead. Belt gold
  (`AppColors.belt`, with a muted variant for interim) sits outside the
  60/30/10 palette on purpose, alongside the win/loss greens and reds:
  the accent red was doing double duty as "danger" and "champion", which
  made neither read.
- **Venue choice is about seats, not price.** A venue changes three
  things: how many people it holds, a flat few hundred [local
  walk-ups](lib/data/models/enums.dart) who come because there's a fight
  on in their city, and the rent. What it deliberately does *not* do is
  multiply your following — the people who follow your promotion are the
  same people wherever you stage it.

  This replaces two successive bugs. Originally venues differed only by
  their *suggested ticket price*, and demand was measured against that
  suggestion — so charging a big arena's suggested price was
  demand-neutral and renting one was free money: the same crowd paid
  double for nothing. Making the market a demand *multiplier* was worse,
  conjuring 60% more customers out of a bigger room. Now demand is priced
  against one market-wide reference nudged by a mild
  [`Venue.priceLevel`](lib/data/models/enums.dart), the extra seats only
  matter once you outgrow the small hall, and staging a show in a room
  two sizes bigger than the crowd needed costs reputation
  (`venueOvershoot` — judged on over-reaching rather than raw fill rate,
  so the smallest room in the game is never punished for being small).
- **Ticket pricing has an answer.** Turnout follows a saturating curve:
  1.0 at the market's reference price, rising toward a ceiling as the
  price approaches free, falling away as it climbs. A plain elasticity
  exponent can't do this — below 1 the best move is always "charge more",
  above 1 always "charge less". A finite audience puts the optimum in the
  middle, and each venue's suggested price now sits on it, so the
  suggestion is real advice rather than a number to beat.
- **Fighter pay has no cliffs.** `PayScale` interpolates between its
  anchors **geometrically**, not linearly. Pay spans three orders of
  magnitude, and a straight line between distant anchors makes the slope
  jump at every control point — the old table went up 2x from 55 to 56
  overall, 1.6x from 65 to 66 and 4.2x from 75 to 76, so a single point
  of overall could cost more than the ten before it. A regional promotion
  ran a profitable card of 55s and lost $22,000 on the same card of 65s
  for no reason it could see. In log space each stretch grows by a
  constant ratio per point instead; the steepest is 75-85 at about +27%,
  which is the climb into real star money and is smooth all the way up.
- **Betting odds**: every fight is priced as American moneylines
  (`OddsCalculator`), shown on the booked card, on the event page beside
  each bout, and in the booking dialog's matchup preview. A logistic
  curve on skill (plus form and injuries) sets the win probability, a 5%
  margin is applied so both sides are slightly worse than fair, and
  prices are rounded to fives and never quoted inside +/-100. Nobody is
  ever priced as a lock — the clamp tops out at 92%.
- **Informed matchmaking**: the Add Fight dialog lists each fighter with
  their record, overall and health, and once both corners are picked it
  shows a side-by-side of overall/striking/grappling/physical/mental/
  popularity with the opening line — so you can tell a competitive
  booking from a squash before you make it.
- **Spoiler-free results**: an event's results page opens as a card of
  matchups with odds, not outcomes. Each fight is revealed by watching it
  live or explicitly skipping to the result, and the sections that would
  give the card away — awards, injuries, popularity swings — stay hidden
  until every fight has been seen.
- **Potential**: a ceiling on a fighter's `overall`, shown on their
  profile. Long win streaks (3+) nudge it up, long losing streaks (3+)
  nudge it down, and it never falls below the fighter's current overall
  (`CareerProgressionEngine.adjustPotential`).
- **Elo rankings**: every resolved fight updates both fighters' Elo
  (`CareerProgressionEngine.updateElo`, K=32). The expected result is
  computed from an **effective rating** — Elo shifted by how far a
  fighter's overall sits from the divisional average, at 10 Elo per
  overall point — rather than raw Elo. Textbook Elo only knows results,
  and every fighter arrives at 1500, so beating a 90-overall debutant
  paid exactly what beating a 60 did. Skill is information the ladder
  already has: a 90 now sits 300 effective points above a 60, so from
  1500 beating the 90 is worth **+24** and beating the 60 **+11**, and
  losing to the 60 costs the same way round. The points still land on the
  stored Elo, which stays a record of results — a 95-overall who has
  never fought is on 1500 until they do. A fighter
  becomes "ranked" — and shows up on the **Rankings** tab — after their
  first fight in a division; the tab lists the top fighters per weight
  class by Elo, plus a **Pound-for-Pound** ladder (the default view) that
  ranks every signed fighter against each other on the same Elo scale
  regardless of division.
- **Retirement**: `CareerProgressionEngine.maybeRetire` rolls a retirement
  chance after every fight, driven by age (34+), a long losing streak
  (3+), and major injuries — any combination stacks, capped at 90%.
  Retired fighters leave the signed roster and talent pool and show up on
  the **History** tab instead, with their retirement reason.
- **History tab**: hall-of-fame leaderboards (Most Wins, Highest Elo,
  Longest Active Win Streak, Fight/Performance of the Night counts,
  Highest Potential) plus the full list of retired fighters.
- **Game clock**: `Organization.currentWeek` is the single source of truth
  for "now" — an absolute week count starting at 1, shown as "Year N, Week
  M" (`GameCalendar`, 52 weeks/year). Nothing reads the real wall clock for
  game-time purposes; the only way time moves is the player tapping
  **Advance Week** on the dashboard.
- **Chronological event ordering**: events are booked a chosen number of
  weeks out from `currentWeek` (a slider on the booking screen, not a free
  date picker), and `GameController.simulateEvent` only ever resolves the
  earliest still-scheduled event, only once its week has arrived.
  `advanceWeek` refuses to move the clock past a week where an event has
  already come due — the player is parked there until they run it. Between
  the two, it's structurally impossible to simulate a later-dated event
  before an earlier one.
- **Monthly talent pool refresh**: `Organization.lastTalentRefreshWeek`
  tracks the last time the pool got new blood; every 4 weeks that
  `advanceWeek` crosses drops in ~10 fresh free agents
  (`generateMonthlyTalentPool`), so the pool doesn't go stale over a long
  save.
- **Injuries from fighting**: separate from the pre-existing injury random
  event, every resolved fight can itself leave a fighter with a minor or
  major injury (worse for the fighter who lost by KO/TKO), worsening
  whatever they already had. A fresh injury also gets a healing countdown
  (`Fighter.injuryClearsAtWeek`, rolled by
  `CareerProgressionEngine.rollHealingWeeks` — a few weeks for minor, 10-24
  for major) that `advanceWeek` checks every week, clearing the fighter
  back to healthy on its own once time's up. Rushing recovery via the
  injury random event is still the faster, costlier alternative.
- **Inbox**: a dedicated screen (mail icon, top-right of the dashboard,
  with an unread badge) notifying the player of injuries and retirements
  on their signed roster, idle healthy fighters occasionally asking to be
  booked, and every roster incident below. Generated by `GameController`
  as part of `advanceWeek`/fight resolution and persisted like everything
  else.
- **Roster incidents** (`RosterIncidentEngine`): what the roster gets up
  to away from the cage. Unlike `RandomEvent`s, these have already
  happened by the time the promoter hears about them — there's no choice
  to make, only a mailbox item and the consequences:
  - **Failed drug test** — a six-month (26 week) suspension the fighter
    can't be booked through, a hit to popularity, and a permanent dent in
    strength, explosiveness and power. `advanceWeek` lifts the ban when
    it expires and mails the player to say so.
  - **DUI** — no suspension, a heavy morale hit. It's the fighter's
    problem, not the commission's.
  - **Backstage altercation** — two of your own fighters go at it. Both
    come out more famous and slightly less happy.
  - **Freak injury** — hurt doing something no one in a fight camp should
    have been doing. Usually minor, occasionally not.

  Deliberately rare: a 6% chance per week that anything happens at all,
  which works out to roughly three stories a year across a whole roster.
  Fighters already serving a ban are excluded from the pool, so nobody
  gets buried under consecutive disasters.
- **Calendar**: a dedicated screen (calendar icon, top-right of the
  dashboard) showing the current Year/Week and every scheduled/completed
  event in chronological order, flagging whichever one is ready to run.
- **Fight of the Night / Performance of the Night**: after an event
  completes, award either from the results screen. Bonus scales with the
  org's reputation tier (Local $500 → International $100k) and gives the
  winner(s) a popularity/morale bump. One award of each per event. The
  money comes off org cash **and is charged to that event's expenses**,
  so the card's net profit on the results and Finance screens is what it
  actually cost you — awards land after the finance calculator has run,
  so they're added to the event's books rather than being part of the
  original calculation.
- **Fight history**: a fighter's profile lists their past fights (opponent,
  method, round, event/date) next to their contract, queried live from
  every event's card.
- **Fighter pay**: contracts are show money + a win bonus, not a flat
  per-fight rate — a fighter takes home `showMoney` no matter what, and
  `showMoney + winBonus` if they actually win. `PayScale.suggest` sets the
  market rate the sign dialog pre-fills (and what an unsigned fighter costs
  in the finance calculator): a fighter's `overall` sets a baseline "before
  popularity" purse via a piecewise curve — roughly $1,000 for a 25-55
  overall prospect, $2,500-5,000 for 56-65, ~$12,000 for 65-75,
  $50,000-100,000 for 75-85, and climbing well past $100,000 for the rare
  90+ legend tier — then `popularity` scales that up to +67% at 100
  popularity, since a mediocre fighter with a following draws money a
  similarly-skilled unknown doesn't. The suggestion is a starting point,
  not a floor — the sign dialog lets the player over- or under-cut it.
- **Debt**: cash can go negative — there's no hard floor blocking a
  signing or an expensive card — but a negative balance accrues 1%
  interest every week (`GameController._applyDebtInterest`, ~68% APR if
  left unpaid), shown on the **Finance** tab. Debt is a tool for riding out
  a cash crunch, not a way to permanently outspend income.

## Simulation model

`FightResolver` runs a real bout rather than scoring a matchup. It's the
most intricate part of the codebase, so here's the shape of it.

**Position state machine.** The fight is always in one of `standing`,
`clinch` or `ground`, plus (on the ground) a `GroundPosition` of guard →
half guard → side control → mount → back mount. Position gates everything:
you can't leg-kick from mount, ground and pound barely lands from closed
guard but ends fights from mount, and a rear-naked choke is only really on
from the back.

**Exchange loop.** Each round is 300 seconds. Every exchange consumes a
variable slice of that clock (a striking exchange is quick, riding position
is slow), so the round genuinely runs out of time. Per exchange:

1. Whoever's dictating is decided by footwork, speed and aggression —
   counter-fighters deliberately hang back.
2. They pick an action weighted by their tendencies, adjusted by fight IQ
   (shooting into elite takedown defence is punished, so smart fighters do
   it less), by stamina (gassed fighters stop shooting and start holding)
   and by whether the opponent is hurt (a hurt opponent gets swarmed, not
   wrestled).
3. The action resolves against the *specific* defensive stats that oppose
   it. Head strikes are defended by defense/head movement/footwork/
   blocking; leg kicks mostly by checking (blocking); takedowns by takedown
   defense/wrestling/athleticism/strength/footwork; guard passes by guard
   retention/scrambling/flexibility/athleticism.

**Condition.** Every stat read goes through one `rate()` call that folds in
stamina (weighted per attribute — explosive things collapse when tired,
chin barely cares), accumulated head damage, leg damage where it matters,
morale, carried-in injuries and whether the fighter is currently rocked.
Nothing is bolted on at one call site.

**Damage.** Separate head, body and leg damage pools, resisted by
durability, body toughness and leg toughness respectively. Body work drains
the gas tank hard; leg damage degrades footwork, kicking and takedowns.
Accumulated damage raises knockdown probability rather than acting as a
health bar that empties on schedule — knockdowns come from power vs chin,
and a knockdown starts a finishing sequence whose outcome turns on the hurt
fighter's heart, composure and recovery.

**Grappling intent.** The thing that makes two wrestlers different: on top,
`positionControl` / `groundAndPound` / `submissionAttempts` are normalised
against each other (and against the fighter's actual skill at each, and the
current position) to decide whether they ride, strike or hunt a finish.
From the bottom, `standUpPreference` decides between scrambling up,
sweeping, or attacking a submission off their back.

**Referee.** A ground position with nothing happening for ~70 seconds gets
stood up, which is what stops fights becoming 60% control time.

**Judging.** Three of the four commission judges each draw a
striking-vs-grappling bias for the fight and score every round on damage
(weighted heaviest), significant strikes, knockdowns, position-weighted
control time, takedowns and submission attempts. That disagreement is what
produces split decisions. A 10-8 is gated separately from the points
margin — see `_isTenEight` — because scoring it off the margin turned two
thirds of all rounds into 10-8s.

**Determinism.** `GameController` takes an optional `Random`, which seeds
the fight resolver, the finance calculator and both event engines
together. Tests pass one so a run is repeatable; the app leaves it null.
Before that existed, every controller-backed test was quietly rolling
dice and could fail on an unlucky simulation.

### Calibration

`test/domain/fight_balance_test.dart` simulates thousands of fights between
generated fighters and asserts the aggregate output stays in a realistic
band. Current output against real UFC aggregates:

| Metric | Sim | UFC |
| --- | --- | --- |
| KO/TKO | 31% | ~32% |
| Submission | 24% | ~20% |
| Decision | 43% | ~47% |
| Striking accuracy | 42% | ~43% |
| Takedowns landed / fighter | 1.1 | ~1.3 |
| Takedown accuracy | 38% | ~38% |
| Knockdowns / fighter | 0.38 | ~0.35 |
| Control time / fighter | 143s | ~150s |

Significant strikes landed (~34 per fighter per fight, ~14 per round) runs
below the UFC average of ~18-21 per round. Pushing volume higher starts
inflating the knockout rate, so the finish distribution is prioritised over
raw volume; that's the one number knowingly left off-target.

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
    simulation/        # FightResolver — position-based bout simulation
                       #   (standing/clinch/ground, damage, stamina) and
                       #   judging.dart, the three-judge panel, and
                       #   submissions.dart, the weighted hold catalog.
                       #   Pure Dart, seedable.
    finance/            # EventFinanceCalculator — attendance/PPV/revenue/
                       #   expenses/reputation from a resolved card
    events/              # RandomEventEngine — generates and resolves
                       #   injuries / contract disputes
    career/              # CareerProgressionEngine — Elo, potential drift,
                       #   retirement rolls. Pure Dart, seedable.
  presentation/
    state/              # GameController: owns the DB + repos + domain
                       #   engines, exposes plain state to widgets
    screens/            # dashboard, roster (list + profile), rankings,
                       #   history, event booking, event results, finance
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
- Title belt *lineage* — who beat whom for a belt and when. Current
  holders are tracked per division on the fighter, and the record book
  derives multi-division champions from title-fight history, but there's
  no reign-by-reign timeline.
- Reputation tier progression during play — `ReputationTier` is fixed at
  new-game setup and tracked via `reputationPoints`, but nothing currently
  promotes an org from e.g. Regional to National as points accumulate.
- More `RandomEvent` types with player choices (callouts, poaching, media
  controversies, weigh-in incidents — the `RandomEventType` enum already
  has slots for these). Drug tests, DUIs, backstage scraps and freak
  injuries are covered by `RosterIncidentEngine` instead, since they
  don't ask the player to decide anything.
- ~~Prelims don't pay for themselves at the regional tier.~~ Fixed by the
  pay-curve and venue rebalance below.
