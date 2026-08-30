import 'package:drift/drift.dart';

class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get province => text().nullable()();
  TextColumn get postalCode => text().nullable()();
  IntColumn get currentPayable => integer().withDefault(const Constant(0))();
  TextColumn get bankAccountName => text().nullable()();
  TextColumn get bankAccountNumber => text().nullable()();
  TextColumn get bankName => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
