# Minimal Setup

It's very easy to setup a bare-bones Angel server.

Any Dart project needs a project file, called `pubspec.yaml`. This file almost always contains a `dependencies` section, where you will install the Angel framework libraries.

```yaml
dependencies:
    angel3_framework: ^4.0.0
```

You might also want to install packages such as `angel3_static`, `angel3_cache`, `angel3_jael`, and `angel3_cors`.

Next, run `pub get` on the command line, or in your IDE if it has Dart support. This will install the framework and all of its dependencies.

Next, create a file, `bin/main.dart`. Put this code in it:

```dart
import 'dart:io';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_framework/http.dart';

void main() async {
  var app = Angel();
  var http = AngelHttp(app);

  app.get("/", (req, res) => "Hello, world!");

  var server = await http.startServer();
  print("Angel server listening at ${http.uri}");
}
```

The specifics are not that important, but there are a few important calls here:

* `var app = Angel()` - The base Angel server is a simple class, and we need an instance of it to run our server. The name `app` is a convention adopted from Express. In general, call an Angel instance `app`. This has no effect on functionality, but it makes it easier for other developers to understand your code.
* `app.get("/", (req, res) => "Hello, world!");` - This is a [route](basic-routing.md), and tells our server to respond to all GET requests at our server root with `"Hello, world!"`. The response will automatically be encoded as JSON. Head over to the [Basic Routing](basic-routing.md) tutorial to learn about routes, and how they work.
3. `await http.startServer(...)` - This asynchronous call is what actually starts the server listening. Without it, your application won't be accessible over HTTP \(as it won't ever listen for requests\).

That's it! Your server is ready to serve requests. You can easily start it from the command line like this:

```text
dart bin/main.dart
```

## Next Up...

Continue reading to learn about [Basic Routing](basic-routing.md).



