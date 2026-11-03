# Jinja

[`angel3_jinja`](https://github.com/dart-backend/angel/tree/master/packages/jinja) renders [Jinja](https://jinja.palletsprojects.com/) templates as views, with [jinja.dart](https://github.com/ykmnkmi/jinja.dart), a port of Jinja to Dart by Olzhas Suleimen.

```yaml
dependencies:
  angel3_jinja: ^10.0.0
```

## Usage

Configure the app with `jinja`, and the path of the views directory. `res.render` then renders a template of it:

```dart
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_framework/http.dart';
import 'package:angel3_jinja/angel3_jinja.dart';
import 'package:path/path.dart' as p;

void main() async {
  var app = Angel();
  var http = AngelHttp(app);
  var viewsDir = p.join(p.dirname(p.fromUri(Platform.script)), 'views');

  // Enable Jinja views
  await app.configure(jinja(path: viewsDir));

  app
    ..get('/', (req, res) => res.render('index.html'))
    ..get('/hello/:name', (req, res) => res.render('hello.html', req.params));

  app.fallback((req, res) => throw AngelHttpException.notFound());

  await http.startServer('127.0.0.1', 3000);
  print('Listening at ${http.uri}');
}
```

## Escaping

Values are not HTML-escaped. Escape every value that is not trusted HTML, such as one from the request, with the `e` (or `escape`) filter:

```html
<p>hello {{ name | e }}!</p>
```

## Views

A view name that resolves outside the views directory (`../secret.html`, an absolute path, a symbolic link out of it), that has none of the extensions in `ext`, or that does not exist, is a 404. In production, templates are kept parsed, so changes to them are seen only after the app restarts; otherwise they are read again on every render.
