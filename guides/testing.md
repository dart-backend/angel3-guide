# Developer Guide

* [Testing](testing.md#testing)
  * [`connectTo(...)`](testing.md#connectto)
  * [`isJson(..)`](testing.md#isjson)
  * [`hasStatus(...)`](testing.md#hasstatus)
  * [More Matchers...](testing.md#more-matchers)
* [Next Up...](testing.md#next-up)

## Testing

Dart already has fantastic testing support, through a library of [testing helpers](https://github.com/dart-backend/angel/tree/master/packages/test) that will make test writing faster. The following functions are exported by [`package:angel3_test`](https://github.com/dart-backend/angel/tree/master/packages/test), and will make your testing much easier.

### connectTo

[Full definition](https://pub.dev/documentation/angel3_test/latest/angel3_test/connectTo.html)

This function will start `app` on an available port, and return a `TestClient` instance \(based on [`package:angel3_client`](https://github.com/dart-backend/angel/tree/master/packages/client)\) configured to send requests to the server. The client also supports session manipulation.

```dart
void main() {
  late TestClient client;

  setUp(() async {
    var app = Angel()..get('/hello', (req, res) => {'hello': 'world'});
    client = await connectTo(app);
  });

  // Shut down server, and cancel pending requests
  tearDown(() => client.close());

  test('hello', () async {
    // This returns an http.Response. :)
    var response = await client.get(Uri.parse('/hello'));
    expect(response, allOf(hasStatus(200), isJson({'hello': 'world'})));
  });
}
```

### isJson

A `Matcher` that asserts that the given `http.Response` equals `value` when decoded as JSON. This uses `test.equals` internally, so anything that would pass that matcher passes this one.

### hasStatus

A `Matcher` that asserts the given `http.Response` has the given `status` code.

### More Matchers

The complete set of `angel3_test` Matchers can be found [here](https://pub.dev/documentation/angel3_test/latest/angel3_test/angel3_test-library.html).

## Next Up

1. Find out how to [handle errors](error-handling.md) in an Angel3 application.
2. Learn how to use the handy [Angel3 CLI](../cli/cli-setup.md).
