import 'dart:math';

/// Skin-tone categories the current headshot art covers. This is
/// deliberately a short, growing list — add a value here (and an asset
/// list below) each time a new set of art fills in a tone this game
/// doesn't have yet (pale, olive/Latino, East Asian, South Asian, ...).
enum SkinTone { deep, medium, tan }

/// Headshot art available for each tone, sliced from the pixel-art
/// sprite sheets kept in `assets/fighters/source/` and sorted into
/// buckets by sampled skin brightness (see `tool/slice_headshots.py`).
/// 63 portraits across three sheets so far.
///
/// This map is what the nationality weighting below draws from, so it is
/// what makes new art reach *generated* fighters. The picker in the
/// fighter editor doesn't read it at all — it lists whatever is in the
/// folder — so art missing from here is still choosable by hand, just
/// never rolled.
const Map<SkinTone, List<String>> _headshotsByTone = {
  SkinTone.deep: [
    'assets/fighters/deep_01.png',
    'assets/fighters/deep_02.png',
    'assets/fighters/deep_03.png',
    'assets/fighters/deep_04.png',
    'assets/fighters/deep_05.png',
    'assets/fighters/deep_06.png',
    'assets/fighters/deep_07.png',
    'assets/fighters/deep_08.png',
    'assets/fighters/deep_09.png',
    'assets/fighters/deep_10.png',
    'assets/fighters/deep_11.png',
    'assets/fighters/deep_12.png',
    'assets/fighters/deep_13.png',
    'assets/fighters/deep_14.png',
    'assets/fighters/deep_15.png',
    'assets/fighters/deep_16.png',
    'assets/fighters/deep_17.png',
    'assets/fighters/deep_18.png',
    'assets/fighters/deep_19.png',
    'assets/fighters/deep_20.png',
  ],
  SkinTone.medium: [
    'assets/fighters/medium_01.png',
    'assets/fighters/medium_02.png',
    'assets/fighters/medium_03.png',
    'assets/fighters/medium_04.png',
    'assets/fighters/medium_05.png',
    'assets/fighters/medium_06.png',
    'assets/fighters/medium_07.png',
    'assets/fighters/medium_08.png',
    'assets/fighters/medium_09.png',
    'assets/fighters/medium_10.png',
    'assets/fighters/medium_11.png',
    'assets/fighters/medium_12.png',
    'assets/fighters/medium_13.png',
    'assets/fighters/medium_14.png',
    'assets/fighters/medium_15.png',
    'assets/fighters/medium_16.png',
    'assets/fighters/medium_17.png',
    'assets/fighters/medium_18.png',
  ],
  SkinTone.tan: [
    'assets/fighters/tan_01.png',
    'assets/fighters/tan_02.png',
    'assets/fighters/tan_03.png',
    'assets/fighters/tan_04.png',
    'assets/fighters/tan_05.png',
    'assets/fighters/tan_06.png',
    'assets/fighters/tan_07.png',
    'assets/fighters/tan_08.png',
    'assets/fighters/tan_09.png',
    'assets/fighters/tan_10.png',
    'assets/fighters/tan_11.png',
    'assets/fighters/tan_12.png',
    'assets/fighters/tan_13.png',
    'assets/fighters/tan_14.png',
    'assets/fighters/tan_15.png',
    'assets/fighters/tan_16.png',
    'assets/fighters/tan_17.png',
    'assets/fighters/tan_18.png',
    'assets/fighters/tan_19.png',
    'assets/fighters/tan_20.png',
    'assets/fighters/tan_21.png',
    'assets/fighters/tan_22.png',
    'assets/fighters/tan_23.png',
    'assets/fighters/tan_24.png',
    'assets/fighters/tan_25.png',
  ],
};

/// Per-nationality odds (summing to 100) of drawing a headshot from each
/// available tone, so a generated fighter's portrait is at least
/// plausible for where they're from — Nigeria and Cameroon skew heavily
/// to the deep end, Northern Europe sits entirely at the light end
/// (there's no meaningful population of, say, Black Russian or Black
/// Polish fighters in reality), and the genuinely mixed rosters — the
/// USA, Brazil, the Caribbean — get a real spread.
///
/// Nationalities absent from this table fall back to
/// [_defaultToneWeights]. Note the current art set only spans deep to
/// tan with no pale or East Asian portraits yet, so [SkinTone.tan] is
/// doing double duty as "lightest available" for nationalities it isn't
/// really a match for. Adding those tones is the fix, not reweighting
/// this table.
const Map<String, Map<SkinTone, double>> _nationalityToneWeights = {
  'Nigeria': {SkinTone.deep: 65, SkinTone.medium: 30, SkinTone.tan: 5},
  'Cameroon': {SkinTone.deep: 65, SkinTone.medium: 30, SkinTone.tan: 5},
  'Cuba': {SkinTone.deep: 25, SkinTone.medium: 35, SkinTone.tan: 40},
  'Dominican Republic': {SkinTone.deep: 25, SkinTone.medium: 35, SkinTone.tan: 40},
  'USA': {SkinTone.deep: 25, SkinTone.medium: 20, SkinTone.tan: 55},
  'South Africa': {SkinTone.deep: 20, SkinTone.medium: 20, SkinTone.tan: 60},
  'Brazil': {SkinTone.deep: 15, SkinTone.medium: 30, SkinTone.tan: 55},
  'France': {SkinTone.deep: 15, SkinTone.medium: 15, SkinTone.tan: 70},
  'England': {SkinTone.deep: 12, SkinTone.medium: 13, SkinTone.tan: 75},
  'Canada': {SkinTone.deep: 10, SkinTone.medium: 15, SkinTone.tan: 75},
  'Netherlands': {SkinTone.deep: 10, SkinTone.medium: 10, SkinTone.tan: 80},
};

/// Fallback for every nationality not listed above — the lightest art
/// this set has, since the alternative would be assigning tones that
/// don't fit.
const Map<SkinTone, double> _defaultToneWeights = {SkinTone.tan: 100};

/// Rolls a headshot asset path for a fighter of this [nationality].
/// Always returns art — every fighter gets a portrait.
String rollHeadshot(String nationality, Random rng) {
  final weights = _nationalityToneWeights[nationality] ?? _defaultToneWeights;

  final roll = rng.nextDouble() * 100;
  var cumulative = 0.0;
  for (final entry in weights.entries) {
    cumulative += entry.value;
    if (roll <= cumulative) {
      final pool = _headshotsByTone[entry.key]!;
      return pool[rng.nextInt(pool.length)];
    }
  }
  // Unreachable while the weights above sum to 100, but a float-rounding
  // miss shouldn't leave a fighter faceless.
  final pool = _headshotsByTone[SkinTone.tan]!;
  return pool[rng.nextInt(pool.length)];
}
