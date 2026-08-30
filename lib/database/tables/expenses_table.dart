import 'package:drift/drift.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get expenseNumber => text().unique()();
  TextColumn get category => text()(); // ExpenseCategory enum
  IntColumn get amount => integer()();
  TextColumn get description => text()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  TextColumn get referenceNumber => text().nullable()();
  IntColumn get createdByUserId => integer().references(Users, #id)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
