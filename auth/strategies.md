# Strategies

Just like in Passport, strategies implement authentication via a specific provider. To create your own strategy, you need to implement the `AuthStrategy` class.

All strategies must implement `authenticate(req, res, [opts])`.

## authenticate

This method should only have three possible results.

**Possibility #1:** Return `true`

This signifies that whatever authentication process you performed was completed successfully, and that it did not produce any result that needs to be serialized.

**Possibility #2:** Return `false`

This represents an authentication failure, and will throw a `401 Not Authenticated` error.

**Possibility #3:** Return something else entirely

This signifies that although the user was successfully authenticated, the authenticated user needs to be serialized into another format for the entire authentication flow to be considered complete.

For example, you usually need to save a user's ID after authentication.

```dart
import 'package:angel3_auth/angel3_auth.dart';

class MyStrategy implements AuthStrategy {
  @override
  authenticate(req, res, [opts]) async {
    final user =
      await login(req.body['username'], req.body['password']);

    return user != null ? user : false;
  }
}
```
