# PostgreSQL Support

PostgreSQL 16 or later is supported by way of `package:angel3_orm_postgres`, which uses version 3 of [`package:postgres`](https://pub.dev/packages/postgres). The `PostgreSqlExecutor` implements `QueryExecutor`, and takes care of running prepared queries, and passing values to the database server.

```yaml
dependencies:
  angel3_orm_postgres: ^10.0.0
  postgres: ^3.5.20
```

The [PostgreSQL ORM template](https://github.com/dart-backend/boilerplates/tree/master/templates/basic_postgres_orm) includes helpers like this to load app configuration into a database connection:

```dart
import 'dart:async';
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:angel3_orm_postgres/angel3_orm_postgres.dart';
import 'package:postgres/postgres.dart';

Future<void> configureServer(Angel app) async {
  try {
    var connection = await connectToPostgres(app.configuration);

    // Given the endpoint and settings, the executor opens a new connection
    // when this one breaks, as when the database restarts.
    var executor = PostgreSqlExecutor(
      connection,
      endpoint: postgresEndpoint(app.configuration),
      settings: postgresSettings(app.configuration),
      logger: app.logger,
    );

    // The executor closes the connection it uses, which may be a new one.
    app
      ..container.registerSingleton<QueryExecutor>(executor)
      ..shutdownHooks.add((_) => executor.close());
  } catch (e) {
    app.logger.severe("Failed to connect to PostgreSQL. ORM disabled.", e);
  }
}

// PostgreSQL connection, of the `postgres` section of the configuration.
Future<Connection> connectToPostgres(Map configuration) => Connection.open(
  postgresEndpoint(configuration),
  settings: postgresSettings(configuration),
);

// The PostgreSQL server, of the `postgres` section of the configuration. The
// POSTGRES_HOST, POSTGRES_USERNAME and POSTGRES_PASSWORD environment variables
// override its `host`, `username` and `password`, as in a container, so they
// need not be kept in a file.
Endpoint postgresEndpoint(Map configuration) {
  var postgresConfig = configuration['postgres'] as Map? ?? {};
  return Endpoint(
    host:
        Platform.environment['POSTGRES_HOST'] ??
        postgresConfig['host'] as String? ??
        'localhost',
    port: postgresConfig['port'] as int? ?? 5432,
    database:
        postgresConfig['database_name'] as String? ??
        Platform.environment['USER'] ??
        Platform.environment['USERNAME'] ??
        '',
    username:
        Platform.environment['POSTGRES_USERNAME'] ??
        postgresConfig['username'] as String?,
    password:
        Platform.environment['POSTGRES_PASSWORD'] ??
        postgresConfig['password'] as String?,
  );
}

// The settings of a connection, of the `postgres` section of the
// configuration.
ConnectionSettings postgresSettings(Map configuration) {
  var postgresConfig = configuration['postgres'] as Map? ?? {};
  var useSsl = postgresConfig['use_ssl'] as bool? ?? false;
  return ConnectionSettings(
    sslMode: useSsl ? SslMode.require : SslMode.disable,
    timeZone: postgresConfig['time_zone'] as String? ?? 'UTC',
    connectTimeout: Duration(
      seconds: postgresConfig['timeout_in_seconds'] as int? ?? 30,
    ),
  );
}
```

Typically, you'll want to use app configuration to create the connection, rather than hard coding values. The template also lets the `POSTGRES_HOST`, `POSTGRES_USERNAME` and `POSTGRES_PASSWORD` environment variables override the configuration, as in a container, so they need not be kept in a file.

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
