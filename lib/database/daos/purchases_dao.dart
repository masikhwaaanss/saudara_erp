import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/purchases_table.dart';

class PurchasesDao {
  final AppDatabase db;

  PurchasesDao(this.db);

  /// Get purchase by ID
  Future<Purchase?> getPurchaseById(int id) {
    return (db.select(db.purchases)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Get purchase by number
  Future<Purchase?> getPurchaseByNumber(String purchaseNumber) {
    return (db.select(db.purchases)..where((p) => p.purchaseNumber.equals(purchaseNumber)))
        .getSingleOrNull();
  }

  /// Get all purchases for supplier
  Future<List<Purchase>> getPurchasesForSupplier(int supplierId) {
    return (db.select(db.purchases)
          ..where((p) => p.supplierId.equals(supplierId))
          ..orderBy([(p) => OrderingTerm(expression: p.purchaseDate, mode: OrderingMode.desc)]))
        .get();
  }

  /// Create purchase
  Future<int> createPurchase(PurchasesCompanion purchase) {
    return db.into(db.purchases).insert(purchase);
  }

  /// Update purchase
  Future<bool> updatePurchase(Purchase purchase) {
    return db.update(db.purchases).replace(purchase);
  }

  /// Get purchase items
  Future<List<PurchaseItem>> getPurchaseItems(int purchaseId) {
    return (db.select(db.purchaseItems)..where((pi) => pi.purchaseId.equals(purchaseId)))
        .get();
  }

  /// Create purchase item
  Future<int> createPurchaseItem(PurchaseItemsCompanion item) {
    return db.into(db.purchaseItems).insert(item);
  }

  /// Create purchase payment
  Future<int> createPurchasePayment(PurchasePaymentsCompanion payment) {
    return db.into(db.purchasePayments).insert(payment);
  }

  /// Get purchase payments
  Future<List<PurchasePayment>> getPurchasePayments(int purchaseId) {
    return (db.select(db.purchasePayments)..where((pp) => pp.purchaseId.equals(purchaseId)))
        .get();
  }
}
