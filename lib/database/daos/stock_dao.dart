import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/stock_tables.dart';

class StockDao {
  final AppDatabase db;

  StockDao(this.db);

  /// Get stock balance for product
  Future<StockBalance?> getStockBalance(int productId) {
    return (db.select(db.stockBalances)..where((sb) => sb.productId.equals(productId)))
        .getSingleOrNull();
  }

  /// Get all stock balances
  Future<List<StockBalance>> getAllStockBalances() {
    return db.select(db.stockBalances).get();
  }

  /// Create stock balance
  Future<int> createStockBalance(StockBalancesCompanion stockBalance) {
    return db.into(db.stockBalances).insert(stockBalance);
  }

  /// Update stock balance
  Future<bool> updateStockBalance(int productId, int quantity) {
    return (db.update(db.stockBalances)..where((sb) => sb.productId.equals(productId)))
        .write(StockBalancesCompanion(
          quantity: Value(quantity),
          lastUpdated: Value(DateTime.now()),
        ));
  }

  /// Get stock movement history
  Future<List<StockMovement>> getStockMovementHistory(int productId) {
    return (db.select(db.stockMovements)
          ..where((sm) => sm.productId.equals(productId))
          ..orderBy([(sm) => OrderingTerm(expression: sm.movementDate, mode: OrderingMode.desc)]))
        .get();
  }

  /// Create stock movement
  Future<int> createStockMovement(StockMovementsCompanion movement) {
    return db.into(db.stockMovements).insert(movement);
  }

  /// Get stock movements for reference (sale, purchase, etc)
  Future<List<StockMovement>> getStockMovementsByReference(
      String referenceType, int referenceId) {
    return (db.select(db.stockMovements)
          ..where((sm) =>
              sm.referenceType.equals(referenceType) & sm.referenceId.equals(referenceId)))
        .get();
  }
}
