import 'package:flutter/services.dart';

/// One group of portraits in the picker — a "set" of faces, named after
/// the filename prefix they share.
class HeadshotSet {
  /// The prefix the files share: `deep`, `tan`, `asian`, whatever the
  /// art was named.
  final String key;

  /// The prefix tidied up for a section header: `east_asian` reads as
  /// "East Asian".
  final String label;

  final List<String> assets;

  const HeadshotSet({
    required this.key,
    required this.label,
    required this.assets,
  });
}

/// Every portrait the build actually ships, discovered at runtime.
///
/// Read from the asset manifest rather than from a hand-maintained list,
/// because the list is the thing that goes stale: art gets drawn, dropped
/// into `assets/fighters/`, and then doesn't show up because nobody
/// remembered to add it in Dart. `pubspec.yaml` registers the whole
/// directory, so a new PNG is in the bundle the moment it is saved — and
/// this makes it pickable with no code change at all.
///
/// Files are grouped by the prefix before the first underscore, so
/// `tan_04.png` and `tan_05.png` land together and a new `asian_01.png`
/// opens a new group on its own.
class HeadshotCatalog {
  HeadshotCatalog._(this.sets);

  final List<HeadshotSet> sets;

  /// Where portraits live. Anything nested deeper — the source sheets in
  /// `assets/fighters/source/`, say — is art *to cut up*, not art to
  /// show, and is left out.
  static const String directory = 'assets/fighters/';

  static const Set<String> _imageExtensions = {'.png', '.jpg', '.jpeg', '.webp'};

  List<String> get allAssets => [for (final set in sets) ...set.assets];

  bool get isEmpty => sets.isEmpty;

  /// Loaded once and reused — the manifest doesn't change while the app
  /// is running, and the picker opens often enough to notice.
  static Future<HeadshotCatalog>? _cached;

  static Future<HeadshotCatalog> load({AssetBundle? bundle}) {
    if (bundle != null) return _build(bundle);
    return _cached ??= _build(rootBundle);
  }

  /// Drops the memoised catalog. Only useful in tests, which load
  /// different manifests in one process.
  static void resetCache() => _cached = null;

  static Future<HeadshotCatalog> _build(AssetBundle bundle) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);

    final paths = <String>[];
    for (final asset in manifest.listAssets()) {
      if (!asset.startsWith(directory)) continue;
      final name = asset.substring(directory.length);
      // Directly in the folder, not in a subfolder.
      if (name.contains('/')) continue;
      final dot = name.lastIndexOf('.');
      if (dot < 0) continue;
      if (!_imageExtensions.contains(name.substring(dot).toLowerCase())) {
        continue;
      }
      paths.add(asset);
    }
    paths.sort();

    final grouped = <String, List<String>>{};
    for (final path in paths) {
      grouped.putIfAbsent(groupKeyOf(path), () => []).add(path);
    }

    final keys = grouped.keys.toList()..sort();
    return HeadshotCatalog._([
      for (final key in keys)
        HeadshotSet(key: key, label: labelFor(key), assets: grouped[key]!),
    ]);
  }

  /// The set a file belongs to: everything before the first underscore.
  /// A file with no underscore is its own group, named after itself.
  static String groupKeyOf(String assetPath) {
    final name = assetPath.split('/').last;
    final dot = name.lastIndexOf('.');
    final stem = dot < 0 ? name : name.substring(0, dot);
    final underscore = stem.indexOf('_');
    return underscore <= 0 ? stem : stem.substring(0, underscore);
  }

  /// `east_asian` -> "East Asian". Whatever the art is named is what the
  /// section header says, so naming files sensibly is the whole of the
  /// configuration.
  static String labelFor(String key) {
    return key
        .split(RegExp(r'[_\-]'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
