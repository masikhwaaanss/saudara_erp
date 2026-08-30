import 'package:drift/drift.dart';

class StockBalances extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id).unique()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  TextColumn get movementType => text()(); // StockMovementType enum
  TextColumn get referenceType => text().nullable()(); // sale, purchase, adjustment, etc
  IntColumn get referenceId => integer().nullable()();
  DateTimeColumn get movementDate => dateTime()();
  IntColumn get createdByUserId => integer().references(Users, #id)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
