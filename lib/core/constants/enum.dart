/// User Roles
enum UserRole {
  owner,
  admin_1,
  admin_2,
  gudang,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.admin_1:
        return 'Admin 1';
      case UserRole.admin_2:
        return 'Admin 2';
      case UserRole.gudang:
        return 'Gudang';
    }
  }

  String get value {
    return name;
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.gudang,
    );
  }
}

/// Price Types
enum PriceType {
  buyer,
  applicator,
  agent,
}

extension PriceTypeExtension on PriceType {
  String get displayName {
    switch (this) {
      case PriceType.buyer:
        return 'Buyer';
      case PriceType.applicator:
        return 'Applicator';
      case PriceType.agent:
        return 'Agent';
    }
  }

  String get value {
    return name;
  }

  static PriceType fromString(String value) {
    return PriceType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => PriceType.buyer,
    );
  }
}

/// Calculation Types
enum CalculationType {
  fixed,
  meter,
  strip_meter,
}

extension CalculationTypeExtension on CalculationType {
  String get displayName {
    switch (this) {
      case CalculationType.fixed:
        return 'Fixed';
      case CalculationType.meter:
        return 'Meter';
      case CalculationType.strip_meter:
        return 'Strip Meter';
    }
  }

  String get value {
    return name;
  }

  static CalculationType fromString(String value) {
    return CalculationType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => CalculationType.fixed,
    );
  }
}

/// Payment Status
enum PaymentStatus {
  unpaid,
  partial,
  paid,
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Belum Dibayar';
      case PaymentStatus.partial:
        return 'Sebagian Dibayar';
      case PaymentStatus.paid:
        return 'Lunas';
    }
  }

  String get value {
    return name;
  }

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }
}

/// Payment Method
enum PaymentMethod {
  cash,
  transfer,
  credit,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer';
      case PaymentMethod.credit:
        return 'Kredit';
    }
  }

  String get value {
    return name;
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// Stock Movement Type
enum StockMovementType {
  purchase_in,
  sale_out,
  sale_return,
  purchase_return,
  adjustment_in,
  adjustment_out,
  opening_balance,
}

extension StockMovementTypeExtension on StockMovementType {
  String get displayName {
    switch (this) {
      case StockMovementType.purchase_in:
        return 'Pembelian Masuk';
      case StockMovementType.sale_out:
        return 'Penjualan Keluar';
      case StockMovementType.sale_return:
        return 'Retur Penjualan';
      case StockMovementType.purchase_return:
        return 'Retur Pembelian';
      case StockMovementType.adjustment_in:
        return 'Penyesuaian Masuk';
      case StockMovementType.adjustment_out:
        return 'Penyesuaian Keluar';
      case StockMovementType.opening_balance:
        return 'Stok Awal';
    }
  }

  String get value {
    return name;
  }

  static StockMovementType fromString(String value) {
    return StockMovementType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => StockMovementType.opening_balance,
    );
  }
}

/// Delivery Note Status
enum DeliveryNoteStatus {
  draft,
  issued,
  delivered,
  cancelled,
}

extension DeliveryNoteStatusExtension on DeliveryNoteStatus {
  String get displayName {
    switch (this) {
      case DeliveryNoteStatus.draft:
        return 'Draft';
      case DeliveryNoteStatus.issued:
        return 'Diterbitkan';
      case DeliveryNoteStatus.delivered:
        return 'Dikirim';
      case DeliveryNoteStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  String get value {
    return name;
  }

  static DeliveryNoteStatus fromString(String value) {
    return DeliveryNoteStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => DeliveryNoteStatus.draft,
    );
  }
}

/// Action Type for Audit Log
enum AuditAction {
  login,
  logout,
  create,
  update,
  delete,
  sale,
  payment,
  purchase,
  stock_adjustment,
  receivable_payment,
  expense,
  print,
  download,
}

extension AuditActionExtension on AuditAction {
  String get displayName {
    switch (this) {
      case AuditAction.login:
        return 'Login';
      case AuditAction.logout:
        return 'Logout';
      case AuditAction.create:
        return 'Buat';
      case AuditAction.update:
        return 'Update';
      case AuditAction.delete:
        return 'Hapus';
      case AuditAction.sale:
        return 'Penjualan';
      case AuditAction.payment:
        return 'Pembayaran';
      case AuditAction.purchase:
        return 'Pembelian';
      case AuditAction.stock_adjustment:
        return 'Penyesuaian Stok';
      case AuditAction.receivable_payment:
        return 'Pembayaran Piutang';
      case AuditAction.expense:
        return 'Pengeluaran';
      case AuditAction.print:
        return 'Print';
      case AuditAction.download:
        return 'Download';
    }
  }

  String get value {
    return name;
  }

  static AuditAction fromString(String value) {
    return AuditAction.values.firstWhere(
      (action) => action.name == value,
      orElse: () => AuditAction.create,
    );
  }
}

/// Expense Category
enum ExpenseCategory {
  operasional,
  transportasi,
  listrik,
  gaji,
  perawatan,
  lainnya,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.operasional:
        return 'Operasional';
      case ExpenseCategory.transportasi:
        return 'Transportasi';
      case ExpenseCategory.listrik:
        return 'Listrik';
      case ExpenseCategory.gaji:
        return 'Gaji';
      case ExpenseCategory.perawatan:
        return 'Perawatan';
      case ExpenseCategory.lainnya:
        return 'Lainnya';
    }
  }

  String get value {
    return name;
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => ExpenseCategory.lainnya,
    );
  }
}
