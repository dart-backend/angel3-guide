# Angel3 Authentication

`angel3_auth` is, in many ways, a port of Passport to the Angel3 Framework.

## Usage

```dart
// Of course, create an instance.
//
// A `jwtKey` is not required, but without a pre-established secret,
// JWT's will automatically be invalidated whenever the server restarts.
//
// If your `allowCookie` is `true` (`true` by default), then JWT's can also be carried within
// a `token` cookie. This can be annoying during the development stage, as it is difficult to remove
// cookies from Dartium.
//
// By convention, try to avoid cookies and session use whenever possible.
var auth = AngelAuth(jwtKey: 'MY_SECRET', allowCookie: false);

// The following two functions de/serialize a user from a JWT.
auth.serializer = (user) async => serializeUserToId();
auth.deserializer = (id) async => deserializeUserFromId();

// Strategies are used to implement authentication methods
auth.strategies.add['local'] = LocalAuthStrategy((username, password) async {
  return await findCorrespondingUser(username, password);
});

// Use `authenticate` to log users in
var app = Angel()..post('/auth/local', auth.authenticate('local'));

// Finally, call our instance as a plugin.
//
// This will a global middleware to decode JWT's and deserialize them,
// and also creates a route to refresh JWT's.
await app.configure(auth);
```
