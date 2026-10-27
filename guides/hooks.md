# Developer Guide

* [Hooks](hooks.md#hooks)
* [The `@Hooks` Annotation](hooks.md#the-hooks-annotation)
* [Next Up...](hooks.md#next-up)

## Hooks

Another concept borrowed from FeathersJS is the concept of _hooking services_. This is a mechanism that allows you to separate concerns within your application. For example, many sites send their users confirmation e-mails after successful registration. The logic to do this is often included in the same place as the code to create the user. Hooks allow you to keep the logic for these two tasks, which are more or less unrelated, in two separate places. And what's more, this frees you up to change your service code without having to update the confirmation code in multiple places. For example, you can easily use an in-memory user store in development, and a MongoDB one in production, and use the same confirmation code for each service. So, let's take a look.

When you `use` a service class, Angel3 wraps it in a `HookedService`, which `app.use` returns. A `HookedService` fires events before and after its inner service runs. This opens the opportunity for events to be canceled, or have parameters modified.

This is similar to middleware, but whereas middleware only runs before requests, hooks can run before and after.

```dart
class HookedService<Id, Data, T extends Service<Id, Data>> extends Service<Id, Data> {
  final HookedServiceEventDispatcher<Id, Data, T> beforeIndexed;
  final HookedServiceEventDispatcher<Id, Data, T> afterIndexed;

  // And so on, for read, created, modified, updated and removed...
}
```

A `HookedServiceEventDispatcher` has one key method you will use: `listen`. In a way, this is similar to a broadcast stream, but it has a few catches. These dispatch `HookedServiceEvent` instances, which look like this:

```dart
/// Fired when a hooked service is invoked.
class HookedServiceEvent<Id, Data, T extends Service<Id, Data>> {
  static const String indexed = 'indexed';
  static const String read = 'read';
  static const String created = 'created';
  static const String modified = 'modified';
  static const String updated = 'updated';
  static const String removed = 'removed';

  /// The inner service whose method was hooked.
  T service;

  /// The name of the event being fired. This class exposes
  /// some constant Strings you can check for, to prevent typos.
  String get eventName;

  /// The `id` passed to this event, if any.
  Id? get id;

  /// The data passed to `create`, `modify` or `update`. It can be changed
  /// in a 'before' hook.
  Data? data;

  /// The parameters passed to the service method. Although the getter is
  /// read-only, you can still assign values within it.
  Map get params;

  /// The request and response, when the service is called over HTTP.
  RequestContext? get request;
  ResponseContext? get response;

  /// After an event completes, this will hold whatever
  /// value the service method returned.
  dynamic result;

  /// If you call this, no further event callbacks will be fired.
  /// If called on a 'before' hook, no further 'before' events will fire.
  /// Same for an 'after' hook.
  ///
  /// If you call this on a 'before' hook, the actual service method
  /// will never be called. Instead, `result` will be returned as the
  /// response, and any 'after' hooks will see this value as the `result`.
  ///
  /// This is very useful, and allows another way to filter or deny access to
  /// services than traditional middleware.
  void cancel([Object? result]);
}
```

```dart
var service = app.use('/api/todos', MapService());

service.afterCreated.listen((e) {
  // In an `after` hook, `e.result` would be the created data.
  if (e.result['completed'] != true) {
    // Use `cancel` to prematurely end an event. In this case,
    // the following response will be given, rather than the
    // created todo:
    e.cancel({'error': 'Hey, you still have to ${e.result['text']}!'});
  }
});
```

A service mounted earlier can be found with `app.findHookedService`:

```dart
var todos = app.findHookedService<MapService>('api/todos');
todos?.beforeCreated.listen((e) => e.data?['created_by'] = e.request?.params['user']);
```

## The `@Hooks` Annotation

Alternatively, the `Hooks` annotation can be used to assign hooks to service methods. Annotations are read with the app's reflector, so this needs one; see [Enabling `dart:mirrors` or other Reflection](dependency-injection.md#enabling-dart-mirrors-or-other-reflection).

```dart
void helloHook(HookedServiceEvent e) => print('Hello, world!');
void fooHook(HookedServiceEvent e) => print('Bar');

@Hooks(before: [helloHook])
class MyService extends Service<String, String> {
  @Hooks(before: [fooHook])
  @override
  Future<List<String>> index([Map<String, dynamic>? params]) async {
    return ['world'];
  }
}
```

## Next Up

Congratulations! Not only have you gotten through the basic Angel3 tutorials, but you've also completed the service tutorials! However, there's still a lot more to Angel3 for you to explore. Check out the sidebar for more! _**Happy coding!**_
