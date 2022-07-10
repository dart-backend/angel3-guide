# Angel3 Command Line Interface (CLI)

Installing `angel3_cli` installs a command line dart application in your local environment. Executed from the terminal, it provides access to a set of useful commands for working with [Angel3](https://pub.dev/packages/angel3_framework). The `--help` option gives more information about the available options.

## Installation

* Prerequisite: [Dart SDK](https://www.dartlang.org/downloads/) must be installed

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

* Follows the instructions given to complete setting up the new project. Choose from one of the available [Angel3 templates](https://github.com/dukefirehawk/boilerplates) to best represents what you would like your backend server to do. A well structured project will be generated and ready for development.

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
