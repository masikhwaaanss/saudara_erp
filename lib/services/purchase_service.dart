import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/daos/purchases_dao.dart';
import 'package:saudara_erp/database/daos/products_dao.dart';
import 'package:saudara_erp/database/daos/audit_logs_dao.dart';
import 'package:saudara_erp/database/daos/expenses_dao.dart';
import 'package:saudara_erp/database/tables/purchases_table.dart';
import 'package:saudara_erp/services/stock_service.dart';
import 'package:saudara_erp/core/constants/enum.dart';
import 'package:saudara_erp/core/constants/app_constants.dart';
import 'package:saudara_erp/core/errors/app_exceptions.dart';
import 'package:saudara_erp/core/utils/logger.dart';

class PurchaseService {
  final AppDatabase db;
  late final PurchasesDao purchasesDao;
  late final ProductsDao productsDao;
  late final StockService stockService;
  late final CashTransactionsDao cashTransactionsDao;
  late final AuditLogsDao auditLogsDao;

  PurchaseService(this.db) {
    purchasesDao = PurchasesDao(db);
    productsDao = ProductsDao(db);
    stockService = StockService(db);
    cashTransactionsDao = CashTransactionsDao(db);
    auditLogsDao = AuditLogsDao(db);
  }

  /// Generate purchase number
  Future<String> generatePurchaseNumber() async {
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      final countToday = await db.customSelect(
        'SELECT COUNT(*) as count FROM purchases WHERE purchase_number LIKE ?',
        variables: ['PO-$dateStr-%'],
        readsFrom: {db.purchases},
      ).getSingle();
      final count = countToday.read<int>('count');
      final nextNumber = (count + 1).toString().padLeft(4, '0');
      return 'PO-$dateStr-$nextNumber';
    } catch (e, st) {
      AppLogger.error('Error generating purchase number', e, st);
      throw DatabaseException(
        message: 'Gagal generate nomor pembelian',
        originalException: e,
      );
    }
  }

  /// Create purchase (atomic transaction)
  Future<Purchase> createPurchase({
    required int supplierId,
    required List<PurchaseItemData> items,
    required int createdByUserId,
    int discountAmount = 0,
    int additionalCost = 0,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    int paidAmount = 0,
    String? notes,
  }) async {
    return await db.transaction(() async {
      try {
        int totalSubtotal = 0;

        // Validate all items
        for (final item in items) {
          final product = await productsDao.getProductById(item.productId);
          if (product == null) {
            throw NotFoundException(
              message: 'Produk tidak ditemukan',
            );
          }
        }

        // Calculate totals
        for (final item in items) {
          final subtotal = item.quantity * item.unitPrice;
          final discountTotal = item.quantity * item.discountPerUnit;
          final subtotalAfterDiscount = subtotal - discountTotal;
          totalSubtotal += subtotalAfterDiscount;
        }

        final grandTotal = totalSubtotal - discountAmount + additionalCost;

        if (grandTotal < 0) {
          throw BusinessException(
            message: 'Total pembelian tidak boleh negatif',
            code: 'INVALID_TOTAL',
          );
        }

        // Validate payment
        if (paidAmount > grandTotal && paymentMethod != PaymentMethod.credit) {
          throw BusinessException(
            message: 'Pembayaran tidak boleh melebihi total',
            code: 'PAYMENT_EXCEEDS_TOTAL',
          );
        }

        // Generate purchase number
        final purchaseNumber = await generatePurchaseNumber();

        // Determine payment status
        final paymentStatus = paymentMethod == PaymentMethod.credit
            ? PaymentStatus.unpaid
            : (paidAmount >= grandTotal ? PaymentStatus.paid : PaymentStatus.partial);

        // Create purchase
        final purchaseId = await purchasesDao.createPurchase(
          PurchasesCompanion(
            purchaseNumber: Value(purchaseNumber),
            supplierId: Value(supplierId),
            purchaseDate: Value(DateTime.now()),
            paymentMethod: Value(paymentMethod.value),
            paymentStatus: Value(paymentStatus.value),
            subtotal: Value(totalSubtotal),
            discountAmount: Value(discountAmount),
            additionalCost: Value(additionalCost),
            grandTotal: Value(grandTotal),
            paidAmount: Value(paidAmount),
            remainingAmount: Value(grandTotal - paidAmount),
            dueDate: Value(paymentMethod == PaymentMethod.credit
                ? DateTime.now().add(Duration(days: 30))
                : null),
            notes: Value(notes),
            createdByUserId: Value(createdByUserId),
            isCancelled: const Value(false),
          ),
        );

        // Create purchase items and adjust stock
        for (final item in items) {
          final subtotal = item.quantity * item.unitPrice;
          final discountTotal = item.quantity * item.discountPerUnit;
          final subtotalAfterDiscount = subtotal - discountTotal;

          await purchasesDao.createPurchaseItem(
            PurchaseItemsCompanion(
              purchaseId: Value(purchaseId),
              productId: Value(item.productId),
              quantity: Value(item.quantity),
              unitPrice: Value(item.unitPrice),
              subtotal: Value(subtotal),
              discountPerUnit: Value(item.discountPerUnit),
              discountTotal: Value(discountTotal),
              subtotalAfterDiscount: Value(subtotalAfterDiscount),
            ),
          );

          // Adjust stock
          await stockService.adjustStockBalance(
            productId: item.productId,
            quantityChange: item.quantity,
            movementType: StockMovementType.purchase_in,
            createdByUserId: createdByUserId,
            referenceType: 'purchase',
            referenceId: purchaseId,
          );
        }

        // Record payment if paid
        if (paidAmount > 0) {
          await purchasesDao.createPurchasePayment(
            PurchasePaymentsCompanion(
              purchaseId: Value(purchaseId),
              paymentMethod: Value(paymentMethod.value),
              amount: Value(paidAmount),
              paymentDate: Value(DateTime.now()),
              createdByUserId: Value(createdByUserId),
            ),
          );

          // Record cash transaction
          final txNumber = 'TXN-${const Uuid().v4().substring(0, 8)}';
          await cashTransactionsDao.createCashTransaction(
            CashTransactionsCompanion(
              transactionNumber: Value(txNumber),
              type: Value('cash_out'),
              category: Value('purchase_payment'),
              amount: Value(paidAmount),
              description: Value('Pembayaran Pembelian $purchaseNumber'),
              transactionDate: Value(DateTime.now()),
              referenceType: Value('purchase'),
              referenceId: Value(purchaseId),
              createdByUserId: Value(createdByUserId),
            ),
          );
        }

        // Create audit log
        await auditLogsDao.createAuditLog(
          AuditLogsCompanion(
            userId: Value(createdByUserId),
            action: Value(AuditAction.purchase.value),
            entityType: Value('Purchase'),
            entityId: Value(purchaseId),
            description: Value('Pembelian dibuat: $purchaseNumber - Total: $grandTotal'),
            newValues: Value(jsonEncode({
              'purchaseNumber': purchaseNumber,
              'grandTotal': grandTotal,
              'itemCount': items.length,
            })),
          ),
        );

        final purchase = await purchasesDao.getPurchaseById(purchaseId);
        if (purchase == null) {
          throw DatabaseException(
            message: 'Gagal membuat pembelian',
          );
        }

        AppLogger.success('Purchase created successfully: $purchaseNumber');
        return purchase;
      } catch (e, st) {
        AppLogger.error('Error creating purchase', e, st);
        rethrow;
      }
    });
  }

  /// Get purchase by ID
  Future<Purchase?> getPurchaseById(int id) async {
    try {
      return await purchasesDao.getPurchaseById(id);
    } catch (e, st) {
      AppLogger.error('Error getting purchase', e, st);
      return null;
    }
  }
}

class PurchaseItemData {
  final int productId;
  final int quantity;
  final int unitPrice;
  final int discountPerUnit;

  PurchaseItemData({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.discountPerUnit = 0,
  });
}
