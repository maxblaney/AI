import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/domain/cosmetics/headshot_catalog.dart';

/// A bundle serving a made-up asset manifest, so the catalog's rules can
/// be exercised against art this build doesn't ship.
class _FakeBundle extends CachingAssetBundle {
  final List<String> assets;

  _FakeBundle(this.assets);

  @override
  Future<ByteData> load(String key) async {
    if (key != 'AssetManifest.bin') {
      throw StateError('unexpected asset $key');
    }
    // The manifest is a standard-message-codec map of asset path to a
    // list of variant descriptors; an empty list means no variants.
    final encoded = const StandardMessageCodec()
        .encodeMessage({for (final a in assets) a: <Object?>[]})!;
    return encoded;
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      jsonEncode({for (final a in assets) a: <String>[]});
}

Future<HeadshotCatalog> catalogOf(List<String> assets) {
  HeadshotCatalog.resetCache();
  return HeadshotCatalog.load(bundle: _FakeBundle(assets));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('grouping', () {
    test('files are grouped by the prefix before the first underscore',
        () async {
      final catalog = await catalogOf([
        'assets/fighters/tan_02.png',
        'assets/fighters/tan_01.png',
        'assets/fighters/deep_01.png',
      ]);

      expect(catalog.sets.map((s) => s.key), ['deep', 'tan']);
      expect(catalog.sets.last.assets,
          ['assets/fighters/tan_01.png', 'assets/fighters/tan_02.png'],
          reason: 'sorted, so the picker order is stable between runs');
    });

    test('a brand new prefix opens its own set with no code change',
        () async {
      // The point of reading the manifest: art dropped into the folder
      // shows up on its own.
      final catalog = await catalogOf([
        'assets/fighters/tan_01.png',
        'assets/fighters/east_asian_01.png',
        'assets/fighters/east_asian_02.png',
      ]);

      expect(catalog.sets.map((s) => s.key), ['east', 'tan']);
      expect(catalog.sets.first.assets, hasLength(2));
    });

    test('a prefix becomes a readable section header', () {
      expect(HeadshotCatalog.labelFor('deep'), 'Deep');
      expect(HeadshotCatalog.labelFor('east_asian'), 'East Asian');
      expect(HeadshotCatalog.labelFor('south-asian'), 'South Asian');
    });

    test('a file with no underscore is its own set', () async {
      final catalog = await catalogOf(['assets/fighters/boss.png']);

      expect(catalog.sets.single.key, 'boss');
      expect(catalog.sets.single.label, 'Boss');
    });
  });

  group('what counts as a portrait', () {
    test('source sheets in subfolders are art to cut up, not art to show',
        () async {
      final catalog = await catalogOf([
        'assets/fighters/tan_01.png',
        'assets/fighters/source/headshots_v3_sheet.png',
      ]);

      expect(catalog.allAssets, ['assets/fighters/tan_01.png']);
    });

    test('assets outside the fighters folder are ignored', () async {
      final catalog = await catalogOf([
        'assets/fighters/tan_01.png',
        'assets/logos/promotion.png',
        'AssetManifest.bin',
      ]);

      expect(catalog.allAssets, ['assets/fighters/tan_01.png']);
    });

    test('non-images are ignored', () async {
      final catalog = await catalogOf([
        'assets/fighters/tan_01.png',
        'assets/fighters/credits.txt',
        'assets/fighters/notes',
      ]);

      expect(catalog.allAssets, ['assets/fighters/tan_01.png']);
    });

    test('jpg and webp count too', () async {
      final catalog = await catalogOf([
        'assets/fighters/a_01.PNG',
        'assets/fighters/b_01.jpg',
        'assets/fighters/c_01.webp',
      ]);

      expect(catalog.allAssets, hasLength(3));
    });

    test('a build with no art gives an empty catalog rather than throwing',
        () async {
      final catalog = await catalogOf(const []);

      expect(catalog.isEmpty, isTrue);
      expect(catalog.allAssets, isEmpty);
    });
  });

  group('the art this build actually ships', () {
    test('every bundled portrait is discoverable', () async {
      // Guards the wiring end to end: pubspec registers the directory,
      // the manifest lists the files, and the catalog finds them.
      HeadshotCatalog.resetCache();
      final catalog = await HeadshotCatalog.load();

      expect(catalog.isEmpty, isFalse);
      expect(catalog.allAssets.length, greaterThanOrEqualTo(48),
          reason: '48 portraits were sliced from the first two sheets');
      expect(catalog.sets.map((s) => s.key), containsAll(['deep', 'tan']));
      for (final asset in catalog.allAssets) {
        expect(asset, startsWith(HeadshotCatalog.directory));
      }
      HeadshotCatalog.resetCache();
    });
  });
}
