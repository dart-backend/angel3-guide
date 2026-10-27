# Angel3 Authentication

`angel3_auth` is, in many ways, a port of Passport to the Angel3 Framework. It authenticates users with JSON Web Tokens (JWTs), and comes with a local strategy, which also supports HTTP Basic authentication.

```yaml
dependencies:
  angel3_auth: ^10.0.0
```

## Usage

```dart
import 'package:angel3_auth/angel3_auth.dart';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_framework/http.dart';

void main() async {
  var app = Angel();

  // Of course, create an instance.
  //
  // A `jwtKey` is not required, but without a pre-established secret,
  // JWT's will automatically be invalidated whenever the server restarts.
  //
  // If `allowCookie` is `true` (`true` by default), then JWT's can also be carried within
  // a `token` cookie.
  var auth = AngelAuth<User>(
    jwtKey: 'MY_SECRET',
    // The following two functions de/serialize a user from a JWT.
    serializer: (user) => user.id ?? '',
    deserializer: (id) => fetchAUserByIdSomehow(id),
  );

  // This adds a global middleware to decode JWT's and deserialize them,
  // and also creates a route to refresh JWT's.
  await app.configure(auth.configureServer);

  // Strategies are used to implement authentication methods
  auth.strategies['local'] = LocalAuthStrategy((username, password) async {
    // Return the user if the credentials are valid, or `null` otherwise.
    return await findCorrespondingUser(username, password);
  });

  // Use `authenticate` to log users in
  app.post('/auth/local', auth.authenticate('local'));

  await AngelHttp(app).startServer('127.0.0.1', 3000);
}

class User {
  String? id, username, password;
}
```

After a user is logged in, later requests that send the JWT, in an `Authorization: Bearer` header or the `token` cookie, are authenticated. Read the user with `req.container!.make<User>()`, and protect routes with the `requireAuthentication<User>()` middleware.

## Security Defaults

* A JWT expires after a day (`jwtLifeSpan`, in milliseconds).
* `POST /auth/token` exchanges a JWT that is still valid for a new one; an expired one only within `reviveGracePeriod` (default: none).
* The `token` cookie is `HttpOnly`, `Secure` and `SameSite=Lax` (`cookieSameSite`), and is set when a user logs in. `logout` expires it.
* A JWT in the query string (`?token=`) is ignored unless `allowTokenInQuery` is `true`.

These changed in 10.0.0; see the [README of `angel3_auth`](https://pub.dev/packages/angel3_auth) for how to upgrade.
