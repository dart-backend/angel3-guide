# Relations

Relational modeling is one of the most commonly-used features of sql databases -
after all, it *is* the namesake of the term "relational database."

Angel3 supports the following kinds of relations by means of annotations on fields:

* `@hasOne` (one-to-one)
* `@hasMany` (one-to-many)
* `@belongsTo` (one-to-one)
* `@manyToMany` (many-to-many)

By default, the keys for columns are inferred automatically.
In the following case:

```dart
@serializable
@orm
abstract class WheelEntity extends Model {
  @belongsTo
  CarEntity? get car;
}
```

The local key defaults to `car_id`, and the foreign key defaults to `id`.
You can manually override these:

```dart
@BelongsTo(localKey: 'car_id', foreignKey: 'license_number')
CarEntity? get car;
```

A relation names the other model by its entity class (`CarEntity`), because the generated class (`Car`) does not exist yet when the generator reads it.

## Loading Relations

Relations are loaded with every query that returns records: `get`, `getOne`, `insert`, `update` and `delete`.

* `@hasOne` and `@belongsTo` are fetched with `JOIN`s, as each record is still one row.
* `@hasMany` is loaded after the records, with one query for all of them (`WHERE car_id IN (...)`), rather than joined, which would return a row per item.
* `@manyToMany` is loaded with a query of the pivot table, then one of the other model.

The items loaded have their own relations loaded in turn, such as a `@hasMany` of a `@hasMany`, so the number of queries depends on the relations, not on the number of records. Fetching authors with their books and the books' reviews takes three queries, however many authors there are. As a record is one row, `limit` and `offset` count records.

A relation back to a table that is being loaded is not loaded again, and is left empty: the `roles` of a `User` are loaded, but not the `users` of those roles, which would load the user again.

The query of a `@hasMany` is the one its items are loaded with, so its conditions and order apply to them:

```dart
var query = AuthorQuery()..where!.name.equals('Jane');
query.books
  ..where!.published.isTrue
  ..orderBy('title');

// Jane, with only her published books, by title.
var author = await query.getOne(executor);
```

Before 10.0.0, `@hasMany` and `@manyToMany` were joined too, so `limit` counted the rows of the joins. See the [10.0.0 Migration Guide](../migration/migration-guide-10.md).

## Many-to-many Relationships

A very common situation that occurs when using relational databases is where two tables may be bound to multiple copies of each other. For example, in a school database, each student could be registered to multiple classes, and each class could have multiple students taking it.

This is typically handled by creating a third table, which joins the two together. In the Angel3 ORM, this is relatively straightforward:

```dart
@serializable
@orm
abstract class CourseEntity extends Model {
  String? get courseName;

  @ManyToMany(EnrollmentEntity)
  List<StudentEntity> get students;
}

@serializable
@orm
abstract class StudentEntity extends Model {
  String? get name;
  int? get year;

  @ManyToMany(EnrollmentEntity)
  List<CourseEntity> get courses;
}

@serializable
@orm
abstract class EnrollmentEntity {
  @belongsTo
  StudentEntity? get student;

  @belongsTo
  CourseEntity? get course;
}
```

In short:

1. Make a pivot table, C, between two tables, table A and B.
2. C should `@belongsTo` both A and B. C *should not* extend `Model`.
3. A should have a field: `@ManyToMany(CEntity) List<BEntity> get b;`
4. B should have a field: `@ManyToMany(CEntity) List<AEntity> get a;`
