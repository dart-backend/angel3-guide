# How to run Angel3 in multiple isolates

The easiest way is [`angel3_production`](https://pub.dev/packages/angel3_production). Its `Runner` starts your application in an isolate per processor, respawns those that crash, and shuts them down gracefully on `SIGINT` or `SIGTERM`:

```dart
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_production/angel3_production.dart';

void main(List<String> args) => Runner('example', configureServer).run(args);

Future<void> configureServer(Angel app) async {
  app.get('/', (req, res) => 'Hello, production world!');
}
```

Run the file with `--help` to see its options, such as the number of isolates (`-j`) and the port (`-p`).

## Doing it Yourself

The concept is pretty simple. A normal server would look like this:

```dart
var app = Angel();
var http = AngelHttp(app);
```

If you use the `AngelHttp.custom` constructor, you can provide a custom server generator, a function that binds an HTTP server:

```dart
Future<HttpServer> Function(dynamic address, int port)
```

With this in mind, you can start a server passing the `shared` argument to `HttpServer.bind`:

```dart
AngelHttp.custom(app, (address, port) => HttpServer.bind(address, port, shared: true));
```

`startShared` is a function that accomplishes this for you, since it's commonly-used functionality:

```dart
AngelHttp.custom(app, startShared);
```

To run in multiple isolates, the concept is simple as well:

```dart
import 'dart:io';
import 'dart:isolate';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_framework/http.dart';

void main(List<String> args) async {
  var concurrency = Platform.numberOfProcessors;

  // Start child isolates...
  for (var i = 1; i < concurrency; i++) {
    await Isolate.spawn(serverMain, i);
  }

  // Spawn a server in the main isolate.
  await serverMain(concurrency);
}

Future<void> serverMain(int id) async {
  // Start shared!!!
  var app = Angel();
  var http = AngelHttp.custom(app, startShared);

  app.get('/json', (req, res) => {'hello': 'world'});

  var server = await http.startServer(InternetAddress.anyIPv4, 3000);
  print('Instance #$id listening at http://${server.address.address}:${server.port}');
}
```
