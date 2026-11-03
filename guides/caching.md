# Caching

[`angel3_cache`](https://github.com/dart-backend/angel/tree/master/packages/cache) caches responses, and the data of services. [`angel3_redis`](https://github.com/dart-backend/angel/tree/master/packages/redis) stores the data of a service in Redis, which can serve as the cache.

```yaml
dependencies:
  angel3_cache: ^10.0.0
  angel3_redis: ^10.0.0
```

## Caching responses

`ResponseCache` keeps responses of matching paths in memory, and serves them again until they expire. Clients whose copy is still current get `304 Not Modified`, as it supports the `If-Modified-Since` header:

```dart
Future configureServer(Angel app) async {
  // Responses expire after `timeout` (10 minutes by default).
  var cache = ResponseCache(timeout: const Duration(days: 2));

  // Close the cache when the application closes.
  app.shutdownHooks.add((_) => cache.close());

  // The request paths to cache, as any `Pattern`.
  cache.patterns.addAll([
    '/robots.txt',
    RegExp(r'\.(png|jpg|gif|txt)$'),
    RegExp(r'^/public/'),
  ]);

  // REQUIRED: The middleware that serves cached responses
  app.fallback(cache.handleRequest);

  // REQUIRED: The response finalizer that saves responses to the cache
  app.responseFinalizers.add(cache.responseFinalizer);
}
```

Only responses that are safe to share are stored: those to `GET`, with status 200, no cookies, not marked `Cache-Control: no-store`, `no-cache` or `private`, no `Vary` other than `Accept-Encoding`, and at most `maxEntryBytes` (1 MB by default) long. Requests with an `Authorization` header or cookies bypass the cache, so a page of one user's session is not served to others. At most `maxEntries` responses (1024 by default) are kept.

The cache key is the request URI, with its query string. Call `cache.purge(key)` to remove a response from the cache.

## Caching a service

`CacheService` caches the data of one service (`database`) in another (`cache`), such as the results of a database query in Redis:

```dart
app.use(
  '/api/todos',
  CacheService(
    cache: MapService(autoIdAndDateFields: false),
    database: todoService,
    timeout: const Duration(minutes: 10),
  ),
);
```

* Cached results expire after `timeout`, 10 minutes by default.
* A cached read is reused only for the same query; set `ignoreParams: true` to reuse it regardless.
* `modify` and `update` write the new record through to `cache`, and `remove` evicts it, so several instances can share one cache.
* If `cache` fails, reads fall back to `database`.

## Redis

`RedisService` is a service of the records of a Redis database, stored as JSON. It takes a client of [`resp_client`](https://pub.dev/packages/resp_client), and a prefix for its keys:

```dart
import 'package:angel3_redis/angel3_redis.dart';
import 'package:resp_client/resp_client.dart';
import 'package:resp_client/resp_commands.dart';
import 'package:resp_client/resp_server.dart';

Future configureServer(Angel app) async {
  var connection = await connectSocket('localhost');
  var client = RespClient(connection);
  var service = RedisService(RespCommandsTier2(client), prefix: 'todos');

  app.use('/api/todos', service);
  app.shutdownHooks.add((_) => connection.close());
}
```

Redis is a flat key-value store, so give each service its own prefix, or they can overwrite one another's records. Prefixes must not nest: `index` on prefix `app` also returns the records of prefix `app:users`.

As the `cache` of a `CacheService`, a `RedisService` lets several instances of the app share one cache. See the [`angel3_redis` README](https://github.com/dart-backend/angel/tree/master/packages/redis) for how it handles ids and concurrent writes.

## Caching serialization

`cacheSerializationResults` caches the JSON of objects that are sent again and again, such as a precomputed list:

```dart
app.fallback(cacheSerializationResults(
  timeout: const Duration(minutes: 5),
  shouldCache: (req, res, value) => value is List,
));
```

Results are cached per object instance, and held weakly, so the objects can still be garbage-collected.
