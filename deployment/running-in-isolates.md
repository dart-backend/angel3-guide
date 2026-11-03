# How to run Angel3 in multiple isolates

A Dart isolate runs on one CPU core. To use more of them, run the server in several isolates, which share one port.

## With `angel3_production`

The `Runner` of [`angel3_production`](https://github.com/dart-backend/angel/tree/master/packages/production), which the starter templates use in `bin/prod.dart`, does this for you. Pass the number of isolates with `-j`:

```bash
dart bin/prod.dart -j 4
```

It also re-spawns isolates that crash, and handles shutdown. `dart bin/prod.dart --help` lists its options.

Each isolate has its own memory, so data kept in memory, such as in a `MapService`, is not shared between them. Keep shared data in a database, and use [`angel3_sync`](https://github.com/dart-backend/angel/tree/master/packages/sync) to share WebSocket events between isolates.

## By hand

To bind several servers to one port, start each with `startShared`, which passes `shared: true` to `HttpServer.bind`:

```dart
var http = AngelHttp.custom(app, startShared);
```

`startSharedSecure(securityContext)` does the same for HTTPS.

Then start a server in each isolate:

```dart
import 'dart:io';
import 'dart:isolate';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_framework/http.dart';

void main() async {
  var concurrency = Platform.numberOfProcessors;

  // Start child isolates...
  for (var i = 1; i < concurrency; i++) {
    await Isolate.spawn(serverMain, i);
  }

  // ...and a server in the main isolate.
  await serverMain(0);
}

Future<void> serverMain(int id) async {
  var app = Angel();
  var http = AngelHttp.custom(app, startShared);

  app.get('/json', (req, res) => {'hello': 'world'});

  var server = await http.startServer(InternetAddress.anyIPv4, 3000);
  print('Instance #$id listening at http://${server.address.address}:${server.port}');
}
```
