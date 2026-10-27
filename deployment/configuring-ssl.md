# Configuring SSL

The `AngelHttp.secure` and `AngelHttp.fromSecurityContext` constructors allow you to run servers that listen to HTTPS requests, which is great in cases where your application handles sensitive data.

You'll need a public and private key, in PEM format:

```dart
var context = SecurityContext()
    ..useCertificateChain('keys/server.crt')
    ..usePrivateKey('keys/server.key');
var http = AngelHttp.fromSecurityContext(app, context);
await http.startServer('0.0.0.0', 443);
```

Or, more briefly:

```dart
var http = AngelHttp.secure(app, 'keys/server.crt', 'keys/server.key');
```

For HTTP/2, which browsers use only over HTTPS, use `AngelHttp2` with a `SecurityContext` instead; its `allowHttp1` option serves HTTP/1.1 clients on the same port.

However, a single AngelHttp instance only corresponds to one `HttpServer` instance. To handle secure requests, while also redirecting insecure users to our HTTPS server, you'll need to have a server listening at port 80, whose only handler is a [middleware](../guides/middleware.md) that sends redirects from plain HTTP URL's to their HTTPS counterparts:

```dart
/// Redirect HTTP URL's to their HTTPS counterparts...
Future<void> enforceHttps() async {
  var enforcer = Angel()
    ..fallback((req, res) =>
        res.redirect(req.uri!.replace(scheme: 'https', port: 443).toString(), code: 301));
  var http = AngelHttp(enforcer);
  var server = await http.startServer('0.0.0.0', 80);
  print('HTTPS enforcer listening at http://${server.address.address}:${server.port}');
}
```

In production, the redirect and HTTPS are often left to a reverse proxy, such as [nginx](ubuntu-and-nginx.md), in front of the Angel3 server.
