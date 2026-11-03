# Running without `dart:mirrors`

`dart compile exe` and Flutter do not support `dart:mirrors`. An Angel3 app can still be compiled into a native executable, which starts faster, and needs no Dart SDK to run:

```bash
dart compile exe bin/prod.dart -o server
ANGEL_ENV=production ./server
```

There are two ways to do this: run the app without a reflector, or give it reflection data generated at build time.

## Without a reflector

`Angel()` has no reflector by default, so it runs with reflection disabled. Routes, services, hooks added with `listen`, and types registered in the container work as usual:

```dart
var app = Angel(); // no reflector

app.container.registerSingleton(Greeter());   // register what you inject
app.use('/api/todos', MapService());           // services work as usual

// Inject with an explicit InjectionRequest instead of reflecting on the closure.
app.get('/greet/:name', ioc(
  (Greeter greeter, String name) => greeter.greet(name),
  injection: InjectionRequest.constant(required: [Greeter, ['name', String]]),
));

// Controllers take their mount path from `expose` and add routes in `configureRoutes`.
class HealthController extends Controller {
  HealthController() : super(expose: const Expose('/health'));

  @override
  void configureRoutes(Routable routable) =>
      routable.get('/', (req, res) => {'status': 'ok'});
}

await app.configure(HealthController().configureServer);
```

Without reflection, these features are unavailable:

* `@Expose` on controller methods
* The `@Middleware` and `@Hooks` annotations, which are ignored
* Dependency injection into constructors, in controllers or `container.make`
* `ioc` without `injection:`

The app logs a warning at startup that says so. The [`no_mirrors.dart` example](https://github.com/dart-backend/angel/blob/master/packages/framework/example/no_mirrors.dart) is a complete app.

## With generated reflection data

To keep those features in a compiled app, generate the reflection data they need with [`angel3_container_generator`](https://pub.dev/packages/angel3_container_generator):

1. Add the generator to `pubspec.yaml`:

   ```yaml
   dependencies:
     angel3_container: ^10.0.0
   dev_dependencies:
     angel3_container_generator: ^10.0.0
     build_runner: ^2.4.0
   ```

2. Mark the classes with `@injectable`, and add a `part` directive:

   ```dart
   import 'package:angel3_container/angel3_container.dart';
   import 'package:angel3_framework/angel3_framework.dart';

   part 'controller.g.dart';

   @injectable
   @Expose('/greet')
   class GreetController extends Controller {
     // GET /greet/hello/:name
     String getHello(String name) => 'Hello, $name!';

     // GET /greet/shout?text=...
     @Expose('/shout')
     String shout(@Query('text') String text) => text.toUpperCase();
   }
   ```

3. Run `dart run build_runner build`. Each library gets one variable named after its file, here `controllerReflection`.

4. Pass the data to the app:

   ```dart
   var app = Angel(reflector: StaticReflector.combine([controllerReflection]));
   await app.configure(GreetController().configureServer);
   ```

Mark with `@injectable`:

* Controllers, so their `@Expose` methods are routed
* Services with `@Hooks` or `@Middleware`
* Classes the container constructs, such as a controller with constructor parameters
* Models whose members are read by name, as in a Jael template
* Top-level functions used as handlers, so `@Middleware` on them applies, and `ioc(handler)` can inject their parameters

A closure cannot be described, so `ioc((Foo foo) => ...)` still needs `injection:`. The [generator's README](https://pub.dev/packages/angel3_container_generator) lists its other limitations.

## With `angel3_production`

The starter templates run their production server with the `Runner` of [`angel3_production`](https://github.com/dart-backend/angel/tree/master/packages/production), without a reflector, so `bin/prod.dart` can be compiled as it is. To use generated data, pass it to the `Runner`:

```dart
void main(List<String> args) => Runner(
  'Starter App',
  configureServer,
  reflector: StaticReflector.combine([controllerReflection]),
).run(args);
```

## On the Dart VM

When the app runs with `dart run`, `MirrorsReflector` of [`angel3_container_mirrors`](https://pub.dev/packages/angel3_container_mirrors) provides the same features with `dart:mirrors`, without generated code:

```dart
import 'package:angel3_container_mirrors/angel3_container_mirrors.dart';

var app = Angel(reflector: MirrorsReflector());
```
