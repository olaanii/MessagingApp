// Firebase Messaging Service Worker
// Required for FCM background message handling on web.
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

// Firebase config is injected at runtime via the main app.
// This SW only needs to be registered; actual config is passed via
// firebase-messaging's getToken() call in the Flutter app.
// If you need background message handling, initialise Firebase here
// with your project config (safe to hardcode in SW — it's public).
self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(clients.claim());
});
