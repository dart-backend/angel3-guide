# Sembast

[Sembast](https://pub.dev/packages/sembast) is a NoSQL database that runs in the server, and keeps its data in one file: there is no database server to install. [`angel3_sembast`](https://github.com/dart-backend/angel/tree/master/packages/sembast) serves a store of it as a [service](../guides/service-basics.md).

```yaml
dependencies:
  angel3_sembast: ^10.0.0
  sembast: ^3.1.1
```

The `Sembast` [starter template](../tutorial/application-setup.md) is set up with it.

## Usage

Open the database, and mount a `SembastService` of one of its stores:

```dart
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_sembast/angel3_sembast.dart';
import 'package:sembast/sembast_io.dart';

Future configureServer(Angel app) async {
  var db = await databaseFactoryIo.openDatabase('todos.db');

  app
    ..use('/api/todos', SembastService(db, store: 'todos'))
    ..shutdownHooks.add((_) => db.close());
}
```

The `id` of a record is its key in the store.

## Querying

Query a service with the query string:

```bash
curl 'http://localhost:3000/api/todos?title=Clean'
```

A record must match every field of the query, and `id` matches the key of the record. Values of the query string are strings, so they only match string fields; query other types from Dart.

Sort with `$sort`: a field name sorts by it in ascending order, and a map of field names to `1` (ascending) or `-1` (descending) sorts by each of them:

```dart
await service.index({
  'query': {r'$sort': {'title': -1}},
});
```

You can also pass a Sembast `Finder` as `query`:

```dart
var queried = await service.index({
  'query': Finder(filter: Filter.equals('completed', false)),
});
```

To map records to your own model classes, see [NoSQL](nosql.md).
