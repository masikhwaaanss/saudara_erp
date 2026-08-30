import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/customers_table.dart';

class CustomersDao {
  final AppDatabase db;

  CustomersDao(this.db);

  /// Get customer by ID
  Future<Customer?> getCustomerById(int id) {
    return (db.select(db.customers)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Get customer by code
  Future<Customer?> getCustomerByCode(String code) {
    return (db.select(db.customers)..where((c) => c.code.equals(code))).getSingleOrNull();
  }

  /// Get all active customers
  Future<List<Customer>> getAllActiveCustomers() {
    return (db.select(db.customers)
          ..where((c) => c.isActive.equals(true) & c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .get();
  }

  /// Search customers by name, code, or phone
  Future<List<Customer>> searchCustomers(String query) {
    return (db.select(db.customers)
          ..where((c) =>
              (c.name.like('%$query%') |
                  c.code.like('%$query%') |
                  c.phone.like('%$query%')) &
              c.isActive.equals(true) &
              c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .get();
  }

  /// Create customer
  Future<int> createCustomer(CustomersCompanion customer) {
    return db.into(db.customers).insert(customer);
  }

  /// Update customer
  Future<bool> updateCustomer(Customer customer) {
    return db.update(db.customers).replace(customer);
  }

  /// Update customer receivable
  Future<bool> updateCustomerReceivable(int customerId, int amount) {
    return (db.update(db.customers)..where((c) => c.id.equals(customerId)))
        .write(CustomersCompanion(currentReceivable: Value(amount)));
  }

  /// Soft delete customer
  Future<bool> softDeleteCustomer(int customerId) {
    return (db.update(db.customers)..where((c) => c.id.equals(customerId)))
        .write(CustomersCompanion(deletedAt: Value(DateTime.now())));
  }
}
