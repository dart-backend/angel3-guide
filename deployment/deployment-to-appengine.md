# Deployment to AppEngine

You can use [`package:appengine`](https://pub.dartlang.org/packages/appengine) with Angel3 easily, just by passing it your app's `handleRequest` method:

```dart
import 'package:angel3_framework/angel3_framework.dart';
import 'package:appengine/appengine.dart';

void main() async {
  var app = Angel();
  var http = AngelHttp(app);
  // ...

  await runAppEngine(http.handleRequest);
}
```
