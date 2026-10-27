# Strategies

Just like in Passport, strategies implement authentication via a specific provider. To create your own strategy, you need to implement the `AuthStrategy` class.

All strategies must implement `authenticate(req, res, [options])`.

## authenticate

This method should only have two possible results.

**Possibility #1:** Return a user

This signifies that the user was successfully authenticated. The user is serialized with the `serializer` of `AngelAuth`, and a JWT is issued for it.

**Possibility #2:** Return `null`

This represents an authentication failure, and will throw a `401 Not Authenticated` error, unless another strategy given to `authenticate` succeeds.

```dart
import 'dart:async';

import 'package:angel3_auth/angel3_auth.dart';
import 'package:angel3_framework/angel3_framework.dart';

class MyStrategy extends AuthStrategy<User> {
  @override
  Future<User?> authenticate(RequestContext req, ResponseContext res,
      [AngelAuthOptions<User>? options]) async {
    await req.parseBody();
    return await login(
        req.bodyAsMap['username'] as String?, req.bodyAsMap['password'] as String?);
  }
}
```

Register it with `auth.strategies['my'] = MyStrategy();`, and use it with `auth.authenticate('my')`.

## Other Strategies

* [Local](local-auth.md), with and without HTTP Basic authentication, is part of `angel3_auth`.
* [OAuth2](https://pub.dev/packages/angel3_auth_oauth2), for providers such as Google or GitHub.
* [Twitter](https://github.com/dart-backend/angel/tree/master/packages/auth_twitter), with OAuth 1.0a.
