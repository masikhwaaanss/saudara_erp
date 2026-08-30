import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/daos/stock_dao.dart';
import 'package:saudara_erp/database/tables/stock_tables.dart';
import 'package:saudara_erp/core/constants/enum.dart';
import 'package:saudara_erp/core/constants/app_constants.dart';
import 'package:saudara_erp/core/errors/app_exceptions.dart';
import 'package:saudara_erp/core/utils/logger.dart';

class StockService {
  final AppDatabase db;
  late final StockDao stockDao;

  StockService(this.db) {
    stockDao = StockDao(db);
  }

  /// Get current stock balance
  Future<int> getCurrentStock(int productId) async {
    try {
      final balance = await stockDao.getStockBalance(productId);
      return balance?.quantity ?? 0;
    } catch (e, st) {
      AppLogger.error('Error getting current stock', e, st);
      return 0;
    }
  }

  /// Validate stock availability
  Future<bool> validateStockAvailability(int productId, int quantity) async {
    try {
      final currentStock = await getCurrentStock(productId);
      if (currentStock < quantity) {
        throw BusinessException(
          message: 'Stok produk tidak mencukupi. Stok tersedia: $currentStock',
          code: 'INSUFFICIENT_STOCK',
        );
      }
      return true;
    } catch (e, st) {
      AppLogger.error('Error validating stock', e, st);
      rethrow;
    }
  }

  /// Record stock movement
  Future<void> recordStockMovement({
    required int productId,
    required int quantity,
    required StockMovementType movementType,
    required int createdByUserId,
    String? referenceType,
    int? referenceId,
    String? notes,
  }) async {
    try {
      await stockDao.createStockMovement(
        StockMovementsCompanion(
          productId: Value(productId),
          quantity: Value(quantity),
          movementType: Value(movementType.value),
          referenceType: Value(referenceType),
          referenceId: Value(referenceId),
          movementDate: Value(DateTime.now()),
          createdByUserId: Value(createdByUserId),
          notes: Value(notes),
        ),
      );

      AppLogger.info('Stock movement recorded: $productId - $movementType - $quantity');
    } catch (e, st) {
      AppLogger.error('Error recording stock movement', e, st);
      rethrow;
    }
  }

  /// Adjust stock balance
  Future<void> adjustStockBalance({
    required int productId,
    required int quantityChange,
    required StockMovementType movementType,
    required int createdByUserId,
    String? referenceType,
    int? referenceId,
    String? notes,
  }) async {
    try {
      // Get current balance
      final balance = await stockDao.getStockBalance(productId);
      int newQuantity = balance?.quantity ?? 0;

      // Calculate new quantity based on movement type
      if (movementType == StockMovementType.purchase_in ||
          movementType == StockMovementType.sale_return ||
          movementType == StockMovementType.adjustment_in ||
          movementType == StockMovementType.opening_balance) {
        newQuantity += quantityChange;
      } else if (movementType == StockMovementType.sale_out ||
          movementType == StockMovementType.purchase_return ||
          movementType == StockMovementType.adjustment_out) {
        newQuantity -= quantityChange;
      }

      // Check if negative stock is allowed
      if (newQuantity < 0 && !AppConstants.allowNegativeStock) {
        throw BusinessException(
          message: 'Stok tidak boleh negatif',
          code: 'NEGATIVE_STOCK_NOT_ALLOWED',
        );
      }

      // Update or create balance
      if (balance == null) {
        await stockDao.createStockBalance(
          StockBalancesCompanion(
            productId: Value(productId),
            quantity: Value(newQuantity),
            lastUpdated: Value(DateTime.now()),
          ),
        );
      } else {
        await stockDao.updateStockBalance(productId, newQuantity);
      }

      // Record movement
      await recordStockMovement(
        productId: productId,
        quantity: quantityChange,
        movementType: movementType,
        createdByUserId: createdByUserId,
        referenceType: referenceType,
        referenceId: referenceId,
        notes: notes,
      );

      AppLogger.success('Stock adjusted: $productId - New Quantity: $newQuantity');
    } catch (e, st) {
      AppLogger.error('Error adjusting stock balance', e, st);
      rethrow;
    }
  }

  /// Get stock movement history
  Future<List<StockMovement>> getStockMovementHistory(int productId) async {
    try {
      return await stockDao.getStockMovementHistory(productId);
    } catch (e, st) {
      AppLogger.error('Error getting stock movement history', e, st);
      return [];
    }
  }
}
