dabl-dart
=========

Dart programming language port of [DABL](https://github.com/ManifestWebDesign/DABL).

## About
DABL is a database ORM that builds uses classes to represent and interact with each table in your database. Using these classes, table rows can be created, retrieved, updated, deleted, and counted using very simple and short commands without writing raw SQL (unless you want to). DABL is designed to make the repetitive tasks of database access easier using objects.  DABL also recognizes foreign key relationships and automatically creates class methods for them.

## Full example project
For an example project that uses DABL, please see [Rollcall](https://github.com/TheBosZ/rollcall): a simple AngularDart app to take roll for a class or meeting.

## Installing
Add a reference to "dabl" in the project's "pubspec.yaml" and run "pub install".

## Generating Models
Use the [DABL Generator](https://github.com/TheBosZ/dabl-generator) project to create the models. Copy the generated files to your project directory. Use the generated "pubspec.yaml" as a basis for your project.

## Using the models
For this document, let's assume we have two tables. One table is "User" with the fields "ID", "Name", "Password", "Email", and "LastLogin" and the other table is "Car" with the fields "ID", "UserID" which is a foreign key to User.ID, "Make" and "Model".

### Database access and Futures
Any operation that has to talk to the database will return a [Future](https://www.dartlang.org/docs/tutorials/futures/). Make sure that your code can handle async operations. 

### Creation
To create a new record, just create a new object, set the desired fields and then call "save".

```dart
User user = new User();
user.setName('Joe');
user.setPassword('sup3ers3cr3t');
user.email('joe@example.com');
user.save();
```

### Retrieval
There are static methods on the models that allow for retrieval of objects. Any foreign keys are automatically turned into retrieval methods. Remember that database access is async.

```dart
User.retrieveByName('Joe').then((User u) {
  u.getCars().then((List<Car> cars) {
    print(cars.first.getModel());
  });
});
```

### Updating
After retrieving (or creating), the model can be updated by changing the fields and then calling save.

```dart
User.retrieveByName('Joe').then((User u) {
  u.setEmail('joe.bob@example.com');
  u.save();
});
```

### Deletion
Deleting a record is easy.

```dart
User.retrieveByName('Joe').then((User u) {
  u.delete();
});
```

### Counting
Counting is slightly tricky. Any models related by foreign keys will have a "count" method.

```dart
User.retrieveByName('Joe').then((User u) {
  u.countCars().then((int count) {
    print("${u.getName()} has ${count} cars");
  });
});
```
