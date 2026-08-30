import 'package:saudara_erp/core/constants/enum.dart';
import 'package:saudara_erp/core/errors/app_exceptions.dart';
import 'package:saudara_erp/core/utils/logger.dart';

class CalculationService {
  /// Calculate sale item subtotal based on calculation type
  static int calculateSubtotal({
    required CalculationType type,
    required int quantity,
    required int unitPrice,
    int? totalMeter,
  }) {
    try {
      switch (type) {
        case CalculationType.fixed:
          return quantity * unitPrice;
        case CalculationType.meter:
          if (totalMeter == null) {
            throw ValidationException(
              message: 'Total meter harus diisi untuk tipe meter',
              code: 'METER_REQUIRED',
            );
          }
          return totalMeter * unitPrice;
        case CalculationType.strip_meter:
          if (totalMeter == null) {
            throw ValidationException(
              message: 'Total meter harus diisi untuk tipe strip meter',
              code: 'METER_REQUIRED',
            );
          }
          return totalMeter * unitPrice;
      }
    } catch (e, st) {
      AppLogger.error('Error calculating subtotal', e, st);
      rethrow;
    }
  }

  /// Calculate total meter for strip meter
  /// Rumus: qty_sheet * length_per_sheet = total_meter
  static int calculateTotalMeterStripMeter({
    required int qtySheet,
    required int lengthPerSheet,
  }) {
    try {
      if (qtySheet <= 0) {
        throw ValidationException(
          message: 'Jumlah sheet harus lebih dari 0',
          code: 'INVALID_QUANTITY',
        );
      }
      if (lengthPerSheet <= 0) {
        throw ValidationException(
          message: 'Panjang per sheet harus lebih dari 0',
          code: 'INVALID_LENGTH',
        );
      }
      return qtySheet * lengthPerSheet;
    } catch (e, st) {
      AppLogger.error('Error calculating total meter', e, st);
      rethrow;
    }
  }

  /// Calculate discount total
  /// Rumus: quantity_or_meter * discount_per_unit
  static int calculateDiscountTotal({
    required CalculationType type,
    required int quantity,
    required int discountPerUnit,
    int? totalMeter,
  }) {
    try {
      if (discountPerUnit < 0) {
        throw ValidationException(
          message: 'Diskon tidak boleh negatif',
          code: 'INVALID_DISCOUNT',
        );
      }

      switch (type) {
        case CalculationType.fixed:
          return quantity * discountPerUnit;
        case CalculationType.meter:
        case CalculationType.strip_meter:
          if (totalMeter == null) {
            throw ValidationException(
              message: 'Total meter tidak valid untuk perhitungan diskon',
              code: 'METER_REQUIRED',
            );
          }
          return totalMeter * discountPerUnit;
      }
    } catch (e, st) {
      AppLogger.error('Error calculating discount total', e, st);
      rethrow;
    }
  }

  /// Calculate subtotal after discount
  static int calculateSubtotalAfterDiscount({
    required int subtotal,
    required int discountTotal,
  }) {
    try {
      final result = subtotal - discountTotal;
      if (result < 0) {
        throw BusinessException(
          message: 'Diskon tidak boleh melebihi subtotal',
          code: 'DISCOUNT_EXCEEDS_SUBTOTAL',
        );
      }
      return result;
    } catch (e, st) {
      AppLogger.error('Error calculating subtotal after discount', e, st);
      rethrow;
    }
  }

  /// Calculate total invoice
  /// Rumus: subtotal_after_discount + additional_cost - discount_amount
  static int calculateGrandTotal({
    required List<int> itemSubtotals,
    int discountAmount = 0,
    int additionalCost = 0,
  }) {
    try {
      if (discountAmount < 0) {
        throw ValidationException(
          message: 'Diskon invoice tidak boleh negatif',
          code: 'INVALID_DISCOUNT',
        );
      }
      if (additionalCost < 0) {
        throw ValidationException(
          message: 'Biaya tambahan tidak boleh negatif',
          code: 'INVALID_ADDITIONAL_COST',
        );
      }

      int subtotal = 0;
      for (final item in itemSubtotals) {
        subtotal += item;
      }

      final total = subtotal - discountAmount + additionalCost;
      if (total < 0) {
        throw BusinessException(
          message: 'Total tidak boleh negatif',
          code: 'INVALID_TOTAL',
        );
      }
      return total;
    } catch (e, st) {
      AppLogger.error('Error calculating grand total', e, st);
      rethrow;
    }
  }

  /// Calculate profit
  /// Rumus: selling_value - cost_value
  static int calculateProfit({
    required int sellingValue,
    required int costValue,
  }) {
    try {
      return sellingValue - costValue;
    } catch (e, st) {
      AppLogger.error('Error calculating profit', e, st);
      rethrow;
    }
  }

  /// Calculate profit margin percentage
  /// Rumus: (profit / selling_value) * 100
  static double calculateProfitMargin({
    required int profit,
    required int sellingValue,
  }) {
    try {
      if (sellingValue <= 0) {
        return 0.0;
      }
      return (profit / sellingValue) * 100;
    } catch (e, st) {
      AppLogger.error('Error calculating profit margin', e, st);
      return 0.0;
    }
  }
}
