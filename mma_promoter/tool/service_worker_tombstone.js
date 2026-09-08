// Tombstone service worker, copied over the generated one at deploy time.
//
// Earlier builds shipped Flutter's default *caching* service worker. Once
// registered it kept serving whatever it had cached, so a redeploy could
// land on GitHub Pages and a returning player would still be running a
// build from several changes ago — reporting bugs that had already been
// fixed, and getting told they were fixed. Not a nice way to discover the
// deploy pipeline is lying to you.
//
// The app is now built with `--pwa-strategy=none`, which stops it caching
// but still generates (and registers) an empty worker at this path. A
// worker already installed in someone's browser does not go away on its
// own either — it keeps serving its cache until the browser re-fetches
// this script and finds it changed. So this file replaces the generated
// empty one, and its job is to clean up after its predecessor.
//
// Deliberately does NOT call registration.unregister(): the page
// re-registers a worker on every load, so unregistering here would
// install-unregister-reload forever.
self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const names = await caches.keys();
    await Promise.all(names.map((name) => caches.delete(name)));
    await self.clients.claim();

    // Only reload when there was actually something stale to clear —
    // which is the one time this matters, on the changeover. After that
    // there are no caches, so this is a no-op and nothing reloads.
    if (names.length === 0) return;
    const clients = await self.clients.matchAll({type: 'window'});
    for (const client of clients) {
      client.navigate(client.url);
    }
  })());
});

// Never intercept a request. Everything goes to the network, every time.
self.addEventListener('fetch', () => {});
