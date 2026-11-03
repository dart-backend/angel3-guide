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
abstract class WheelEntity extends Model {
  @belongsTo
  CarEntity? get car;
}
```

The local key defaults to `car_id`, and the foreign key defaults to `id`.
You can manually override these:

```dart
@BelongsTo(localKey: 'carId', foreignKey: 'licenseNumber')
CarEntity? get car;
```

The ORM fetches `@hasOne` and `@belongsTo` relations with `JOIN`s, in the same query as the records, as each record is still one row. `@hasMany` and `@manyToMany` relations are loaded after the records, with one query for all of them (`WHERE car_id IN (...)`), so `limit` and `offset` count records rather than the rows of a join. In Angel3 9.x and earlier, these were joined too.

## Many-to-many Relationships

A very common situation that occurs when using relational databases is where two tables may be bound to multiple copies of each other. For example, in a school database, each student could be registered to multiple classes, and each class could have multiple students taking it.

This is typically handled by creating a third table, which joins the two together. In the Angel3 ORM, this is relatively straightforward:

```dart
@serializable
abstract class ClassEntity extends Model {
  String? get courseName;

  @ManyToMany(EnrollmentEntity)
  List<StudentEntity> get students;
}

@serializable
abstract class StudentEntity extends Model  {
  String? get name;
  int? get year;

  @ManyToMany(EnrollmentEntity)
  List<ClassEntity> get classes;
}

@serializable
abstract class EnrollmentEntity {
    @belongsTo
    StudentEntity? get student;

    @belongsTo
    ClassEntity? get class_;
}
```

In short:

1. Make a pivot table, C, between two tables, table A and B.
2. C should `@belongsTo` both A and B. C *should not* extend `Model`.
3. A should have a field: `@ManyToMany(CEntity) List<BEntity> get b;`
4. B should have a field: `@ManyToMany(CEntity) List<AEntity> get a;`
