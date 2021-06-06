# Main Points
**WARNING**, backup your existing code before proceeding with migration as the process cannot be reversed. Angel project can be upgraded to Angel3 by following the steps below:
1. Run `dart pub outdated --mode=null-safety`. Make sure all the packages **except** `angel_*` are upgradable.
2. Check that all `angel_*` packages can be upgraded by referring to [Migrated Angel3 Packages](https://github.com/dukefirehawk/angel/wiki/Migrated-Angel3-Packages).
3. Upgrade all `angel_*` packages manually in `pubspec.yml` by referring to 
[NNDB Basic Starter Template](https://github.com/dukefirehawk/boilerplates/blob/basic-sdk-2.12.x_nnbd/pubspec.yaml) or 
[NNDB ORM Starter Template](https://github.com/dukefirehawk/boilerplates/blob/orm-sdk-2.12.x_nnbd/pubspec.yaml)
4. Run `dart pub upgrade --null-safety` to upgrade the rest of the packages automatically.
5. Run `dart migrate` to do the migration.
6. Fix and resolve NNBD related warnings and errors in the code.
7. Replace all `angel_*` packages in `pubspec.yml` with `angel3_*` equivalent by referring to [Migrated Angel3 Packages](https://github.com/dukefirehawk/angel/wiki/Migrated-Angel3-Packages).
8. Fix and resolve import errors in your project by updating them to `angel3_*` packages.
