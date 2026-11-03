# 10.0.0 Migration Guide

Angel3 10.0.0 requires Dart SDK 3.13 or later. All `angel3_*` packages are released as 10.0.0 together, so upgrade them at the same time.

**WARNING**, backup your existing code, or commit it, before proceeding with migration.

1. Change the SDK constraint in `pubspec.yaml` to `sdk: ^3.13.0`.

2. Change every `angel3_*` dependency to `^10.0.0`, and run `dart pub upgrade`.

3. If the app uses `MirrorsReflector`, add `angel3_container_mirrors: ^10.0.0` to its dependencies, and change the import:

   ```dart
   // 9.x
   import 'package:angel3_container/mirrors.dart';

   // 10.0.0
   import 'package:angel3_container_mirrors/angel3_container_mirrors.dart';
   ```

   To compile the app with `dart compile exe` instead, see [Running without `dart:mirrors`](../guides/running-without-mirrors.md).

4. Regenerate the generated code, with `dart run build_runner build --delete-conflicting-outputs`. The generators of 10.0.0 write code that the 10.0.0 runtimes need.

5. Go through the breaking changes below, and those of each package the app uses.

6. Run the app's tests.

## Framework

These are the breaking changes of `angel3_framework` that need changes in an app. The [CHANGELOG](https://github.com/dart-backend/angel/blob/master/packages/framework/CHANGELOG.md) lists all of them.

### `chain` stops at the first handler that does not return `true`

Like the handlers of a route, each handler given to `chain` must return `true` for the next one to run. A handler that returns nothing, such as a middleware that only sets a value, now stops the chain:

```dart
// 9.x: `handler` ran after it
chain([(req, res) { req.params['user'] = 'me'; }, handler]);

// 10.0.0
chain([(req, res) { req.params['user'] = 'me'; return true; }, handler]);
```

### Buffered responses send `Content-Length`

A buffered response is sent with a `Content-Length` header instead of chunked transfer encoding. Set `res.chunked = true` to send it chunked.

### Default response headers

`AngelHttp.addResponseHeader` and `removeResponseHeader` take a `Map` of headers:

* `addResponseHeader` throws an `ArgumentError` for a header that cannot be sent, before it adds any of the call's headers.
* `removeResponseHeader` removes each value of a list, every value equal to a given one, and, if none matches exactly, those that match ignoring case, such as `sameorigin` for the `SAMEORIGIN` that `dart:io` adds. A `null` value removes the header whatever its values.

```dart
var http = AngelHttp(app);
http.removeResponseHeader({'X-FRAME-OPTIONS': 'SAMEORIGIN'});
http.removeResponseHeader({'X-XSS-PROTECTION': null});
http.addResponseHeader({'X-XSRF-TOKEN': 'a591a6d4...'});
```

### HTTP/2 sessions

An HTTP/2 request gets a session, and the session cookie, only when `req.session` is first read. Code that expects the cookie on every response must read `req.session`. See [HTTP/2](../guides/http2.md).

## Packages

Each package's `README.md` has a "Migrating from 9.x to 10.0.0" section with the changes that may need changes in an app:

| Area | Packages |
| --- | --- |
| Dependency injection | [container](https://github.com/dart-backend/angel/tree/master/packages/container/container#migrating-from-9x-to-1000), [container_generator](https://github.com/dart-backend/angel/tree/master/packages/container/container_generator#migrating-from-9x-to-1000) |
| Serialization | [serialize](https://github.com/dart-backend/angel/tree/master/packages/serialize/serialize#migrating-from-9x-to-1000), [serialize_generator](https://github.com/dart-backend/angel/tree/master/packages/serialize/serialize_generator#migrating-from-9x-to-1000), [model](https://github.com/dart-backend/angel/tree/master/packages/model#migrating-from-9x-to-1000) |
| ORM | [orm](https://github.com/dart-backend/angel/tree/master/packages/orm/orm#migrating-from-9x-to-1000), [orm_generator](https://github.com/dart-backend/angel/tree/master/packages/orm/orm_generator#migrating-from-9x-to-1000), [orm_postgres](https://github.com/dart-backend/angel/tree/master/packages/orm/orm_postgres#migrating-from-9x-to-1000), [orm_mysql](https://github.com/dart-backend/angel/tree/master/packages/orm/orm_mysql#migrating-from-9x-to-1000), [migration](https://github.com/dart-backend/angel/tree/master/packages/orm/migration#migrating-from-9x-to-1000), [migration_runner](https://github.com/dart-backend/angel/tree/master/packages/orm/migration_runner#migrating-from-9x-to-1000) |
| Databases | [mongo](https://github.com/dart-backend/angel/tree/master/packages/mongo#migrating-from-9x-to-1000), [rethinkdb](https://github.com/dart-backend/angel/tree/master/packages/rethinkdb#migrating-from-9x-to-1000), [sembast](https://github.com/dart-backend/angel/tree/master/packages/sembast#migrating-from-9x-to-1000), [file_service](https://github.com/dart-backend/angel/tree/master/packages/file_service#migrating-from-9x-to-1000), [redis](https://github.com/dart-backend/angel/tree/master/packages/redis#migrating-from-9x-to-1000) |
| Authentication and security | [auth](https://github.com/dart-backend/angel/tree/master/packages/auth#migrating-from-9x-to-1000), [auth_oauth2](https://github.com/dart-backend/angel/tree/master/packages/auth_oauth2#migrating-from-9x-to-1000), [security](https://github.com/dart-backend/angel/tree/master/packages/security#migrating-from-9x-to-1000), [cors](https://github.com/dart-backend/angel/tree/master/packages/cors#migrating-from-9x-to-1000) |
| Views | [jael](https://github.com/dart-backend/angel/tree/master/packages/jael/jael#migrating-from-9x-to-1000), [jael_preprocessor](https://github.com/dart-backend/angel/tree/master/packages/jael/jael_preprocessor#migrating-from-9x-to-1000), [angel_jael](https://github.com/dart-backend/angel/tree/master/packages/jael/angel_jael#migrating-from-9x-to-1000), [mustache](https://github.com/dart-backend/angel/tree/master/packages/mustache#migrating-from-9x-to-1000), [jinja](https://github.com/dart-backend/angel/tree/master/packages/jinja#migrating-from-9x-to-1000), [markdown](https://github.com/dart-backend/angel/tree/master/packages/markdown#migrating-from-9x-to-1000), [html](https://github.com/dart-backend/angel/tree/master/packages/html#migrating-from-9x-to-1000) |
| Clients and real time | [client](https://github.com/dart-backend/angel/tree/master/packages/client#migrating-from-9x-to-1000), [websocket](https://github.com/dart-backend/angel/tree/master/packages/websocket#migrating-from-9x-to-1000) |
| Other | [cache](https://github.com/dart-backend/angel/tree/master/packages/cache#migrating-from-9x-to-1000), [static](https://github.com/dart-backend/angel/tree/master/packages/static#migrating-from-9x-to-1000), [hot](https://github.com/dart-backend/angel/tree/master/packages/hot#migrating-from-9x-to-1000), [production](https://github.com/dart-backend/angel/tree/master/packages/production#migrating-from-9x-to-1000), [paginate](https://github.com/dart-backend/angel/tree/master/packages/paginate#migrating-from-9x-to-1000), [validate](https://github.com/dart-backend/angel/tree/master/packages/validate#migrating-from-9x-to-1000), [test](https://github.com/dart-backend/angel/tree/master/packages/test#migrating-from-9x-to-1000), [mock_request](https://github.com/dart-backend/angel/tree/master/packages/mock_request#migrating-from-9x-to-1000) |
