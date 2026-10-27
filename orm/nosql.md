# NoSQL Support

As one can imagine, a SQL ORM cannot be used with a NoSQL database. However, this is usually not a problem, because the ideal use cases for NoSQL databases
typically do not require the functionality present in an ORM (namely, relation support).

With a NoSQL database, you can use the `Service` API (you likely already are!), and use `Service.map` to deal with Dart data only, rather than messing around with `Map`s, and risking typos and refactoring challenges.

If you are using `package:angel3_serialize`, this is pretty easy:

```dart
@serializable
abstract class GreetingEntity extends Model {
    String? get text;

    double? get attachedMoney;
}

var service = MongoService(db.collection('greetings'));
var mappedService = service.map(GreetingSerializer.fromMap, GreetingSerializer.toMap);

// Now you can get Greeting instances.
var greeting = await mappedService.read(id);
print([greeting.text, greeting.attachedMoney]);
```

Angel3 has services for several NoSQL databases: [MongoDB](https://pub.dev/packages/angel3_mongo), [RethinkDB](https://pub.dev/packages/angel3_rethinkdb), [Redis](https://pub.dev/packages/angel3_redis) and [Sembast](https://pub.dev/packages/angel3_sembast), as well as a [JSON file](https://pub.dev/packages/angel3_file_service) for development.
