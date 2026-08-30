import 'package:drift/drift.dart';

class DeliveryNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deliveryNoteNumber => text().unique()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get customerId => integer().references(Customers, #id)();
  DateTimeColumn get issueDate => dateTime()();
  TextColumn get deliveryAddress => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))(); // DeliveryNoteStatus
  DateTimeColumn get deliveredDate => dateTime().nullable()();
  TextColumn get driver => text().nullable()();
  TextColumn get licensePlate => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdByUserId => integer().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class DeliveryNoteItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deliveryNoteId => integer().references(DeliveryNotes, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  TextColumn get unit => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
