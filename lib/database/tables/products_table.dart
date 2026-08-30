import 'package:drift/drift.dart';

class ProductCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ProductUnits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get symbol => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  IntColumn get categoryId => integer().references(ProductCategories, #id)();
  IntColumn get unitId => integer().references(ProductUnits, #id)();
  TextColumn get calculationType => text()(); // CalculationType enum
  IntColumn get costPrice => integer()(); // in Rupiah minor units
  IntColumn get buyerPrice => integer()(); // in Rupiah minor units
  IntColumn get applicatorPrice => integer()(); // in Rupiah minor units
  IntColumn get agentPrice => integer()(); // in Rupiah minor units
  IntColumn get minimumStock => integer().withDefault(const Constant(0))();
  IntColumn get maximumStock => integer().withDefault(const Constant(0))();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
