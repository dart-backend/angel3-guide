# Developer Guide

* [Requests and Responses](requests-and-responses.md#requests-and-responses)
  * [Return Values](requests-and-responses.md#return-values)
  * [Other Parameters](requests-and-responses.md#other-parameters)
  * [Queries, Files and Bodies](requests-and-responses.md#queries-files-and-bodies)
* [Next Up...](requests-and-responses.md#next-up)

## Requests and Responses

Angel3 is inspired by Express, and as such, request handlers in general resemble those from Express. Request handlers can return any Dart object \(see [how they are handled](requests-and-responses.md#return-values)\). Basic request handlers accept two parameters:

* [`RequestContext`](https://pub.dev/documentation/angel3_framework/latest/angel3_framework/RequestContext-class.html) - Contains vital information about the client requesting a resource, such as request method, request body, IP address, etc. The request object can also be used to pass information from one handler to the next.
* [`ResponseContext`](https://pub.dev/documentation/angel3_framework/latest/angel3_framework/ResponseContext-class.html) - Allows you to send headers, write data, and more, to be sent to the client. To prevent a response from being modified by future handlers, call `res.end()` to prevent further writing.

### Return Values

Request handlers can return any Dart value. Return values are handled as follows:

* If you return a `bool`: Request handling will end prematurely if you return `false`, but it will continue if you return `true`.
* If you return `null`, or nothing: Request handling will end, as if you returned `false`. Return `true` from a middleware that lets the request through. The response is sent as the handler left it, such as after `res.write()`. Some response methods, such as [`res.redirect()`](https://pub.dev/documentation/angel3_framework/latest/angel3_framework/ResponseContext/redirect.html) or [`res.serialize()`](https://pub.dev/documentation/angel3_framework/latest/angel3_framework/ResponseContext/serialize.html), automatically close the response.
* A `RequestHandler`: the returned handler will be executed.
* Another function: it will be called with its parameters injected, which needs a [reflector](dependency-injection.md#enabling-dart-mirrors-or-other-reflection).
* A `Stream`: `toList` will be called, and then returned.
* A `Future`: it will be awaited, and then returned.
* Anything else: Whatever other Dart value you return will be serialized as a response. The default method is to encode responses as JSON, using `json.encode`. However, you can change a response's serialization method by setting `res.serializer = foo;`. If you want to assign the same serializer to all responses, globally set [`serializer`](https://pub.dev/documentation/angel3_framework/latest/angel3_framework/Angel/serializer.html) on your Angel instance. The default serializer is `json.encode`, which handles JSON-compatible Dart objects, like Maps and Lists, and objects with a `toJson` method.

### Buffered and Streamed Responses

By default, what a handler writes is streamed to the client. Call `res.useBuffer()` to buffer the response instead, so that it can still be changed, for example by `responseFinalizers`, until the request ends. A buffered response is sent with a `Content-Length` header; set `res.chunked = true` to send it with chunked transfer encoding.

### Other Parameters

Request handlers can take other parameters, instead of just a `RequestContext` and `ResponseContext`. Consult the [dependency injection documentation](dependency-injection.md#in-routes-and-controllers).

### Queries, Files and Bodies

You can access a mutable `Map` based on the URI query parameters through `RequestContext.queryParameters`.

Consult the [body parsing documentation](body-parsing.md) to understand how to handle user input.

For more information, see the API docs:

[RequestContext](https://pub.dev/documentation/angel3_framework/latest/angel3_framework/RequestContext-class.html)

[ResponseContext](https://pub.dev/documentation/angel3_framework/latest/angel3_framework/ResponseContext-class.html)

## Next Up

Now, let's learn about Angel3's [Request Lifecycle](request-lifecycle.md).
