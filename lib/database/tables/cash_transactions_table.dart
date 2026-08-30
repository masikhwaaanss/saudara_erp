import 'package:drift/drift.dart';

class CashTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionNumber => text().unique()();
  TextColumn get type => text()(); // cash_in, cash_out
  TextColumn get category => text()();
  IntColumn get amount => integer()();
  TextColumn get description => text()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get referenceType => text().nullable()(); // sale, purchase, receivable_payment, expense, etc
  IntColumn get referenceId => integer().nullable()();
  IntColumn get createdByUserId => integer().references(Users, #id)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
