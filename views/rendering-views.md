# Server Side Rendered Views

* [Rendering Views](rendering-views.md#rendering-views)
  * [Example](rendering-views.md#example)
  * [`ViewGenerator` typedef](rendering-views.md#viewgenerator)

## Rendering Views

Just like `res.render` in Express, Angel3's `ResponseContext` exposes a `Future` called `render`. This invokes whichever function is assigned to your server's `viewGenerator`.

The following template engines have Angel3 plug-ins:

* [Jael](jael/about.md), one of the few actively-developed HTML templating engines for Dart. Angel3 support for Jael is provided through [`package:angel3_jael`](https://pub.dev/packages/angel3_jael).
* Mustache, through [`package:angel3_mustache`](https://pub.dev/packages/angel3_mustache).
* Jinja, ported to Dart by [Olzhas Suleimen](https://github.com/ykmnkmi/jinja.dart), through [`package:angel3_jinja`](https://pub.dev/packages/angel3_jinja).
* Markdown, through [`package:angel3_markdown`](https://pub.dev/packages/angel3_markdown).
* HTML built in Dart with `belatuk_html_builder`, through [`package:angel3_html`](https://pub.dev/packages/angel3_html).

### Example

```dart
app.get('/view', (req, res) => res.render('hello', {'locals': ['foo', 'bar']}));
```

With Jael, for example:

```dart
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_jael/angel3_jael.dart';
import 'package:file/local.dart';

Future<void> configureServer(Angel app) async {
  var fileSystem = const LocalFileSystem();
  await app.configure(jael(fileSystem.directory('views')));
}
```

### ViewGenerator

Angel3 declares the following typedef:

```dart
/// A function that asynchronously generates a view from the given path and data.
typedef ViewGenerator = FutureOr<String> Function(String path, [Map<String, dynamic>? data]);
```

A templating plug-in can assign one of these to `app.viewGenerator` to set itself up:

```dart
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_framework/http.dart';

Future<void> plugin(Angel app) async {
  app.viewGenerator = (String path, [Map<String, dynamic>? data]) async {
    return 'Requested view $path with locals: $data';
  };
}

void main() async {
  var app = Angel();
  await app.configure(plugin);
  await AngelHttp(app).startServer('localhost', 3000);
}
```
