import 'package:drift/drift.dart';

class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get action => text()(); // AuditAction enum
  TextColumn get entityType => text()(); // Product, Customer, Sale, etc
  IntColumn get entityId => integer().nullable()();
  TextColumn get description => text()();
  TextColumn get oldValues => text().nullable()(); // JSON
  TextColumn get newValues => text().nullable()(); // JSON
  TextColumn get ipAddress => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
