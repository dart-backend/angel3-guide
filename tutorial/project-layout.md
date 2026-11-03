# Project Layout

A project created from the `Basic` template looks like this:

```bash
hello
├── bin
│   ├── dev.dart          # Development server, with hot reloading
│   └── prod.dart         # Production server
├── config
│   ├── default.yaml      # Configuration of every environment
│   ├── development.yaml  # Overrides for development
│   └── production.yaml   # Overrides for production
├── lib
│   ├── hello.dart        # configureServer: sets up the app
│   └── src
│       ├── config
│       │   ├── config.dart          # Loads configuration and the view engine
│       │   └── plugins
│       │       └── plugins.dart     # Your own plug-ins
│       ├── routes
│       │   ├── routes.dart          # Routes, static files and error handling
│       │   └── controllers
│       │       └── controllers.dart # Controllers
│       └── services
│           └── services.dart        # Services
├── test
│   └── all_test.dart     # Tests, with angel3_test
├── views                 # Jael templates
│   ├── error.jael
│   ├── hello.jael
│   └── layout.jael
├── web                   # Static files: stylesheets, images
├── Containerfile         # Container image, for Podman
├── contrib/deployment    # Podman Compose file
└── pubspec.yaml
```

## Entry points

`bin/dev.dart` and `bin/prod.dart` both create an `Angel` app, and configure it with the `configureServer` function of `lib/hello.dart`:

* `bin/dev.dart` runs it with a `HotReloader` of [`angel3_hot`](https://github.com/dart-backend/angel/tree/master/packages/hot), which reloads the app when the files of `lib/` or `config/` change. Run it with `dart --observe bin/dev.dart`.
* `bin/prod.dart` runs it with the `Runner` of [`angel3_production`](https://github.com/dart-backend/angel/tree/master/packages/production), which can run several isolates, and re-spawns crashed ones. See [Deploy to Production](deploy-production.md).

## Configuring the app

`lib/hello.dart` applies three plug-ins in order:

```dart
Future configureServer(Angel app) async {
  var fs = const LocalFileSystem();

  await app.configure(configuration.configureServer(fs));
  await app.configure(services.configureServer);
  await app.configure(routes.configureServer(fs));
}
```

A plug-in is a function that takes the `Angel` app, and adds to it. See [Using Plug-ins](../guides/using-plug-ins.md).

* **`src/config/config.dart`** loads the files of `config/` with [`angel3_configuration`](https://github.com/dart-backend/angel/tree/master/packages/configuration), sets up Jael for `views/`, and applies the plug-ins of `src/config/plugins/plugins.dart`, where your own go.
* **`src/services/services.dart`** mounts [services](../guides/service-basics.md), with `app.use`.
* **`src/routes/routes.dart`** mounts the [controllers](../guides/controllers.md) of `controllers/controllers.dart`, adds routes, serves the files of `web/`, and renders an error page for errors in HTML requests.

## Configuration

`config/default.yaml` holds the configuration of every environment. The `ANGEL_ENV` environment variable selects the environment: `development` unless it is set, or `production`. The file of the environment, such as `config/production.yaml`, is loaded over the default one, and overrides its values. A `config/.env` file, if present, sets environment variables first.

The configuration is a `Map`, as `app.configuration`:

```dart
var port = app.configuration['port'] as int? ?? 3000;
```

## Next Up

Continue to [Templates and Views](templates-views.md) to render pages of your own.
