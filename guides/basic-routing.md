# About Routing

* [Routing](basic-routing.md#routing)
* [Route Parameters](basic-routing.md#route-parameters)
  * [Parsing Parameters](basic-routing.md#parsing-parameters)
* [`RegExp` Routes](basic-routing.md#regexp-routes)
* [Mounting Routers](basic-routing.md#mounting-routers)
* [Route Groups](basic-routing.md#route-groups)
* [Extended Documentation](basic-routing.md#extended-documentation)
* [Next Up...](basic-routing.md#next-up)

## Routing

There is only one method responsible for adding routes to your application:

```dart
app.addRoute('<method>', '<path>', requestHandler);
```

However, the following methods are available for convenience, and are the ones you will use most often. Each method's name responds to an HTTP request method. For example, a route declared with `app.get(...)`, will respond to HTTP `GET` requests.

```dart
app.get('<path>', requestHandler);
app.post('<path>', requestHandler);
app.put('<path>', requestHandler);
app.patch('<path>', requestHandler);
app.delete('<path>', requestHandler);
app.head('<path>', requestHandler);
```

Your `requestHandler` should take the following form:

```dart
typedef RequestHandler = FutureOr<dynamic> Function(RequestContext req, ResponseContext res);
```

Your `requestHandler` can return any Dart value, whether a function, or an object. See the [Requests and Responses](requests-and-responses.md#return-values) pages for detailed documentation.

Route paths _do not_ have to begin with a forward slash, as leading and trailing slashes are stripped from route paths internally.

## Route Parameters

Say you're building an API, or an MVC application. You typically want to serve the same view template on multiple paths, corresponding to different ID's. You can do this as follows, and all parameters will be available via `req.params`:

```dart
app.get('/todos/:id', (req, res) async => {'id': req.params['id']});
```

Remember, route parameters _must_ be preceded by a colon \(':'\). Parameter names must start with a letter or underscore, optionally followed by letters, underscores, or numbers. Parameters will match any character except a forward slash \('/'\) in a request URI.

Examples:

* `:id`
* `:_hello`
* `:param123`
* `info_about_:username`

### Parsing Parameters

With a special syntax, you can build routes that automatically parse parameters as `ints` or `doubles`. A typed parameter matches only a number, so `/add/abc` is not routed to the handler below:

```dart
app
  ..get('/add/int:number', (req, res) => (req.params['number'] as int) * 3)
  ..get('/multiply/double:number', (req, res) => (req.params['number'] as double) * 5.0);
```

## RegExp Routes

Route parameters can also have custom regular expressions, to remove the requirement of manual parsing. Simply enclose the regular expression in a set of parentheses following the parameter's name.

```dart
app.get(r'/number/:num([0-9]+(\.[0-9])?)', ...);
```

## Mounting Routers

You can `mount` routers, and their routes are added under the given path. Services are mounted with `use`, as [Service Basics](service-basics.md#mounting-services) describes.

```dart
var app = Angel();
app.get('/', (req, res) => 'Hello!');

var subRouter = Router<RequestHandler>()..get('/', (req, res) => 'Subroute');
app.mount('/sub', subRouter);
// Now, you can visit /sub and receive the message "Subroute"
```

## Route Groups

Routes can also be grouped together. Route parameters, and the group's `middleware`, will be applied to sub-routes automatically. Route groups can be nested as well.

```dart
app.group('/user/:id', (router) {
  router
    ..get('/messages', (req, res) => fetchUserMessages(req.params['id']))
    ..group('/nested', (nested) {
      // ...
    });
}, middleware: [requireAuthentication]);
```

## Extended Documentation

For more documentation on the router, see [Angel3 Route Repository](https://github.com/dart-backend/angel/tree/master/packages/route). [`angel3_route`](https://pub.dev/packages/angel3_route) has no `dart:io` or `dart:mirrors` dependency, and it also supports browser use \(both hash and push state\).

## Next Up

Learn how [Requests and Responses](requests-and-responses.md) work, and then how [Middleware](middleware.md) lets you reuse functionality across your entire routing setup.
