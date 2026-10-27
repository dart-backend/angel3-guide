# LocalAuthStrategy

`LocalAuthStrategy` authenticates users by a username and a password, sent in the request body, or, with `allowBasic: true`, in an HTTP Basic `Authorization` header:

```dart
auth.strategies['local'] = LocalAuthStrategy<User>(
  (username, password) async => await findCorrespondingUser(username, password),
  allowBasic: true,
);

app.post('/auth/local', auth.authenticate('local'));
```

See the [docs](https://pub.dev/documentation/angel3_auth/latest/angel3_auth/LocalAuthStrategy-class.html).
