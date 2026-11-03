# Application Setup

The [Getting Started](getting-started.md) tutorial built a server from scratch. A real application also needs configuration, views, static files, logging and a production server. The starter templates set these up for you.

## Prerequisite

* The Dart SDK version 3.13 or later. Follow the instructions on the [official dart site](https://dart.dev/get-dart) to download and install it.
* The [Angel3 CLI](../cli/cli-setup.md):

  ```bash
  dart pub global activate angel3_cli
  ```

## Creating a project

Run:

```bash
angel3 init hello
```

and choose a template:

| Template | Description |
| --- | --- |
| Basic | A basic web application with Jael views and static files |
| ORM for PostgreSQL | The basic application, with the Angel3 ORM and migrations on PostgreSQL |
| ORM for MySQL/MariaDB | The basic application, with the Angel3 ORM and migrations on MySQL or MariaDB |
| GraphQL | A to-do list served over GraphQL, stored in PostgreSQL with the Angel3 ORM |
| MongoDB | The basic application, with a REST API of a MongoDB collection (`angel3_mongo`) |
| RethinkDB | The basic application, with a REST and WebSocket API of a RethinkDB table, which pushes its changefeed to clients (`angel3_rethinkdb`, `angel3_websocket`) |
| Sembast | The basic application, with a REST API of a store in Sembast, a database in one file that needs no server (`angel3_sembast`) |
| Kelicap | A full-stack application: an Angel3 REST API and a [Kelicap](../views/kelicap.md) web client |

For this tutorial, choose `Basic`. `angel3 init` copies the template into `hello`, names the package `hello`, generates new JWT secrets in `config/`, and runs `dart pub get`.

Instead of the CLI, you can also clone a template from the [boilerplates](https://github.com/dart-backend/boilerplates) repository, under `templates/`. Run `dart pub get` in it, and replace the `jwt_secret` values in `config/` before deploying.

## Running the server

From the project's root, start the server in development mode:

```bash
cd hello
dart --observe bin/dev.dart
```

Open <http://localhost:3000>, and you'll see the template's home page. The `--observe` flag enables hot reloading: change a file under `lib/` or `config/`, and the server reloads it without restarting.

Each template's `README.md` describes how to set up its database, if it has one.

## Next Up

Continue to [Project Layout](project-layout.md) to see what each file of the project does.
