# Configure ORM

The [Angel3 ORM](../orm/about.md) stores your models in PostgreSQL, MySQL or MariaDB, with queries generated from the model classes. This tutorial uses the `ORM for PostgreSQL` template, which is the `Basic` template with the ORM set up.

## Creating the project

```bash
angel3 init hello_orm
```

and choose `ORM for PostgreSQL`. The template includes a `Greeting` model, in `lib/src/models/greeting.dart`, with a `message`, and `GET` and `POST` routes for `/greetings`.

## Setting up the database

1. Install PostgreSQL 16 or later.

2. Create a user, and a database that it owns, with `psql`:

   ```sql
   postgres=# create user appuser with encrypted password 'App1970#';
   postgres=# create database appdb owner appuser;
   ```

   The user must own the database to create the tables of the migrations: since PostgreSQL 15, only the owner of a database can create tables in its `public` schema.

3. Set them in the `postgres` section of `config/default.yaml`:

   ```yaml
   postgres:
     host: localhost
     port: 5432
     database_name: appdb
     username: appuser
     password: App1970#
     use_ssl: false
     time_zone: UTC
   ```

   The `POSTGRES_HOST`, `POSTGRES_USERNAME` and `POSTGRES_PASSWORD` environment variables, if set, override `host`, `username` and `password`, so they need not be kept in a file.

4. Create the tables, with the migrations:

   ```bash
   dart bin/migrate.dart up
   ```

   This creates the `greetings` table, and a `migrations` table that records which migrations have run. `rollback` undoes the last batch, `reset` undoes all of them, and `refresh` resets and runs them again. See [Migrations](../orm/migrations.md).

## Trying it out

Start the server with `dart --observe bin/dev.dart`, and add a greeting:

```bash
curl -H "Content-Type: application/json" -X POST -d '{"message":"Hello"}' http://localhost:3000/greetings
```

Then list them:

```bash
curl http://localhost:3000/greetings
```

## How it fits together

* **`lib/src/config/plugins/orm.dart`** connects to PostgreSQL with the configuration, and registers a `PostgreSqlExecutor` in the app's container as the `QueryExecutor`. See [PostgreSQL](../orm/postgresql.md).
* **`bin/migrate.dart`** runs the migrations with a `PostgresMigrationRunner`.
* **`lib/src/routes/routes.dart`** reads the `QueryExecutor` from the container, and queries the greetings with `GreetingQuery`:

  ```dart
  app.get('/greetings', (req, res) {
    var executor = req.container!.make<QueryExecutor>();
    return GreetingQuery().get(executor);
  });
  ```

## Adding a model

1. Create the model, such as `lib/src/models/todo.dart`. Its class name ends with `Entity`, and the generated class takes the name without it:

   ```dart
   import 'package:angel3_migration/angel3_migration.dart';
   import 'package:angel3_orm/angel3_orm.dart';
   import 'package:angel3_serialize/angel3_serialize.dart';
   import 'package:optional/optional.dart';

   part 'todo.g.dart';

   @serializable
   @orm
   abstract class TodoEntity extends Model {
     String? get text;

     bool? get completed;
   }
   ```

   Export it from `lib/models.dart`.

2. Generate its code:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

   This generates `Todo`, its serializer, `TodoQuery`, and `TodoMigration`. See [Serialization](../guides/serialization.md) and [Basic Functionality](../orm/basic-functionality.md).

3. Add `TodoMigration()` to the `migrations` of `bin/migrate.dart`, and run `dart bin/migrate.dart up`.

4. Query it in your routes or services:

   ```dart
   var query = TodoQuery()..where!.completed.isFalse;
   List<Todo> todos = await query.get(executor);
   ```

   [`angel3_orm_service`](https://github.com/dart-backend/angel/tree/master/packages/orm/orm_service) can also serve a model as a REST [service](../guides/service-basics.md).

For MySQL or MariaDB, choose the `ORM for MySQL/MariaDB` template instead, whose `README.md` describes its setup.

## Next Up

Continue to [Deploy to Production](deploy-production.md).
