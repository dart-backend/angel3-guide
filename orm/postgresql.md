# PostgreSQL Support

PostgreSQL 14 or later is supported by way of `package:angel3_orm_postgres`, which uses version 3 of [`package:postgres`](https://pub.dev/packages/postgres). The `PostgreSqlExecutor` implements `QueryExecutor`, and takes care of running prepared queries, and passing values to the database server.

```yaml
dependencies:
  angel3_orm_postgres: ^10.0.0
```

`angel3 init` projects using the ORM include helpers like this to load app configuration into a database connection:

```dart
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:angel3_orm_postgres/angel3_orm_postgres.dart';
import 'package:postgres/postgres.dart';

Future<void> configureServer(Angel app) async {
  var connection = await connectToPostgres(app.configuration);

  app
    ..container.registerSingleton<QueryExecutor>(
        PostgreSqlExecutor(connection, logger: app.logger))
    ..shutdownHooks.add((_) => connection.close());
}

Future<Connection> connectToPostgres(Map configuration) async {
  var postgresConfig = configuration['postgres'] as Map? ?? {};
  var useSsl = postgresConfig['use_ssl'] as bool? ?? false;

  return await Connection.open(
    Endpoint(
      host: postgresConfig['host'] as String? ?? 'localhost',
      port: postgresConfig['port'] as int? ?? 5432,
      database: postgresConfig['database_name'] as String? ??
          Platform.environment['USER'] ??
          Platform.environment['USERNAME'] ??
          '',
      username: postgresConfig['username'] as String?,
      password: postgresConfig['password'] as String?,
    ),
    settings: ConnectionSettings(
      sslMode: useSsl ? SslMode.require : SslMode.disable,
      timeZone: postgresConfig['time_zone'] as String? ?? 'UTC',
      connectTimeout:
          Duration(seconds: postgresConfig['timeout_in_seconds'] as int? ?? 30),
    ),
  );
}
```

Typically, you'll want to use app configuration to create the connection, rather than hard coding values.

## Connection Pools

To run queries on several connections, give a `Pool` of `package:postgres` to a `PostgreSqlPoolExecutor`:

```dart
var pool = Pool.withEndpoints(
  [Endpoint(host: 'localhost', database: 'demo', username: 'demouser', password: 'demo123')],
  settings: PoolSettings(maxConnectionCount: 10, sslMode: SslMode.disable),
);
var executor = PostgreSqlPoolExecutor(pool);
```

## Transactions

`transaction` runs its callback in a transaction, which is committed if the callback completes, and rolled back if it throws. Use the executor given to the callback:

```dart
var car = await executor.transaction((tx) async {
  var query = CarQuery()..values.make = 'Ferrari';
  return (await query.insert(tx)).value;
});
```

PostgreSQL does not nest transactions, so `transaction` on the executor the callback is given runs in a savepoint instead. What it does is rolled back if it throws, even when the outer callback catches the error, and committed with the outer transaction otherwise:

```dart
await executor.transaction((tx) async {
  await insertOrder(tx);
  try {
    await tx.transaction((inner) => sendInvoice(inner));
  } on InvoiceException {
    // Only the savepoint is rolled back; the order is kept.
  }
});
```

See the [README of `angel3_orm_postgres`](https://pub.dev/packages/angel3_orm_postgres) for more.
