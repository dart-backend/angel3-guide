# Developer Guide

* [Services](service-basics.md#services)
  * [Service Parameters and Middleware](service-basics.md#service-parameters-and-middleware)
  * [Mounting Services](service-basics.md#mounting-services)
* [Next Up...](service-basics.md#next-up)

## Services

One of the main concepts within Angel3, which is borrowed from FeathersJS, is a _service_. You more than likely have already dealt with another implementation of the service concept. In Angel3, a _service_ is a class that acts as a Web interface and exposes CRUD actions operating on a set of data. Angel3 services extend `Routable`, and thus can be mounted on a certain path and become REST endpoints.

The Angel3 core library includes the `Service` base class, as well as the in-memory `MapService`. Database adapter packages, such as [`package:angel3_mongo`](https://github.com/dart-backend/angel/tree/master/packages/mongo), [`package:angel3_orm_service`](https://github.com/dart-backend/angel/tree/master/packages/orm/orm_service) or [`package:angel3_redis`](https://github.com/dart-backend/angel/tree/master/packages/redis), include service classes that let you interact with a database without writing complex code yourself.

Services can also be filtered or reacted to with [service hooks](hooks.md).

A service looks like this:

```dart
class MyService extends Service<String, Map<String, dynamic>> {
  // GET /
  // Fetch all resources. Usually returns a List.
  @override
  Future<List<Map<String, dynamic>>> index([Map<String, dynamic>? params]);

  // GET /:id
  // Fetch one resource, by its ID
  @override
  Future<Map<String, dynamic>> read(String id, [Map<String, dynamic>? params]);

  // POST /
  // Create a resource. This endpoint should return
  // the created resource.
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data, [Map<String, dynamic>? params]);

  // PATCH /:id
  // Modifies a resource. Clients can submit only the data
  // they want to change, and the corresponding resource will
  // have only those fields changed. This endpoint should return
  // the modified resource.
  @override
  Future<Map<String, dynamic>> modify(String id, Map<String, dynamic> data, [Map<String, dynamic>? params]);

  // POST /:id
  // Overwrites a resource. The existing resource is completely
  // replaced by the new data. This endpoint should return the
  // new resource.
  @override 
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data, [Map<String, dynamic>? params]);

  // DELETE /:id
  // Deletes a resource. This endpoint should return the
  // deleted resource.
  @override
  Future<Map<String, dynamic>> remove(String id, [Map<String, dynamic>? params]);
}
```

There are meta-methods that default to delegating to the above:

* `findOne`
* `readMany`

You can override these for your service, if it will improve performance.

### Service Parameters and Middleware

You might notice that each service method accepts an optional `Map` of parameters. When accessed via HTTP \(i.e., not over Websockets\), the query string is passed in it as `params['query']`, and the body is passed as `data` to `create`, `update` and `modify`. To pass custom parameters to a service, you should create a middleware to do so. `@Middleware` annotations, which need a [reflector](dependency-injection.md#enabling-dart-mirrors-or-other-reflection), can be prepended to service classes or service methods. For example, the following will pass `foo='bar'` to every method in the service:

```dart
Future<bool> myMiddleware(RequestContext req, ResponseContext res) async {
  req.queryParameters['foo'] = 'bar';
  return true;
}

@Middleware([myMiddleware])
class MyService extends Service {
  // Responds with "['bar']"
  @override
  Future<List> index([Map<String, dynamic>? params]) async => [params!['query']['foo']];
}
```

Additionally, when accessed by a client, `params` will contain a field called `provider`.

```dart
class MyService extends Service {
  @override
  Future create(data, [Map<String, dynamic>? params]) async {
    if (params == null || params['provider'] == null) {
       // Accessed via server
    }
    return data;
  }
}
```

`provider` will be a `Providers` class, whose `String via` will tell you where the service is being accessed from, i.e. `'rest'`, `'graphql'` or `'websocket'`.

### Mounting Services

As mentioned above, services extend `Routable`, so you can simply `app.use()` them. You can also supplement them with additional routes or middleware, placed _before_ the mounting of a service:

```dart
app.get('/user/:id/todos', (req, res) => fetchUserTodos(req.params['id']));

// Another way to apply a middleware to a service
app.all('/user/*', someMiddleware);

app.use('/user', MongoService(db.collection('users')));

// Access app services. Returns the HookedService that `use` mounted.
// Leading and trailing slashes are ignored.
var users = app.findService('user'); // The user service
var secrets = app.findServiceOf<String, Map<String, dynamic>>('secret');
```

A service deals with `Map`s. To work with model classes instead, `map` it with the serializer generated by [`angel3_serialize`](serialization.md):

```dart
var todos = app.findServiceOf<String, Map<String, dynamic>>('api/todos')!
    .map(TodoSerializer.fromMap, TodoSerializer.toMap);
Todo todo = await todos.read('1');
```

Ids are parsed from the URL to the service's `Id` type: a `Service<int, ...>` gets an `int`, and an id that cannot be parsed is a `400 Bad Request`.

## Additional Notes

Important things to consider when writing your own service:

* [`MapService`](https://github.com/dart-backend/angel/tree/master/packages/framework/lib/src/core/map_service.dart) and [mongo](https://github.com/dart-backend/angel/tree/master/packages/mongo/lib/mongo_service.dart) are good reference implementations
* Services need only worry about handling `Map`s. Object serialization should be handled by `angel3_serialize`, another serializer, or `Service.map`.
* Allowing users to query the service via query string is optional (see `allowQuery`)
* Allowing users to remove all entries is **optional**, and should be disabled by default
  
  * `DELETE /null` should trigger an evaluation of `allowRemoveAll`
  * `Service.toId` will return `null` in these cases
* Always return the most recent representation of the data
  
  * After `remove`, return the old item
  * After modify/update, return what the item looks like in the database
* `modify` and `update` are **not** interchangeable!
  
  * `modify` merges changes into an existing item
  * `update` **overwrites** an existing item
  * BOTH should create an item with the given ID if it does not already exist
