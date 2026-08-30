import 'package:drift/drift.dart';

class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().unique()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get customerId => integer().references(Customers, #id)();
  DateTimeColumn get invoiceDate => dateTime()();
  IntColumn get subtotal => integer()();
  IntColumn get discountAmount => integer()();
  IntColumn get additionalCost => integer()();
  IntColumn get grandTotal => integer()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('issued'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
