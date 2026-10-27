# MySQL and MariaDB Support

MySQL 8 or later, and MariaDB 10.2 or later, are supported by way of `package:angel3_orm_mysql`, which uses the [`mysql_dart`](https://pub.dev/packages/mysql_dart) driver. It provides two executors, which implement `QueryExecutor`:

* `MySqlExecutor`, for MySQL, which stores a `DateTime` as local time.
* `MariaDbExecutor`, for MariaDB, which stores a `DateTime` as UTC.

```yaml
dependencies:
  angel3_orm_mysql: ^10.0.0
  mysql_dart: ^3.0.3
```

```dart
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:angel3_orm_mysql/angel3_orm_mysql.dart';
import 'package:mysql_dart/mysql_dart.dart';

Future<void> configureServer(Angel app) async {
  var connection = await MySQLConnection.createConnection(
    host: 'localhost',
    port: 3306,
    databaseName: 'orm_test',
    userName: 'test',
    password: 'test123',
    secure: true,
  );
  await connection.connect(timeoutMs: 10000);

  app
    ..container.registerSingleton<QueryExecutor>(
        MySqlExecutor(connection, logger: app.logger))
    ..shutdownHooks.add((_) => connection.close());
}
```

For MariaDB, use `MariaDbExecutor(connection)` instead. Run the migrations with `MySqlMigrationRunner` or `MariaDbMigrationRunner` of `package:angel3_migration_runner`; see [Migrations](migrations.md).

## Transactions

`transaction` runs its callback in a transaction, which is committed if the callback completes, and rolled back if it throws. The queries of a connection run one at a time, and a transaction holds the connection until it ends, so use the executor given to the callback, and await its queries. MySQL and MariaDB do not nest transactions.

```dart
var car = await executor.transaction((tx) async {
  var query = CarQuery()..values.make = 'Ferrari';
  return (await query.insert(tx)).value;
});
```

## Known Limitations

* `Blob` data type mapping is not supported.
* A `timestamp` column is read and written as a `datetime` one is, and the migration runner creates `timeStamp` columns as `datetime`.
* A `datetime` column has no time zone, so use one executor for a database, or run the application at UTC. Give the date of a `date` column as a `DateTime` of the time zone of the executor: UTC for `MariaDbExecutor`, and local time for `MySqlExecutor`.

See the [README of `angel3_orm_mysql`](https://pub.dev/packages/angel3_orm_mysql) for more.
