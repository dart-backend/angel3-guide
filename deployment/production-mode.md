# Production Mode

Angel3 can optionally run in "production mode," where several optimizations are applied to the base server, such as running reflective dependency injection before server startup, flattening the server's route tree, and caching the resolved routes of request paths, up to `app.maxHandlerCacheSize` entries.

Production mode is considered a global setting.

`angel3_configuration` will load a `config/production.yaml` file to read configuration.

To run your application in production mode, set `ANGEL_ENV` in your environment to `production`. If you are writing a plug-in with production mode-specific code, query its value as follows:

```dart
if (app.environment.isProduction) {
  // Do some production-only stuff...
}
```

To run the application in several isolates, with respawning and graceful shutdown, use [`angel3_production`](https://pub.dev/packages/angel3_production); see [Running in Isolates](running-in-isolates.md).
