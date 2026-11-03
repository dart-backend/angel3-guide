# Angel3 Serialization

![Pub Version (including pre-releases)](https://img.shields.io/pub/v/angel3_serialize?include_prereleases)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Discord](https://img.shields.io/discord/1060322353214660698)](https://discord.gg/3X6bxTUdCM)
[![License](https://img.shields.io/github/license/dart-backend/angel)](https://github.com/dart-backend/angel/tree/master/packages/serialize/serialize/LICENSE)

Source-generated serialization for Dart objects. This package uses `package:source_gen` to eliminate the time you spend writing boilerplate serialization code for your models. `package:angel3_serialize` also powers `package:angel3_orm`.

- [Angel3 Serialization](#angel3-serialization)
  - [Usage](#usage)
  - [Models](#models)
  - [Serialization](#serialization)
  - [Customizing Serialization](#customizing-serialization)
  - [Subclasses](#subclasses)
  - [Aliases](#aliases)
  - [Excluding Keys](#excluding-keys)
  - [Required Fields](#required-fields)
  - [Adding Annotations to Generated Classes](#adding-annotations-to-generated-classes)
  - [Custom Serializers](#custom-serializers)
  - [Nesting](#nesting)
  - [ID and Dates](#id-and-dates)
  - [Binary Data](#binary-data)
  - [TypeScript Definitions](#typescript-definitions)
  - [Constructor Parameters](#constructor-parameters)

## Usage

In your `pubspec.yaml`, you need to install the following dependencies:

```yaml
dependencies:
  angel3_serialize: ^10.0.0
dev_dependencies:
  angel3_serialize_generator: ^10.0.0
  build_runner: ^2.4.0
```

`angel3_serialize` exports `angel3_model`, so `Model` needs no other import. Build models anywhere in your project structure by running `dart run build_runner build`.

To tweak this: [Build Config](https://pub.dev/packages/build_config)

If you want to watch for file changes and re-build when necessary, replace the `build` call with a call to `watch`. They take the same parameters.

## Models

There are a few changes opposed to normal Model classes. You need to add a `@serializable` annotation to your model class to have it serialized, and a serializable model class's name should end with `Entity`. The generated class takes the name without the suffix. A leading underscore, such as `_Book`, still works, but `Entity` is the convention.

In addition, you may consider using an `abstract` class to ensure immutability of models.

Rather you writing the public class, `angel3_serialize` does it for you. This means that the main class can have its constructors automatically generated, in addition into serialization functions.

For example, say we have a `Book` model. Create a class named `BookEntity`:

```dart
import 'package:angel3_serialize/angel3_serialize.dart';
part 'book.g.dart';

@serializable
abstract class BookEntity extends Model {
  String? get author;

  @SerializableField(defaultValue: '[Untitled]')
  String? get title;

  String? get description;

  int? get pageCount;

  BookType? get type;
}

/// It even supports enums!
enum BookType {
  fiction,
  nonFiction
}
```

The following file will be generated:

- `book.g.dart`

Producing these classes:

- `Book`: Extends or implements `BookEntity`, with `copyWith`, `==` and `toJson`.
- `BookSerializer`: static functionality for serializing `Book` models.
- `BookFields`: The names of all fields from the `Book` model, statically-available.
- `BookEncoder`: Allows `BookSerializer` to extend `Codec<Book, Map>`.
- `BookDecoder`: Also allows `BookSerializer` to extend `Codec<Book, Map>`.

And the following other features:

- `bookSerializer`: A top-level, `const` instance of `BookSerializer`.
- `Book.toString`: Prints out all of a `Book` instance's fields.

## Serialization

You can use the generated files as follows:

```dart
myFunction() {
  var warAndPeace = Book(
    author: 'Leo Tolstoy',
    title: 'War and Peace',
    description: 'You will cry after reading this.',
    pageCount: 1225
  );

  // Easily serialize models into Maps
  var map = BookSerializer.toMap(warAndPeace);

  // Also deserialize from Maps
  var book = BookSerializer.fromMap(map);
  print(book.title); // 'War and Peace'

  // For compatibility with `jsonEncode`, a `toJson` method
  // is included that forwards to `BookSerializer.toMap`:
  expect(book.toJson(), map);

  // Generated classes act as value types, and thus can be compared.
  expect(BookSerializer.fromMap(map), equals(warAndPeace));
}
```

The generated output also includes information about the serialized names of keys on your model class.

```dart
  myOtherFunction() {
    // Relying on the serialized key of a field? No worries.
      map[BookFields.author] = 'Zora Neale Hurston';
  }

```

## Customizing Serialization

Currently, these serialization methods are supported:

- to `Map`
- to JSON
- to TypeScript definitions

You can customize these by means of `serializers`:

```dart
@Serializable(serializers: [Serializers.map, Serializers.json])
abstract class MyClassEntity extends Model {}
```

## Subclasses

`angel3_serialize` pulls in fields from parent classes, as well as implemented interfaces, so it is extremely easy to share attributes among model classes:

```dart
import 'package:angel3_serialize/angel3_serialize.dart';
part 'subclass.g.dart';

@serializable
class AnimalEntity {
  @notNull
  String? genus;
  @notNull
  String? species;
}

@serializable
class BirdEntity extends AnimalEntity {
  @DefaultsTo(false)
  bool? isSparrow;
}

var saxaulSparrow = Bird(
  genus: 'Passer',
  species: 'ammodendri',
  isSparrow: true,
);
```

## Aliases

Whereas Dart fields conventionally are camelCased, most database columns tend to be snake_cased. This is not a problem, because we can define an alias for a field.

By default `angel3_serialize` will transform keys into snake case. Use `alias` to provide a custom name, or pass `autoSnakeCaseNames`: `false` to the builder;

```dart
@serializable
abstract class SpyEntity extends Model {
  /// Will show up as 'agency_id' in serialized JSON.
  ///
  /// When deserializing JSON, instead of searching for an 'agencyId' key,
  /// it will use 'agency_id'.
  ///
  /// Hooray!
  String? agencyId;

  @SerializableField(alias: 'foo')
  String? someOtherField;
}
```

You can also override `autoSnakeCaseNames` per model:

```dart
@Serializable(autoSnakeCaseNames: false)
abstract class OtherCasingEntity extends Model {
  String? camelCasedField;
}
```

## Excluding Keys

In pratice, there may keys that you want to exclude from JSON. To accomplish this, simply annotate them with `@exclude`:

```dart
@serializable
abstract class WhisperEntity extends Model {
  /// Will never be serialized to JSON
  @SerializableField(exclude: true, isNullable: true)
  String? secret;
}
```

There are times, however, when you want to only exclude either serialization or deserialization, but not both. For example, you might want to deserialize passwords from a database without sending them to users as JSON.

In this case, use `canSerialize` or `canDeserialize`:

```dart
@serializable
abstract class WhisperEntity extends Model {
  /// Will never be serialized to JSON
  ///
  /// ... But it can be deserialized
  @SerializableField(exclude: true, canDeserialize: true, isNullable: true)
  String? secret;
}
```

## Required Fields

It is easy to mark a field as required:

```dart
@serializable
abstract class FooEntity extends Model {
  @SerializableField(isNullable: false)
  int? get myRequiredInt;

  @SerializableField(isNullable: false, errorMessage: 'Custom message')
  int? get myOtherRequiredInt;
}
```

The given field will be marked as `required` in the generated constructor, and serializers will check for its presence, throwing a `FormatException` if it is missing.

## Adding Annotations to Generated Classes

There are times when you need the generated class to have annotations affixed to it:

```dart
@Serializable(
  includeAnnotations: [
    Deprecated('blah blah blah'),
    pragma('something...'),
  ]
)
abstract class FooEntity extends Model {}
```

## Custom Serializers

`package:angel3_serialize` does not cover every known Dart data type; you can add support for your own. Provide `serializer` and `deserializer` arguments to `@SerializableField()` as you see fit.

They are typically used together. Note that the argument to `deserializer` will always be `dynamic`, while `serializer` can receive the data type in question.

In such a case, you might want to also provide a `serializesTo` argument. This lets the generator, as well as the ORM, apply the correct (de)serialization rules and validations.

```dart
DateTime? _dateFromString(s) => s is String ? HttpDate.parse(s) : null;
String? _dateToString(DateTime? v) => v == null ? null : HttpDate.format(v);

@serializable
abstract class HttpRequestEntity {
  @SerializableField(
    serializer: #_dateToString,
    deserializer: #_dateFromString,
    serializesTo: String)
  DateTime? date;
}
```

## Nesting

`angel3_serialize` also supports a few types of nesting of `@serializable` classes:

- As a class member, ex. `Book myField`
- As the type argument to a `List`, ex. `List<Book>`
- As the second type argument to a `Map`, ex. `Map<String, Book>`

In other words, the following are all legal, and will be serialized/deserialized. You can use either the name of a child model class (ex. `BookEntity`), or the generated class name (ex `Book`):

```dart
@serializable
abstract class AuthorEntity extends Model {
  List<BookEntity> get books;
  BookEntity? get newestBook;
  Map<String, BookEntity> get booksByIsbn;
}
```

If your model (`Author`) depends on a model defined in another file (`Book`), then you will need to generate `book.g.dart` before, `author.g.dart`, **in a separate build action**. This way, the analyzer can resolve the `Book` type.

## ID and Dates

This package will automatically generate `id`, `createdAt`, and `updatedAt` fields for you, in the style of an Angel3 `Model`. This will automatically be generated, **only** for classes extending `Model`.

## Binary Data

`package:angel3_serialize` also handles `Uint8List` fields, by means of serialization to and from `base64` encoding.

## TypeScript Definitions

It is quite common to build frontends with JavaScript and/or TypeScript, so why not generate typings as well?

To accomplish this, add `Serializers.typescript` to your `@Serializable()` declaration:

```dart
@Serializable(serializers: [Serializers.map, Serializers.json, Serializers.typescript])
abstract class FooEntity extends Model {}
```

`Serializers.all` lists all three. An `AuthorEntity` with a required `name` and `age`, and a `LibraryEntity` with a `Map<String, BookEntity> get collection`, generate the following in a `.d.ts` file:

```typescript
interface Author {
  id?: string;
  created_at?: any;
  updated_at?: any;
  name: string;
  age: number;
  books?: Book[];
  newest_book?: Book;
}
interface Library {
  id?: string;
  created_at?: any;
  updated_at?: any;
  collection?: LibraryCollection;
}
interface LibraryCollection {
  [key: string]: Book;
}
```

Excluded fields, such as those with `@exclude` or `@SerializableField(exclude: true)`, will not be present in the TypeScript definition. The rationale for this is that if a field (i.e. `password`) will never be sent to the client, the client shouldn't even know the field exists.

## Constructor Parameters

Sometimes, you may need to have custom constructor parameters, for example, when using depedency injection frameworks. For these cases, `angel3_serialize` can forward custom constructor parameters.

The following:

```dart
@serializable
abstract class BookmarkEntity extends Model {
  @SerializableField(exclude: true)
  final BookEntity book;

  @SerializableField(isNullable: false)
  int? get page;

  String? get comment;

  BookmarkEntity(this.book);
}
```

Generates:

```dart
class Bookmark extends BookmarkEntity {
  Bookmark(
    BookEntity book, {
    this.id,
    this.createdAt,
    this.updatedAt,
    required this.page,
    this.comment,
  }) : super(book);

  @override
  String? id;

  // ...
}
```
