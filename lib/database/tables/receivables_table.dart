import 'package:drift/drift.dart';

class Receivables extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get customerId => integer().references(Customers, #id)();
  IntColumn get originalAmount => integer()();
  IntColumn get paidAmount => integer().withDefault(const Constant(0))();
  IntColumn get remainingAmount => integer()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('unpaid'))(); // unpaid, partial, paid, overdue
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ReceivablePayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get receivableId => integer().references(Receivables, #id)();
  IntColumn get customerId => integer().references(Customers, #id)();
  IntColumn get amount => integer()();
  TextColumn get paymentMethod => text()(); // PaymentMethod enum
  TextColumn get referenceNumber => text().nullable()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdByUserId => integer().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
