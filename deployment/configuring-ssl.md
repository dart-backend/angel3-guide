# Configuring SSL

The `AngelHttp.secure` and `AngelHttp.fromSecurityContext` constructors allow you to run servers that listen to HTTPS requests, which is great in cases where your application handles sensitive data.

You'll need a public and private key, in PEM format:

```dart
var context = SecurityContext()
    ..useCertificateChain('keys/server.crt')
    ..usePrivateKey('keys/server.key');
var http = AngelHttp.fromSecurityContext(app, context);
```

With `angel3_production`, pass `--ssl`, `--certificate-file` and `--key-file` to the `Runner` instead. To serve HTTP/2, see [HTTP/2](../guides/http2.md).

## Redirecting to HTTPS

A single `AngelHttp` instance only corresponds to one `HttpServer` instance. To handle secure requests, while also redirecting insecure users to your HTTPS server, you'll need another server listening at port 80, which redirects each request to its HTTPS counterpart:

```dart
/// Redirect HTTP URL's to their HTTPS counterparts...
Future<void> enforceHttps() async {
  var enforcer = Angel();
  enforcer.fallback((req, res) {
    // The `Host` header, without its port.
    var host = Uri.parse('http://${req.hostname}').host;
    return res.redirect('https://$host${req.uri}', code: 301);
  });

  var http = AngelHttp(enforcer);
  var server = await http.startServer('0.0.0.0', 80);
  print('HTTPS enforcer listening at http://${server.address.address}:${server.port}');
}
```

In production, a reverse proxy such as [nginx](ubuntu-and-nginx.md) often terminates TLS, and redirects plain HTTP, instead of the app.
