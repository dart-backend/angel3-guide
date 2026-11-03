# HTTP/2

Angel3 serves HTTP/2 with `AngelHttp2`, of `package:angel3_framework/http2.dart`. The same `Angel` app can be served over HTTP/1.1 and HTTP/2, so routes, services and plug-ins need no change.

Browsers only speak HTTP/2 over TLS, so `AngelHttp2` needs a certificate, and ALPN to negotiate the `h2` protocol:

```dart
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_framework/http.dart';
import 'package:angel3_framework/http2.dart';

void main() async {
  var app = Angel();
  app.get('/', (req, res) => 'Hello HTTP/2!!!');
  app.fallback((req, res) => throw AngelHttpException.notFound());

  var ctx = SecurityContext()
    ..useCertificateChain('dev.pem')
    ..usePrivateKey('dev.key', password: 'dartdart')
    ..setAlpnProtocols(['h2'], true);

  var http1 = AngelHttp(app);
  var http2 = AngelHttp2(app, ctx);

  // Clients that do not negotiate HTTP/2 are served by `AngelHttp`.
  http2.onHttp1.listen(http1.handleRequest);

  await http2.startServer('127.0.0.1', 3000);
  print('Listening at ${http2.uri}');
}
```

Pass `allowHttp1: true` to `AngelHttp2` to serve HTTP/1.1 clients without an `AngelHttp` of your own.

With `angel3_production`, pass `--http2`, `--certificate-file` and `--key-file` to the `Runner` instead.

## Sessions

An HTTP/2 request gets a session, and the session cookie, only when `req.session` is first read. Code that expects the cookie on every response must read `req.session`.

Sessions are discarded after they have not been used for `sessionTimeout`, 20 minutes by default, like those of `dart:io`'s `HttpServer`:

```dart
var http2 = AngelHttp2(app, ctx, sessionTimeout: const Duration(hours: 1));
```

## Server push

With HTTP/2, the server can push resources that a page will request, before the browser asks for them. The response of an HTTP/2 request is an `Http2ResponseContext`:

```dart
// `streamFile` takes a `File` of `package:file`.
var fs = const LocalFileSystem();
var styleCss = fs.file('web/style.css');
var appJs = fs.file('web/app.js');
var indexHtml = fs.file('web/index.html');

app.get('/', (req, res) async {
  if (res is Http2ResponseContext && res.canPush) {
    await res.push('/style.css').streamFile(styleCss);
    await res.push('/app.js').streamFile(appJs);
  }

  await res.streamFile(indexHtml);
});
```

`canPush` is `false` when the client has disabled server push. The [HTTP/2 examples](https://github.com/dart-backend/angel/tree/master/packages/framework/example/http2) include body parsing and server push.
