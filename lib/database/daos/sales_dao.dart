import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/sales_table.dart';

class SalesDao {
  final AppDatabase db;

  SalesDao(this.db);

  /// Get sale by ID
  Future<Sale?> getSaleById(int id) {
    return (db.select(db.sales)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// Get sale by invoice number
  Future<Sale?> getSaleByInvoiceNumber(String invoiceNumber) {
    return (db.select(db.sales)..where((s) => s.invoiceNumber.equals(invoiceNumber)))
        .getSingleOrNull();
  }

  /// Get all sales for customer
  Future<List<Sale>> getSalesForCustomer(int customerId) {
    return (db.select(db.sales)
          ..where((s) => s.customerId.equals(customerId))
          ..orderBy([(s) => OrderingTerm(expression: s.saleDate, mode: OrderingMode.desc)]))
        .get();
  }

  /// Create sale
  Future<int> createSale(SalesCompanion sale) {
    return db.into(db.sales).insert(sale);
  }

  /// Update sale
  Future<bool> updateSale(Sale sale) {
    return db.update(db.sales).replace(sale);
  }

  /// Get sale items
  Future<List<SaleItem>> getSaleItems(int saleId) {
    return (db.select(db.saleItems)..where((si) => si.saleId.equals(saleId))).get();
  }

  /// Create sale item
  Future<int> createSaleItem(SaleItemsCompanion item) {
    return db.into(db.saleItems).insert(item);
  }

  /// Create sale payment
  Future<int> createSalePayment(SalePaymentsCompanion payment) {
    return db.into(db.salePayments).insert(payment);
  }

  /// Get sale payments
  Future<List<SalePayment>> getSalePayments(int saleId) {
    return (db.select(db.salePayments)..where((sp) => sp.saleId.equals(saleId))).get();
  }
}
