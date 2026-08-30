import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/suppliers_table.dart';

class SuppliersDao {
  final AppDatabase db;

  SuppliersDao(this.db);

  /// Get supplier by ID
  Future<Supplier?> getSupplierById(int id) {
    return (db.select(db.suppliers)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// Get supplier by code
  Future<Supplier?> getSupplierByCode(String code) {
    return (db.select(db.suppliers)..where((s) => s.code.equals(code))).getSingleOrNull();
  }

  /// Get all active suppliers
  Future<List<Supplier>> getAllActiveSuppliers() {
    return (db.select(db.suppliers)
          ..where((s) => s.isActive.equals(true) & s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm(expression: s.name)]))
        .get();
  }

  /// Search suppliers by name, code, or phone
  Future<List<Supplier>> searchSuppliers(String query) {
    return (db.select(db.suppliers)
          ..where((s) =>
              (s.name.like('%$query%') |
                  s.code.like('%$query%') |
                  s.phone.like('%$query%')) &
              s.isActive.equals(true) &
              s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm(expression: s.name)]))
        .get();
  }

  /// Create supplier
  Future<int> createSupplier(SuppliersCompanion supplier) {
    return db.into(db.suppliers).insert(supplier);
  }

  /// Update supplier
  Future<bool> updateSupplier(Supplier supplier) {
    return db.update(db.suppliers).replace(supplier);
  }

  /// Update supplier payable
  Future<bool> updateSupplierPayable(int supplierId, int amount) {
    return (db.update(db.suppliers)..where((s) => s.id.equals(supplierId)))
        .write(SuppliersCompanion(currentPayable: Value(amount)));
  }

  /// Soft delete supplier
  Future<bool> softDeleteSupplier(int supplierId) {
    return (db.update(db.suppliers)..where((s) => s.id.equals(supplierId)))
        .write(SuppliersCompanion(deletedAt: Value(DateTime.now())));
  }
}
