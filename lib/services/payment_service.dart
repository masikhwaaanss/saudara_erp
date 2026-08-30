import 'package:saudara_erp/core/constants/enum.dart';
import 'package:saudara_erp/core/errors/app_exceptions.dart';
import 'package:saudara_erp/core/utils/logger.dart';

class PaymentService {
  /// Determine payment status based on paid amount vs grand total
  static PaymentStatus determinePaymentStatus({
    required int grandTotal,
    required int totalPaid,
  }) {
    try {
      if (totalPaid <= 0) {
        return PaymentStatus.unpaid;
      } else if (totalPaid >= grandTotal) {
        return PaymentStatus.paid;
      } else {
        return PaymentStatus.partial;
      }
    } catch (e, st) {
      AppLogger.error('Error determining payment status', e, st);
      return PaymentStatus.unpaid;
    }
  }

  /// Calculate remaining amount
  static int calculateRemainingAmount({
    required int grandTotal,
    required int totalPaid,
  }) {
    try {
      final remaining = grandTotal - totalPaid;
      if (remaining < 0) {
        throw BusinessException(
          message: 'Pembayaran tidak boleh melebihi total invoice',
          code: 'PAYMENT_EXCEEDS_TOTAL',
        );
      }
      return remaining;
    } catch (e, st) {
      AppLogger.error('Error calculating remaining amount', e, st);
      rethrow;
    }
  }

  /// Validate payment amount
  static void validatePaymentAmount({
    required int paymentAmount,
    required int remainingAmount,
  }) {
    try {
      if (paymentAmount <= 0) {
        throw ValidationException(
          message: 'Jumlah pembayaran harus lebih dari 0',
          code: 'INVALID_PAYMENT_AMOUNT',
        );
      }
      if (paymentAmount > remainingAmount) {
        throw BusinessException(
          message: 'Pembayaran melebihi sisa tagihan',
          code: 'PAYMENT_EXCEEDS_REMAINING',
        );
      }
    } catch (e, st) {
      AppLogger.error('Error validating payment amount', e, st);
      rethrow;
    }
  }

  /// Check if payment is complete
  static bool isPaymentComplete({
    required int grandTotal,
    required int totalPaid,
  }) {
    try {
      return totalPaid >= grandTotal;
    } catch (e, st) {
      AppLogger.error('Error checking payment complete', e, st);
      return false;
    }
  }
}
