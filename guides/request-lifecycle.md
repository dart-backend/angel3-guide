# Request-Lifecycle

Requests in the Angel3 framework go through a relatively complex lifecycle, and to truly master the framework, one must understand that lifecycle.

1. `startServer` is called.
2. Each `HttpRequest` is sent through `handleRequest`.
3. `handleRequest` converts the `HttpRequest` to a `RequestContext`, and converts its `HttpResponse` into a
   `ResponseContext`.

4. `angel3_route` is used to match the request path to a list of request handlers.
5. Each handler is executed.
   Each handler must return `true` for the next one to run.
6. If the response is streamed (the default), rather than buffered (`res.useBuffer()`), skip to step 9.
7. All `responseFinalizers` are run.
8. All headers, the status code and the response buffer are sent through the actual `HttpResponse`, with a `Content-Length` header, unless `res.chunked` is `true`.
9. The `HttpResponse` is closed.

When the server shuts down, `AngelHttp.close()` stops accepting requests, lets those in progress finish, within `closeTimeout`, and then runs the app's `shutdownHooks`.

If at any point an error occurs, Angel3 will catch it. See the [error handling](error-handling.md) docs for more.

## Next Up

Continue reading to learn about [Dependency Injection](dependency-injection.md).
