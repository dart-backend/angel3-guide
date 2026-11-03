# PostgreSQL Support

PostgreSQL support is provided by way of `package:angel3_orm_postgres`, for PostgreSQL 14 or later. The `PostgreSqlExecutor` implements `QueryExecutor`, and takes care of
running prepared queries, and passing values to the database server. It uses a `Connection` of `package:postgres` 3.x. To share a pool of connections, use `PostgreSqlPoolExecutor` with a `Pool` instead.

The [PostgreSQL ORM template](https://github.com/dart-backend/boilerplates/tree/master/templates/basic_postgres_orm) includes helpers like this to load app configuration into a database connection:

```dart
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:angel3_orm_postgres/angel3_orm_postgres.dart';
import 'package:postgres/postgres.dart';

Future<void> configureServer(Angel app) async {
  var connection = await Connection.open(
    postgresEndpoint(app.configuration),
    settings: postgresSettings(app.configuration),
  );

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
}

Endpoint postgresEndpoint(Map configuration) {
  var postgresConfig = configuration['postgres'] as Map? ?? {};
  return Endpoint(
    host: postgresConfig['host'] as String? ?? 'localhost',
    port: postgresConfig['port'] as int? ?? 5432,
    database: postgresConfig['database_name'] as String? ??
        Platform.environment['USER'] ??
        Platform.environment['USERNAME'] ??
        '',
    username: postgresConfig['username'] as String?,
    password: postgresConfig['password'] as String?,
  );
}

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

Typically, you'll want to use app configuration to create the connection, rather than hard coding values. The template also lets the `POSTGRES_HOST`, `POSTGRES_USERNAME` and `POSTGRES_PASSWORD` environment variables override the configuration, as in a container.

## MySQL and MariaDB

MySQL 8 or later and MariaDB 10.2 or later are supported by `package:angel3_orm_mysql`, on the [`mysql_dart`](https://pub.dev/packages/mysql_dart) driver. See its [README](https://pub.dev/packages/angel3_orm_mysql) for its executors.
