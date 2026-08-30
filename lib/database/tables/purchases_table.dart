import 'package:drift/drift.dart';

class Purchases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get purchaseNumber => text().unique()();
  IntColumn get supplierId => integer().references(Suppliers, #id)();
  DateTimeColumn get purchaseDate => dateTime()();
  TextColumn get paymentMethod => text()(); // PaymentMethod enum
  TextColumn get paymentStatus => text().withDefault(const Constant('unpaid'))(); // PaymentStatus enum
  IntColumn get subtotal => integer()();
  IntColumn get discountAmount => integer().withDefault(const Constant(0))();
  IntColumn get additionalCost => integer().withDefault(const Constant(0))();
  IntColumn get grandTotal => integer()();
  IntColumn get paidAmount => integer().withDefault(const Constant(0))();
  IntColumn get remainingAmount => integer()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdByUserId => integer().references(Users, #id)();
  BoolColumn get isCancelled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseId => integer().references(Purchases, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  IntColumn get unitPrice => integer()();
  IntColumn get subtotal => integer()();
  IntColumn get discountPerUnit => integer().withDefault(const Constant(0))();
  IntColumn get discountTotal => integer().withDefault(const Constant(0))();
  IntColumn get subtotalAfterDiscount => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchasePayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseId => integer().references(Purchases, #id)();
  TextColumn get paymentMethod => text()(); // PaymentMethod enum
  IntColumn get amount => integer()();
  TextColumn get referenceNumber => text().nullable()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdByUserId => integer().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
