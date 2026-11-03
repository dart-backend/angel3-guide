# Full-stack with Kelicap

[Kelicap](https://github.com/dukefirehawk/kelicap) is a Dart web framework derived from AngularDart, which compiles to HTML and JavaScript. With Kelicap for the web client and Angel3 for the server, both are written in Dart, and share the same model classes.

The client calls the server's services with [`angel3_client`](https://pub.dev/packages/angel3_client), whose `browser.dart` compiles to JavaScript with `dart2js`.

## Starting a project

Create a project from the [Kelicap template](https://github.com/dart-backend/boilerplates/tree/master/templates/basic_kelicap), with the [CLI](../cli/cli-setup.md):

```bash
angel3 init my_app
```

and choose `Kelicap`. The project is a [pub workspace](https://dart.dev/tools/pub/workspaces) of three packages:

| Directory | What it is |
| --- | --- |
| `.` | The Angel3 server: the API under `/api`, which also serves the client |
| `shared/` | The models of both, made with `angel3_serialize` |
| `client/` | The Kelicap client: its pages, routes and services |

The server and the client have one origin, the server's. In development, the server forwards the pages to the client's `build_runner serve`; in production, it serves the client as built. So the client needs no CORS, and cookies work.

## Development

1. In `client/`, build the client, and rebuild it as its files change, on port 8080:

    ```bash
    cd client
    dart run build_runner serve web:8080
    ```

2. In another terminal, from the project's root, start the server, hot-reloaded on file changes:

    ```bash
    dart --observe bin/dev.dart
    ```

3. Open <http://localhost:3000>, the server's port, not the client's.

## Production

Build the client, optimized, into `client/build`, then run the server, which serves it:

```bash
cd client
dart run build_runner build --release -o web:build
cd ..
ANGEL_ENV=production dart bin/prod.dart
```

The template's `Containerfile` builds the client and the server together, to run them with [Podman](../deployment/podman.md).

## Calling the server

The client reaches a service of the server through `angel3_client`:

```dart
import 'package:angel3_client/browser.dart';
import 'package:shared/shared.dart';

Angel app = Rest(window.location.origin);

// The service, whose methods take and give the `Greeting` of shared/.
var greetings = app.service<String, Greeting>(
  'api/greetings',
  deserializer: (map) => GreetingSerializer.fromMap(map as Map),
);

await greetings.index();                              // GET    /api/greetings
await greetings.create(Greeting(message: 'Hi'));      // POST   /api/greetings
await greetings.remove(id);                           // DELETE /api/greetings/:id
```

An error of the server is thrown as an `AngelHttpException`, with its status code and message. `app.authenticate(...)` logs in with `angel3_auth`, after which the client sends its token with each request. A `ServiceList` keeps a list of a service's records, which updates itself as the service is called.

For live updates, use the WebSocket client of [`angel3_websocket`](https://pub.dev/packages/angel3_websocket), whose services work the same way.

## Sharing models

Keep the models in `shared/`, and generate their serializers there with `dart run build_runner build`. `shared/` is compiled to JavaScript for the client, so keep `dart:io`, `angel3_framework` and other server packages out of it. ORM models, annotated with `@orm`, belong to the server.

See the [Kelicap documentation](https://github.com/dukefirehawk/kelicap-docs) for the client side.
