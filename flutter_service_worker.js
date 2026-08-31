'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"drift_worker.js": "90effdfcc99037ed718548b234ab5275",
"flutter_bootstrap.js": "bedd6ebf7a43126bb3679e5596eca380",
"assets/NOTICES": "6149a1d9516bfb001c912c212a69292f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/AssetManifest.bin": "7eb2314816e26e312c9bdcf04c4dada9",
"assets/assets/fighters/medium_07.png": "ce4e04ebc9e2b24c5715e8e75b3af705",
"assets/assets/fighters/deep_19.png": "8efa643cdd7648f3f0397a68324d5edf",
"assets/assets/fighters/tan_01.png": "981bdb125b6e1ec526ab36060c31a193",
"assets/assets/fighters/medium_12.png": "9cc946af3263beaa9c8b66e7df2207bf",
"assets/assets/fighters/deep_08.png": "05d72ef73c48962a08909224e6168abd",
"assets/assets/fighters/tan_04.png": "ffd407c420ca5d8f7a32670effd04801",
"assets/assets/fighters/tan_14.png": "2cab77035da25c6306aecb94327bf57a",
"assets/assets/fighters/deep_14.png": "e6b4b83a49bcf7d5132e5ec9e8410417",
"assets/assets/fighters/deep_06.png": "f3e87fe429079c6c7e3c3a9e9f848105",
"assets/assets/fighters/deep_07.png": "7890769a69802118e92e482ce1153574",
"assets/assets/fighters/tan_08.png": "dbd22634f97fe5ca2cb74fe834e8d42d",
"assets/assets/fighters/tan_16.png": "fd9d186da704c071a28f6b42ebc6bd0c",
"assets/assets/fighters/tan_03.png": "a77ada4439ed06e731634c722f7bc035",
"assets/assets/fighters/medium_06.png": "d9a29b1695a3cd198f43364bca32f3cb",
"assets/assets/fighters/deep_15.png": "8974b623c4c28a88c86cf2ee5129b6e3",
"assets/assets/fighters/deep_05.png": "0aa223474e35d553a0a52e20c59ec5c0",
"assets/assets/fighters/tan_11.png": "88a7e7b10386bb8fdd2fb6866efd8e3a",
"assets/assets/fighters/deep_02.png": "0a69cb7427d541bc770a1b5b8653f065",
"assets/assets/fighters/tan_02.png": "c7dfef5766a75112bf0ec950ecbb0fe6",
"assets/assets/fighters/deep_16.png": "369427e08b3b96109a1b9c4308121d83",
"assets/assets/fighters/deep_03.png": "9a85ab509e42ff8a35686d50bc37aed3",
"assets/assets/fighters/deep_11.png": "c4463ab46233ca46a45a4ab6e0d17e90",
"assets/assets/fighters/tan_12.png": "06bddd26e7d2a8d692d32b1cfc50c579",
"assets/assets/fighters/medium_13.png": "3af32f86b75b1343b7abc0ee616c0393",
"assets/assets/fighters/deep_09.png": "9b8820015a0d3727a1d64ed77f7ee38d",
"assets/assets/fighters/medium_05.png": "af3ac140ad9a8a0768e4969a04369604",
"assets/assets/fighters/deep_10.png": "ee9ced68068496e7295e65ab2280633d",
"assets/assets/fighters/medium_10.png": "4c6973f12e6340a7d90df62c6af958b7",
"assets/assets/fighters/tan_07.png": "cde535b0c01fd1c6ac82b4c12d5de6b4",
"assets/assets/fighters/deep_18.png": "1e45b462dd3e1b66a533d2df49aabead",
"assets/assets/fighters/medium_03.png": "de405ebd44b3205ae5016c2eee2cb697",
"assets/assets/fighters/medium_11.png": "adcdb4a643e80101dc1cb855f3bd760b",
"assets/assets/fighters/deep_04.png": "d9be1c31ee1624d7bad249e7020ab274",
"assets/assets/fighters/medium_01.png": "1284d3e4222643f8c7d1e1154ab25e62",
"assets/assets/fighters/medium_02.png": "125b775486106aef9090f7f3ae73ffab",
"assets/assets/fighters/tan_13.png": "2af81978972563c2c8a6f4fe6a42f548",
"assets/assets/fighters/deep_13.png": "de7c26bd1f4f6ef21ceed898e1e90a3c",
"assets/assets/fighters/deep_01.png": "1f3cd3b0aa8bbbe1f0a0c96aaf3154eb",
"assets/assets/fighters/medium_08.png": "19fb3d33e928eba914fe5edef6c7f972",
"assets/assets/fighters/tan_05.png": "838039d7704062c6c689969baa89b864",
"assets/assets/fighters/tan_09.png": "007fb90074f98f611cc03abe20ec719a",
"assets/assets/fighters/tan_06.png": "89cff4a2caca2c052e97a2b443dbcca7",
"assets/assets/fighters/deep_12.png": "343cef0a2f7e5d09e946ae36167f091b",
"assets/assets/fighters/medium_04.png": "e7f3943764792388b5ddb18315a48138",
"assets/assets/fighters/tan_15.png": "06cda97585bd3bfef51760c0d1d957de",
"assets/assets/fighters/tan_10.png": "17bfd21bc715fc138515dabc74acf477",
"assets/assets/fighters/deep_17.png": "37fefbb03b43de68748d123f176e49df",
"assets/assets/fighters/medium_09.png": "7a1847e9b9ed46d130a24e2d66737b14",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.json": "fea020f39b4d9030d94661afef857625",
"assets/fonts/MaterialIcons-Regular.otf": "0e1294c8749feb76d0fd9c7cd957d1e0",
"assets/AssetManifest.bin.json": "6c241a5ca61690079c0dd5f12c4564fa",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"sqlite3.wasm": "fa7637a49a0e434f2a98f9981856d118",
"index.html": "fe11cce194481976f06e5f394ef1a569",
"/": "fe11cce194481976f06e5f394ef1a569",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"main.dart.js": "814be7de393715bdee3d3fb6bb48b5ac",
"manifest.json": "32fb474cac9295c9132141dde61df606",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"version.json": "c969aae4638b2e7b02161d4079741217"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
