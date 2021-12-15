const cachename = 'cache';
const assets = [
    'shopblocks-status/assets/js/app.js',
    'shopblocks-status/assets/css/normalize.css',
    'shopblocks-status/assets/rocket.css',
    'shopblocks-status/assets/img/logo.ico',
    'shopblocks-status/assets/img/logo.png'
];

self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(cachename).then(cache => {
            cache.addAll(assets);
        }).then(() => {
            return self.skipWaiting();
        })
    )
});

self.addEventListener('fetch', (event) => {
    event.respondWith(caches.match(event.request)
        .then(response => {
            if (response) {
                return response;
            }
            return fetch(event.request);
        })
    );
});

self.addEventListener('activate', (event) => {
    return self.clients.claim();
});