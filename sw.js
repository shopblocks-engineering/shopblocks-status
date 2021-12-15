const cachename = 'cache';
const assets = [
    'assets/js/app.js',
    'assets/css/normalize.css',
    'assets/rocket.css',
    'assets/img/logo.ico',
    'assets/img/logo.png'
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