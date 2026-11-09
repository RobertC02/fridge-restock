// The app page: try the network first so updates show straight away, but give up after 3 seconds
// and use the saved copy, so weak or no signal still opens the app.
// Everything else (fonts, icon): serve the saved copy instantly and refresh it in the background.
const C = 'fridge-restock-v2';
const WAIT_MS = 3000;
self.addEventListener('install', e => {
  e.waitUntil(caches.open(C).then(c => c.addAll(['./', './manifest.webmanifest', './icon.png'])));
  self.skipWaiting();
});
self.addEventListener('activate', e => e.waitUntil(
  caches.keys().then(ks => Promise.all(ks.filter(k => k !== C).map(k => caches.delete(k)))).then(() => self.clients.claim())));
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  if (new URL(e.request.url).pathname.endsWith('/fridges.json')) return; // always fetch the latest plans from the network
  if (e.request.mode === 'navigate') {
    e.respondWith(caches.open(C).then(async c => {
      const net = fetch(e.request.url, { cache: 'no-store' }).then(r => { if (r.ok) c.put(e.request, r.clone()); return r; });
      const slow = new Promise((_, no) => setTimeout(no, WAIT_MS));
      try { return await Promise.race([net, slow]); }
      catch { return (await c.match(e.request, { ignoreSearch: true })) || (await c.match('./')) || net; }
    }));
    return;
  }
  e.respondWith(caches.open(C).then(async c => {
    const hit = await c.match(e.request, { ignoreSearch: true });
    const net = fetch(e.request).then(r => { if (r.ok || r.type === 'opaque') c.put(e.request, r.clone()); return r; }).catch(() => hit);
    return hit || net;
  }));
});
