# Request Limits

## Body size

`req.parseBody()`, which services also use, reads at most `app.maxBodySize` bytes, 10 MB by default, and answers larger requests with `413 Payload Too Large`:

```dart
var app = Angel()..maxBodySize = 1024 * 1024; // 1 MB for the whole app

// Allow larger bodies on one route by raising the limit before parsing.
app.post('/upload', uploadHandler, middleware: [
  (req, res) {
    req.maxBodySize = 100 * 1024 * 1024; // 100 MB
    return true;
  },
]);
```

Set `app.maxBodySize = null` to remove the limit.

See [Parsing Request Bodies](body-parsing.md) for how bodies are parsed.

## Route cache

In production, resolved routes are cached per request path, so a path is only matched against the routes once. The cache holds at most `app.maxHandlerCacheSize` entries, 1024 by default, so requests to many different paths cannot grow it without bound. Set it to `0` to disable the cache:

```dart
var app = Angel()..maxHandlerCacheSize = 4096;
```

## Rate limiting

To limit the number of requests a client can make, use the rate limiters of [`angel3_security`](https://github.com/dart-backend/angel/tree/master/packages/security).
