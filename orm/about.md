# About ORM

Angel3, like many other Web server frameworks, features support for object-relational mapping, or _ORM_. ORM tools allow for conversion from database results to Dart classes.

Angel3's ORM uses Dart's `build` system to generate query builder classes from your `Model` classes, and takes advantage of Dart's strong typing to prevent errors at runtime. It supports PostgreSQL 14 or later, MySQL 8 or later, and MariaDB 10.2 or later.

Take, for example, the following class:

```dart
@serializable
@orm
abstract class PokemonEntity extends Model {
    String? get nickName;

    int? get level;

    int? get experiencePoints;

    @belongsTo
    PokemonTrainerEntity? get trainer;

    @belongsTo
    PokemonSpeciesEntity? get species;

    @belongsTo
    PokemonAttackEntity? get attack0;

    @belongsTo
    PokemonAttackEntity? get attack1;

    @belongsTo
    PokemonAttackEntity? get attack2;

    @belongsTo
    PokemonAttackEntity? get attack3;
}
```

`package:angel3_orm_generator` will generate a `Pokemon` model and a `PokemonQuery` class that let you do the following:

```dart
app.get('/trainer/int:id/first_moves', (req, res) async {
    var id = req.params['id'] as int;
    var executor = req.container!.make<QueryExecutor>();
    var query = PokemonQuery()..where!.trainerId.equals(id);
    var pokemon = await query.get(executor);
    return pokemon.map((p) => p.attack0?.name).toList();
});
```

This section of the Angel3 documentation consists mostly of guides, rather than technical documentation.

For more in-depth documentation, see the actual `angel3_orm` project on GitHub:

<https://github.com/dart-backend/angel/tree/master/packages/orm>
