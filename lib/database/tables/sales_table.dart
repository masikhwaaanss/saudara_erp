import 'package:drift/drift.dart';

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().unique()();
  IntColumn get customerId => integer().references(Customers, #id)();
  DateTimeColumn get saleDate => dateTime()();
  TextColumn get paymentMethod => text()(); // PaymentMethod enum
  TextColumn get paymentStatus => text().withDefault(const Constant('unpaid'))(); // PaymentStatus enum
  IntColumn get subtotal => integer()(); // before discount
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

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get calculationType => text()(); // CalculationType enum
  IntColumn get quantity => integer()(); // for fixed
  IntColumn get totalMeter => integer().nullable()(); // for meter/strip_meter
  IntColumn get lengthPerSheet => integer().nullable()(); // for strip_meter only
  IntColumn get sellingUnitPrice => integer()();
  IntColumn get subtotalBeforeDiscount => integer()();
  IntColumn get discountPerUnit => integer().withDefault(const Constant(0))();
  IntColumn get discountTotal => integer().withDefault(const Constant(0))();
  IntColumn get subtotalAfterDiscount => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SalePayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
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
