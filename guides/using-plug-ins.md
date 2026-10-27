# Developer Guide

* [Using Plug-ins](using-plug-ins.md#using-plug-ins)
  * [Execution Order](using-plug-ins.md#execution-order)
  * [Writing a Plug-in](writing-a-plugin.md)
* [Next Up...](using-plug-ins.md#next-up)

## Using Plug-ins

Angel3 is designed to be extensible. As such, it exposes a typedef, `AngelConfigurer`, that has special privileges within the framework - they act as plug-ins and can be called via `app.configure()`.

Plug-ins simply need to accept an `Angel` instance as a parameter, and may return a `Future` \(the result of which will be ignored, unless it throws an error\). `Angel` instances have several facilities available to be customized, and thus it is easy to use a custom plug-in to bring about desired functionality within your application.

```dart
typedef AngelConfigurer = FutureOr<void> Function(Angel app);
```

As a convention, Angel3 plug-ins should be hooked up **before** the call to `startServer`.

```dart
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_framework/http.dart';

Future<void> plugin(Angel app) async {
  print('Do stuff here');
}

void main() async {
  var app = Angel();
  await app.configure(plugin);
  await AngelHttp(app).startServer('localhost', 3000);
}
```

### Execution Order

Plugins are usually immediately invoked by `app.configure()`. However, you may run into certain plug-ins that depend on other facilities already being available, or all of your [services](service-basics.md) already being mounted. You can set aside a plug-in to be run just before server startup by adding it to `app.startupHooks`, instead of directly calling `app.configure()`.

```dart
app.startupHooks.addAll([
  myPlugin(),
  AngelWebSocket(app).configureServer,
  fooBarBazQuux(),
]);
```

Likewise, you can add hooks that run when the app is shut down, via `Angel.shutdownHooks`. They run once, after the requests in progress have finished, and before the services are closed.

## Next Up

Learn how to generate content for clients by [rendering views](../views/rendering-views.md).
