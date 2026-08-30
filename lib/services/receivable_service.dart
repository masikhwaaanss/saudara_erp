import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/daos/receivables_dao.dart';
import 'package:saudara_erp/database/daos/audit_logs_dao.dart';
import 'package:saudara_erp/database/daos/customers_dao.dart';
import 'package:saudara_erp/database/daos/expenses_dao.dart';
import 'package:saudara_erp/database/tables/receivables_table.dart';
import 'package:saudara_erp/core/constants/enum.dart';
import 'package:saudara_erp/core/errors/app_exceptions.dart';
import 'package:saudara_erp/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class ReceivableService {
  final AppDatabase db;
  late final ReceivablesDao receivablesDao;
  late final CustomersDao customersDao;
  late final AuditLogsDao auditLogsDao;
  late final CashTransactionsDao cashTransactionsDao;

  ReceivableService(this.db) {
    receivablesDao = ReceivablesDao(db);
    customersDao = CustomersDao(db);
    auditLogsDao = AuditLogsDao(db);
    cashTransactionsDao = CashTransactionsDao(db);
  }

  /// Get receivable by ID
  Future<Receivable?> getReceivableById(int id) async {
    try {
      return await receivablesDao.getReceivableById(id);
    } catch (e, st) {
      AppLogger.error('Error getting receivable', e, st);
      return null;
    }
  }

  /// Get all unpaid receivables
  Future<List<Receivable>> getUnpaidReceivables() async {
    try {
      final receivables = await receivablesDao.getUnpaidReceivables();
      // Update status for overdue items
      for (final receivable in receivables) {
        if (receivable.status != 'paid' && DateTime.now().isAfter(receivable.dueDate)) {
          // Update status to overdue
          await receivablesDao.updateReceivable(
            receivable.copyWith(status: 'overdue'),
          );
        }
      }
      return receivables;
    } catch (e, st) {
      AppLogger.error('Error getting unpaid receivables', e, st);
      return [];
    }
  }

  /// Record receivable payment (atomic transaction)
  Future<void> recordReceivablePayment({
    required int receivableId,
    required int customerId,
    required int paymentAmount,
    required int createdByUserId,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? referenceNumber,
    String? notes,
  }) async {
    return await db.transaction(() async {
      try {
        final receivable = await receivablesDao.getReceivableById(receivableId);
        if (receivable == null) {
          throw NotFoundException(
            message: 'Piutang tidak ditemukan',
          );
        }

        if (paymentAmount <= 0) {
          throw ValidationException(
            message: 'Jumlah pembayaran harus lebih dari 0',
            code: 'INVALID_PAYMENT_AMOUNT',
          );
        }

        if (paymentAmount > receivable.remainingAmount) {
          throw BusinessException(
            message: 'Pembayaran melebihi sisa piutang',
            code: 'PAYMENT_EXCEEDS_REMAINING',
          );
        }

        // Calculate new amounts
        final newPaidAmount = receivable.paidAmount + paymentAmount;
        final newRemainingAmount = receivable.remainingAmount - paymentAmount;

        // Determine new status
        String newStatus;
        if (newRemainingAmount <= 0) {
          newStatus = 'paid';
        } else if (newPaidAmount > 0) {
          newStatus = 'partial';
        } else {
          newStatus = 'unpaid';
        }

        // Update receivable
        await receivablesDao.updateReceivable(
          receivable.copyWith(
            paidAmount: newPaidAmount,
            remainingAmount: newRemainingAmount,
            status: newStatus,
            updatedAt: DateTime.now(),
          ),
        );

        // Record payment
        await receivablesDao.createReceivablePayment(
          ReceivablePaymentsCompanion(
            receivableId: Value(receivableId),
            customerId: Value(customerId),
            amount: Value(paymentAmount),
            paymentMethod: Value(paymentMethod.value),
            referenceNumber: Value(referenceNumber),
            paymentDate: Value(DateTime.now()),
            createdByUserId: Value(createdByUserId),
            notes: Value(notes),
          ),
        );

        // Record cash transaction
        final txNumber = 'TXN-${const Uuid().v4().substring(0, 8)}';
        await cashTransactionsDao.createCashTransaction(
          CashTransactionsCompanion(
            transactionNumber: Value(txNumber),
            type: Value('cash_in'),
            category: Value('receivable_payment'),
            amount: Value(paymentAmount),
            description: Value('Pembayaran Piutang - Receivable #$receivableId'),
            transactionDate: Value(DateTime.now()),
            referenceType: Value('receivable'),
            referenceId: Value(receivableId),
            createdByUserId: Value(createdByUserId),
          ),
        );

        // Update customer receivable balance
        final customer = await customersDao.getCustomerById(customerId);
        if (customer != null) {
          final newCustomerReceivable = (customer.currentReceivable - paymentAmount).toInt();
          await customersDao.updateCustomerReceivable(customerId, newCustomerReceivable);
        }

        // Create audit log
        await auditLogsDao.createAuditLog(
          AuditLogsCompanion(
            userId: Value(createdByUserId),
            action: Value(AuditAction.receivable_payment.value),
            entityType: Value('Receivable'),
            entityId: Value(receivableId),
            description: Value('Pembayaran Piutang: Rp $paymentAmount'),
          ),
        );

        AppLogger.success('Receivable payment recorded: Rp $paymentAmount');
      } catch (e, st) {
        AppLogger.error('Error recording receivable payment', e, st);
        rethrow;
      }
    });
  }

  /// Get receivables by customer
  Future<List<Receivable>> getReceivablesByCustomer(int customerId) async {
    try {
      return await receivablesDao.getReceivablesForCustomer(customerId);
    } catch (e, st) {
      AppLogger.error('Error getting receivables by customer', e, st);
      return [];
    }
  }
}
