import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/daos/sales_dao.dart';
import 'package:saudara_erp/database/daos/products_dao.dart';
import 'package:saudara_erp/database/daos/audit_logs_dao.dart';
import 'package:saudara_erp/database/daos/expenses_dao.dart';
import 'package:saudara_erp/database/tables/sales_table.dart';
import 'package:saudara_erp/services/calculation_service.dart';
import 'package:saudara_erp/services/stock_service.dart';
import 'package:saudara_erp/core/constants/enum.dart';
import 'package:saudara_erp/core/constants/app_constants.dart';
import 'package:saudara_erp/core/errors/app_exceptions.dart';
import 'package:saudara_erp/core/utils/logger.dart';

class SalesService {
  final AppDatabase db;
  late final SalesDao salesDao;
  late final ProductsDao productsDao;
  late final StockService stockService;
  late final CashTransactionsDao cashTransactionsDao;
  late final AuditLogsDao auditLogsDao;

  SalesService(this.db) {
    salesDao = SalesDao(db);
    productsDao = ProductsDao(db);
    stockService = StockService(db);
    cashTransactionsDao = CashTransactionsDao(db);
    auditLogsDao = AuditLogsDao(db);
  }

  /// Generate invoice number
  Future<String> generateInvoiceNumber() async {
    try {
      final today = DateTime.now();
      final dateStr = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      final countToday = await db.customSelect(
        'SELECT COUNT(*) as count FROM sales WHERE invoice_number LIKE ?',
        variables: ['${AppConstants.invoicePrefix}-$dateStr-%'],
        readsFrom: {db.sales},
      ).getSingle();
      final count = countToday.read<int>('count');
      final nextNumber = (count + 1).toString().padLeft(4, '0');
      return '${AppConstants.invoicePrefix}-$dateStr-$nextNumber';
    } catch (e, st) {
      AppLogger.error('Error generating invoice number', e, st);
      throw DatabaseException(
        message: 'Gagal generate nomor invoice',
        originalException: e,
      );
    }
  }

  /// Create sale (atomic transaction)
  Future<Sale> createSale({
    required int customerId,
    required List<SaleItemData> items,
    required int createdByUserId,
    int discountAmount = 0,
    int additionalCost = 0,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    int paidAmount = 0,
    String? notes,
  }) async {
    return await db.transaction(() async {
      try {
        // Validate all items and calculate subtotals
        List<SaleItemCalculated> calculatedItems = [];
        int totalSubtotal = 0;

        for (final item in items) {
          // Get product
          final product = await productsDao.getProductById(item.productId);
          if (product == null) {
            throw NotFoundException(
              message: 'Produk tidak ditemukan',
            );
          }

          // Validate stock
          await stockService.validateStockAvailability(item.productId, item.quantity);

          // Get price based on price type
          final price = _getPriceByType(product, item.priceType);

          // Calculate subtotal
          final subtotal = CalculationService.calculateSubtotal(
            type: product.calculationType as dynamic,
            quantity: item.quantity,
            unitPrice: price,
            totalMeter: item.totalMeter,
          );

          // Calculate discount
          final discountTotal = CalculationService.calculateDiscountTotal(
            type: product.calculationType as dynamic,
            quantity: item.quantity,
            discountPerUnit: item.discountPerUnit,
            totalMeter: item.totalMeter,
          );

          final subtotalAfterDiscount = CalculationService.calculateSubtotalAfterDiscount(
            subtotal: subtotal,
            discountTotal: discountTotal,
          );

          calculatedItems.add(
            SaleItemCalculated(
              productId: item.productId,
              calculationType: product.calculationType,
              quantity: item.quantity,
              totalMeter: item.totalMeter,
              lengthPerSheet: item.lengthPerSheet,
              sellingUnitPrice: price,
              subtotalBeforeDiscount: subtotal,
              discountPerUnit: item.discountPerUnit,
              discountTotal: discountTotal,
              subtotalAfterDiscount: subtotalAfterDiscount,
              costPrice: product.costPrice,
            ),
          );

          totalSubtotal += subtotalAfterDiscount;
        }

        // Calculate grand total
        final itemSubtotals =
            calculatedItems.map((item) => item.subtotalAfterDiscount).toList();
        final grandTotal = CalculationService.calculateGrandTotal(
          itemSubtotals: itemSubtotals,
          discountAmount: discountAmount,
          additionalCost: additionalCost,
        );

        // Validate payment
        if (paidAmount > grandTotal && paymentMethod != PaymentMethod.credit) {
          throw BusinessException(
            message: 'Pembayaran tidak boleh melebihi total',
            code: 'PAYMENT_EXCEEDS_TOTAL',
          );
        }

        // Generate invoice number
        final invoiceNumber = await generateInvoiceNumber();

        // Determine payment status
        final paymentStatus = paymentMethod == PaymentMethod.credit
            ? PaymentStatus.unpaid
            : (paidAmount >= grandTotal ? PaymentStatus.paid : PaymentStatus.partial);

        // Create sale
        final saleId = await salesDao.createSale(
          SalesCompanion(
            invoiceNumber: Value(invoiceNumber),
            customerId: Value(customerId),
            saleDate: Value(DateTime.now()),
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

        // Create sale items and adjust stock
        for (final item in calculatedItems) {
          await salesDao.createSaleItem(
            SaleItemsCompanion(
              saleId: Value(saleId),
              productId: Value(item.productId),
              calculationType: Value(item.calculationType),
              quantity: Value(item.quantity),
              totalMeter: Value(item.totalMeter),
              lengthPerSheet: Value(item.lengthPerSheet),
              sellingUnitPrice: Value(item.sellingUnitPrice),
              subtotalBeforeDiscount: Value(item.subtotalBeforeDiscount),
              discountPerUnit: Value(item.discountPerUnit),
              discountTotal: Value(item.discountTotal),
              subtotalAfterDiscount: Value(item.subtotalAfterDiscount),
            ),
          );

          // Adjust stock
          await stockService.adjustStockBalance(
            productId: item.productId,
            quantityChange: item.quantity,
            movementType: StockMovementType.sale_out,
            createdByUserId: createdByUserId,
            referenceType: 'sale',
            referenceId: saleId,
          );
        }

        // Record payment if paid
        if (paidAmount > 0) {
          await salesDao.createSalePayment(
            SalePaymentsCompanion(
              saleId: Value(saleId),
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
              type: Value('cash_in'),
              category: Value('sale_payment'),
              amount: Value(paidAmount),
              description: Value('Pembayaran Penjualan $invoiceNumber'),
              transactionDate: Value(DateTime.now()),
              referenceType: Value('sale'),
              referenceId: Value(saleId),
              createdByUserId: Value(createdByUserId),
            ),
          );
        }

        // Create receivable if credit
        if (paymentMethod == PaymentMethod.credit) {
          await db.into(db.receivables).insert(
            ReceivablesCompanion(
              saleId: Value(saleId),
              customerId: Value(customerId),
              originalAmount: Value(grandTotal),
              remainingAmount: Value(grandTotal),
              dueDate: Value(DateTime.now().add(const Duration(days: 30))),
              status: const Value('unpaid'),
            ),
          );
        }

        // Create audit log
        await auditLogsDao.createAuditLog(
          AuditLogsCompanion(
            userId: Value(createdByUserId),
            action: Value(AuditAction.sale.value),
            entityType: Value('Sale'),
            entityId: Value(saleId),
            description: Value('Penjualan dibuat: $invoiceNumber - Total: $grandTotal'),
            newValues: Value(jsonEncode({
              'invoiceNumber': invoiceNumber,
              'grandTotal': grandTotal,
              'itemCount': calculatedItems.length,
            })),
          ),
        );

        final sale = await salesDao.getSaleById(saleId);
        if (sale == null) {
          throw DatabaseException(
            message: 'Gagal membuat penjualan',
          );
        }

        AppLogger.success('Sale created successfully: $invoiceNumber');
        return sale;
      } catch (e, st) {
        AppLogger.error('Error creating sale', e, st);
        rethrow;
      }
    });
  }

  /// Get price based on price type
  int _getPriceByType(Product product, PriceType priceType) {
    switch (priceType) {
      case PriceType.buyer:
        return product.buyerPrice;
      case PriceType.applicator:
        return product.applicatorPrice;
      case PriceType.agent:
        return product.agentPrice;
    }
  }

  /// Get sale by ID
  Future<Sale?> getSaleById(int id) async {
    try {
      return await salesDao.getSaleById(id);
    } catch (e, st) {
      AppLogger.error('Error getting sale', e, st);
      return null;
    }
  }
}

class SaleItemData {
  final int productId;
  final int quantity;
  final int totalMeter;
  final int lengthPerSheet;
  final PriceType priceType;
  final int discountPerUnit;

  SaleItemData({
    required this.productId,
    required this.quantity,
    this.totalMeter = 0,
    this.lengthPerSheet = 0,
    this.priceType = PriceType.buyer,
    this.discountPerUnit = 0,
  });
}

class SaleItemCalculated {
  final int productId;
  final String calculationType;
  final int quantity;
  final int? totalMeter;
  final int? lengthPerSheet;
  final int sellingUnitPrice;
  final int subtotalBeforeDiscount;
  final int discountPerUnit;
  final int discountTotal;
  final int subtotalAfterDiscount;
  final int costPrice;

  SaleItemCalculated({
    required this.productId,
    required this.calculationType,
    required this.quantity,
    this.totalMeter,
    this.lengthPerSheet,
    required this.sellingUnitPrice,
    required this.subtotalBeforeDiscount,
    required this.discountPerUnit,
    required this.discountTotal,
    required this.subtotalAfterDiscount,
    required this.costPrice,
  });
}
