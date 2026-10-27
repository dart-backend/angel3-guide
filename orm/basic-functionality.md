# Basic ORM

Before starting with the ORM, it is highly recommended to familiarize oneself with `package:angel3_serialize`, as it is the foundation for `package:angel3_orm`. See [Serialization](../guides/serialization.md).

Add the ORM, its generator, and the package of your database to your `pubspec.yaml`:

```yaml
dependencies:
  angel3_orm: ^10.0.0
  angel3_orm_postgres: ^10.0.0 # or angel3_orm_mysql for MySQL and MariaDB
  angel3_migration: ^10.0.0
  angel3_serialize: ^10.0.0
dev_dependencies:
  angel3_orm_generator: ^10.0.0
  build_runner: ^2.6.0
```

To enable the ORM for a given model, simply add the `@orm` annotation to its definition. The name of the model ends with `Entity`, which the generated classes are named without:

```dart
import 'package:angel3_migration/angel3_migration.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:angel3_serialize/angel3_serialize.dart';
import 'package:optional/optional.dart';

part 'todo.g.dart';

@serializable
@orm
abstract class TodoEntity extends Model {
    bool? get isComplete;

    String? get text;

    @Column(type: ColumnType.bigInt)
    int? get score;
}
```

Then run `dart run build_runner build`. The generator will produce a `Todo` model, a `TodoMigration`, and a `TodoQuery` class, which contains fields corresponding to each field declared in `TodoEntity`. Each of `TodoQuery`'s fields is a subclass of `SqlExpressionBuilder`, corresponding to the given type. For example, `TodoQuery` would look *something* like:

```dart
class TodoQuery extends Query<Todo, TodoQueryWhere> {
    TodoQueryWhere? get where;

    TodoQueryValues get values;
}

class TodoQueryWhere extends QueryWhere {
    BooleanSqlExpressionBuilder get isComplete;

    StringSqlExpressionBuilder get text;

    NumericSqlExpressionBuilder<int> get score;
}
```

Thus, you can query the database using plain-old-Dart-objects (*PODO's*):

```dart
Future<List<Todo>> leftToDo(QueryExecutor executor) async {
    var query = TodoQuery()..where!.isComplete.isFalse;
    return await query.get(executor);
}

Future<void> markAsComplete(Todo todo, QueryExecutor executor) async {
    var query = TodoQuery()
        ..where!.id.equals(todo.idAsInt)
        ..values.isComplete = true;

    await query.updateOne(executor);
}
```

`get` returns a `List`, and `getOne`, `insert`, `updateOne` and `deleteOne` return an `Optional` of a record, from `package:optional`.

The glue holding everything together is the `QueryExecutor` interface. To support the ORM for any arbitrary database, simply extend the class and implement its abstract methods. `QueryExecutor.transaction` runs queries in a transaction, which is rolled back if its callback throws:

```dart
var todo = await executor.transaction((tx) async {
    var query = TodoQuery()..values.text = 'Clean your room';
    return (await query.insert(tx)).value;
});
```

Consumers of a `QueryExecutor` typically inject it into the app's [dependency injection](../guides/dependency-injection.md) container:

```dart
app.container.registerSingleton<QueryExecutor>(PostgreSqlExecutor(connection));
```

The ORM supports PostgreSQL, through [`angel3_orm_postgres`](postgresql.md), and MySQL and MariaDB, through [`angel3_orm_mysql`](mysql.md).
