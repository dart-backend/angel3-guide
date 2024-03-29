# Developer Guide

* [Error Handling](error-handling.md#error-handling)
* [Next Up...](error-handling.md#next-up)

## Error Handling

Error handling is one of the most important concerns in building Web applications. The easiest way to throw an HTTP exception is to actually `throw` one. Angel3 provides an `AngelHttpException` class to take care of this.

```dart
app.get('/this-page-does-not-exist', (req, res) async {
  // 404 Not Found
  throw AngelHttpException.notFound();
});
```

Of course, you will probably want to handle these errors, and potentially render views upon catching them.

Fortunately, Angel3 runs every request in a `try`/`catch`, and gracefully intercepts exceptions. This enables Angel3 to catch errors on every request, and not crash the server. Unhandled errors are wrapped in instances of `AngelHttpException`, which can be handled as follows.

You can also turn on the `useZone` flag in `AngelHttp` or another driver (i.e. HTTP/2) to run each request in its own `Zone`, though by Angel3, this is no longer necessary.

To provide custom error handling logic:

```dart
// Typically, you want to preserve the old error handler, unless you are
// completely replacing the functionality.
var oldErrorHandler = app.errorHandler;

app.errorHandler = (e, req, res) {
  if (someCondition || req.accepts('text/html', strict: true)) {
    // Do something else special...
  } else {
    // Otherwise, use the default functionality.
    return oldErrorHandler(e, req, res);
  }
}
```

## Next Up

Congratulations! You have completed the basic Angel3 tutorials. Take what you've learned on a spin in a small side project, and then move on to learning about [services](service-basics.md).
