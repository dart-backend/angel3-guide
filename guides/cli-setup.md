# Angel3 CLI Setup

* [Getting Started](cli-setup.md#getting-started)
  * [Installation](cli-setup.md#installation)
    * [Prerequisites](cli-setup.md#prequisites)
* [Next Up...](cli-setup.md#next-up)

## Installation

* Download and install [Dart SDK](https://www.dartlang.org/downloads/).

* Install [Angel3 CLI](cli.md). The CLI includes several code generators and commands that will help Angel3 development.

```bash
  pub global activate angel3_cli
```

## Creating a New Project

* Create a sample project, called `hello`, run:

```bash
  angel3 init hello
```

This will create a folder called `hello`.

* If you prefer to initialize a project within the current directory, run:

```bash
  angel3 init
```

* Follow the instructions given to complete initializing the new project. Choose from one of the available [Angel3 templates](https://github.com/dukefirehawk/boilerplates) to best represents what you would like your backend server to do. A well structured project will be generated.

## Starting Angel3 Server

* Running the server in development mode:

```bash
  # Use the `--observe` flag to enable hot reloading in Angel3.
  dart --observe bin/dev.dart
```

* Running the server in production mode:

```bash
  dart bin/prod.dart
```

* And there you have it - you've created an Angel3 backend server!

## Next Up

Continue reading to learn about [Basic Routing](basic-routing.md).
