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
flutter build web --release --web-renderer html --no-web-resources-cdn
cd build/web && python3 -m http.server 8765
# open http://localhost:8765 in a browser
```

`--no-web-resources-cdn` avoids a runtime fetch to Google's CDN for
CanvasKit/font assets, so the built app has no external dependency at
all — useful offline and behind restrictive networks, and used for the
GitHub Pages deploy too.

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
- **Realistic judging**: each of the three judges draws their own
  striking- vs grappling-weighting bias for the fight, so close rounds
  genuinely divide a panel — which is what produces split and majority
  decisions instead of every fight being unanimous. Rounds are scored
  10-9, or 10-8 for genuine domination (`judging.dart`).
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
- **Championships**: belts are held **per division**, as a set on the
  fighter rather than a single flag — which is what makes a double champ
  reachable. Winning a championship fight takes that division's belt off
  whoever held it and leaves any other belt the winner holds alone; an
  interim belt is tracked separately since it doesn't displace the
  undisputed champion, and a draw leaves the belt where it is. A champion
  who wins a second division's title appears in both divisions'
  rankings, labelled with his home weight in the one he visited. In a divisional ranking the champion sits above the
  contenders as **C** (interim as **iC**) with the rest numbering from 1;
  pound-for-pound stays a straight Elo list with a belt icon, since it
  spans every division and so has many champions in it.
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
- **Elo rankings**: every resolved fight updates both fighters' Elo rating
  (`CareerProgressionEngine.updateElo`, standard formula, K=32). A fighter
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
  org's reputation tier (Local $500 → International $100k), paid out of
  org cash, and gives the winner(s) a popularity/morale bump. One award of
  each per event.
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

**Judging.** Three judges each draw a striking-vs-grappling bias for the
fight and score every round on damage (weighted heaviest), significant
strikes, knockdowns, position-weighted control time, takedowns and
submission attempts. That disagreement is what produces split decisions.

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
                       #   judging.dart, the three-judge panel. Pure Dart,
                       #   seedable.
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
- **Prelims don't pay for themselves at the regional tier.** Card depth
  now drives revenue properly, but a mid-card bout's purse still runs
  slightly ahead of the gate it generates at $35 a ticket, so a deep card
  earns more and profits a little less. The lever is `PayScale`'s low
  end, which is priced well above what regional MMA actually pays; that's
  a separate rebalance.
