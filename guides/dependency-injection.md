# Dependency-Injection

Angel3 uses a [container hierarchy](https://github.com/dart-backend/angel/tree/master/packages/container/container) for DI. Dependency injection makes it easier to build applications with multiple moving parts, because logic can be contained in one location and reused at another place in your application.

## Adding a Singleton

```dart
Future<void> myPlugin(Angel app) async {
  app.container.registerSingleton(SomeClass('foo'));
  app.container.registerSingleton<SomeAbstractClass>(MyImplClass());
  app.container.registerFactory((_) => SomeClass('foo'));
  app.container.registerLazySingleton((_) => SomeOtherClass());
  app.container.registerNamedSingleton('yes', Yes());
}
```

You can also inject within a `RequestContext`, as each one has a `container` property that extends from the app's global container.

Accessing these injected properties is easy, and strongly typed:

```dart
// Inject types.
var todo = req.container!.make<Todo>();
print(todo.isComplete);

// Or by name
var db = req.container!.findByName<Db>('database');
var collection = db.collection('pets');
```

Registering and reading instances, as above, needs no reflection.

## In Routes and Controllers

In Angel3, by wrapping a function in a call to `ioc`, you can automatically inject the dependencies of any route handler. Reflecting on the function needs a reflector (see [below](#enabling-dart-mirrors-or-other-reflection)); without one, describe its parameters with `injection:`:

```dart
app.get('/greet/:name', ioc(
  (Greeter greeter, String name) => greeter.greet(name),
  injection: InjectionRequest.constant(required: [Greeter, ['name', String]]),
));
```

With a reflector:

```dart
app.get('/some/class/text', ioc((SomeClass singleton) => singleton.text)); // Always "foo"

app.post("/foo", ioc((SomeClass singleton, {Foo? optionalInjection}) => singleton.text));

@Expose('/my/controller')
class MyController extends Controller {
  @Expose('/bar')
  // Inject classes from container, request parameters or the request/response context :)
  String bar(SomeClass singleton, RequestContext req) => '${singleton.text} bar'; // Always "foo bar"

  @Expose("/baz")
  baz({Foo? optionalInjection}) => 'baz';
}
```

`ioc` finds the parameters of the function with the app's reflector. Without one, as in an app compiled with `dart compile exe`, list them in an `InjectionRequest`; a parameter given as `[name, type]` is read from the route parameters:

```dart
app.get('/greet/:name', ioc(
  (Greeter greeter, String name) => greeter.greet(name),
  injection: InjectionRequest.constant(required: [Greeter, ['name', String]]),
));
```

As you can imagine, this is very useful for managing things such as database connections.

```dart
Future<void> configureServer(Angel app) async {
  var db = Db('mongodb://localhost:27017/db');
  await db.open();
  app.container.registerSingleton(db);
}

@Expose('/users')
class ApiController extends Controller {
  @Expose('/:id')
  Future fetchUser(String id, Db db) =>
      db.collection('users').findOne(where.id(ObjectId.fromHexString(id)));
}
```

## Dependency-Injected Controllers

`Controller`s have dependencies injected without any additional configuration by you. However, you might want to inject dependencies into the constructor of your controller.

```dart
@Expose('/controller')
class MyController extends Controller {
  final AngelAuth auth;
  final Db db;

  MyController(this.auth, this.db);

  @Expose('/login')
  RequestHandler login() => auth.authenticate('local');
}

void main() async {
  var app = Angel(reflector: MirrorsReflector());

  // At some point in your application, register necessary dependencies as singletons...
  app.container.registerSingleton(auth);
  app.container.registerSingleton(db);

  // Create the controller with injected dependencies
  await app.mountController<MyController>();
}
```

## Enabling `dart:mirrors` or other Reflection

By default, `Angel()` has no reflector, so that it can be used where `dart:mirrors` is not available, such as in apps compiled with `dart compile exe` and in Flutter. Without a reflector, these features are unavailable:

* `@Expose` on controller methods
* The `@Middleware` and `@Hooks` annotations, which are ignored
* Dependency injection into **constructors**, whether in controllers or plain `container.make` calls
* `ioc` without `injection:`

To use them, pass a reflector to the app:

* On the Dart VM, `MirrorsReflector` of `package:angel3_container_mirrors` uses `dart:mirrors`:

  ```dart
  import 'package:angel3_container_mirrors/angel3_container_mirrors.dart';

  var app = Angel(reflector: MirrorsReflector());
  ```

* To compile with `dart compile exe`, mark the classes with `@injectable`, generate their reflection data with `package:angel3_container_generator` and `dart run build_runner build`, and pass it to `StaticReflector`. Each library gets one variable named after its file, such as `servicesReflection` for `services.dart`:

  ```dart
  var app = Angel(reflector: StaticReflector.combine([servicesReflection]));
  ```

Mark controllers, services with `@Hooks` or `@Middleware`, and top-level functions used as handlers with `@injectable`. A closure cannot be described, so `ioc((Foo foo) => ...)` still needs `injection:` with generated data. The [`angel3_container_generator` README](https://pub.dev/packages/angel3_container_generator) lists its limitations.

## Next Up

Continue reading to learn about [Middleware](middleware.md).
