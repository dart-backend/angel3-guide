# Angel3 Command Line Interface (CLI)

Installing `angel3_cli` installs a command line dart application in your local environment. Executed from the terminal, it provides access to a set of useful commands for working with [Angel3](https://pub.dev/packages/angel3_framework). The `--help` option gives more information about the available options.

## Installation

* Prerequisite: [Dart SDK](https://dart.dev/get-dart) 3.13 or later must be installed

* Open a terminal screen and run the following command.

  ```bash
    dart pub global activate angel3_cli
  ```

### Creating a New Project

* Creating a new project, `hello`, in the current directory, run:

  ```bash
    angel3 init hello
  ```

* Initializing a project within a directory, `hello`, run:

  ```bash
    angel3 init
  ```

* Follow the instructions given to complete setting up the new project. Choose the one of the available [Angel3 templates](https://github.com/dart-backend/boilerplates) that best represents what you would like your backend server to do. A well structured project will be generated and ready for development:

  * **Basic**: a basic starter application
  * **ORM for PostgreSQL**: a starter application with the ORM and PostgreSQL
  * **ORM for MySQL/MariaDB**: a starter application with the ORM and MySQL or MariaDB
  * **GraphQL**: a starter application with GraphQL

* At the time of writing, the templates use Angel3 9.x packages. To use 10.0.0, change their constraints to `^10.0.0`, run `dart pub upgrade`, and follow the [10.0.0 Migration Guide](../migration/migration-guide-10.md).

### Starting Backend Server

* Running the server in development mode:

  ```bash
    # Use the `--observe` flag to enable hot reloading in Angel3.
    dart --observe bin/dev.dart
  ```

* Running the server in production mode:

  ```bash
    dart bin/prod.dart
  ```
