import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/receivables_table.dart';

class ReceivablesDao {
  final AppDatabase db;

  ReceivablesDao(this.db);

  /// Get receivable by ID
  Future<Receivable?> getReceivableById(int id) {
    return (db.select(db.receivables)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  /// Get receivable by sale ID
  Future<Receivable?> getReceivableBySaleId(int saleId) {
    return (db.select(db.receivables)..where((r) => r.saleId.equals(saleId))).getSingleOrNull();
  }

  /// Get all receivables for customer
  Future<List<Receivable>> getReceivablesForCustomer(int customerId) {
    return (db.select(db.receivables)
          ..where((r) => r.customerId.equals(customerId))
          ..orderBy([(r) => OrderingTerm(expression: r.dueDate)]))
        .get();
  }

  /// Get all unpaid receivables
  Future<List<Receivable>> getUnpaidReceivables() {
    return (db.select(db.receivables)
          ..where((r) => r.status.isIn(['unpaid', 'partial', 'overdue']))
          ..orderBy([(r) => OrderingTerm(expression: r.dueDate)]))
        .get();
  }

  /// Create receivable
  Future<int> createReceivable(ReceivablesCompanion receivable) {
    return db.into(db.receivables).insert(receivable);
  }

  /// Update receivable
  Future<bool> updateReceivable(Receivable receivable) {
    return db.update(db.receivables).replace(receivable);
  }

  /// Create receivable payment
  Future<int> createReceivablePayment(ReceivablePaymentsCompanion payment) {
    return db.into(db.receivablePayments).insert(payment);
  }

  /// Get receivable payments
  Future<List<ReceivablePayment>> getReceivablePayments(int receivableId) {
    return (db.select(db.receivablePayments)..where((rp) => rp.receivableId.equals(receivableId)))
        .get();
  }
}
