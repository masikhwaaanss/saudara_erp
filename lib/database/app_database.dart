import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:saudara_erp/database/tables/users_table.dart';
import 'package:saudara_erp/database/tables/products_table.dart';
import 'package:saudara_erp/database/tables/customers_table.dart';
import 'package:saudara_erp/database/tables/suppliers_table.dart';
import 'package:saudara_erp/database/tables/sales_table.dart';
import 'package:saudara_erp/database/tables/invoices_table.dart';
import 'package:saudara_erp/database/tables/delivery_notes_table.dart';
import 'package:saudara_erp/database/tables/purchases_table.dart';
import 'package:saudara_erp/database/tables/stock_tables.dart';
import 'package:saudara_erp/database/tables/receivables_table.dart';
import 'package:saudara_erp/database/tables/expenses_table.dart';
import 'package:saudara_erp/database/tables/cash_transactions_table.dart';
import 'package:saudara_erp/database/tables/audit_logs_table.dart';
import 'package:saudara_erp/database/tables/app_settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    ProductCategories,
    ProductUnits,
    Products,
    Customers,
    Suppliers,
    Sales,
    SaleItems,
    SalePayments,
    Invoices,
    DeliveryNotes,
    DeliveryNoteItems,
    Purchases,
    PurchaseItems,
    PurchasePayments,
    StockBalances,
    StockMovements,
    Receivables,
    ReceivablePayments,
    Expenses,
    CashTransactions,
    AuditLogs,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static AppDatabase? _instance;

  factory AppDatabase() {
    return _instance ??= AppDatabase._internal();
  }

  AppDatabase._internal() : super(_openConnection());

  /// Test database instance
  static AppDatabase test() {
    return AppDatabase._testInternal();
  }

  AppDatabase._testInternal() : super(_testConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Seed initial data
      await _seedInitialData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle future migrations here
    },
  );

  Future<void> _seedInitialData() async {
    // Seed default categories
    await into(productCategories).insert(
      const ProductCategoriesCompanion(
        name: Value('Umum'),
        description: Value('Kategori produk umum'),
        isActive: Value(true),
      ),
    );

    // Seed default units
    await into(productUnits).insert(
      const ProductUnitsCompanion(
        name: Value('Lembar'),
        symbol: Value('lbr'),
        description: Value('Satuan lembar'),
      ),
    );

    // Seed default customer
    await into(customers).insert(
      const CustomersCompanion(
        code: Value('CUST-0001'),
        name: Value('Walk-in Customer'),
        email: Value(''),
        phone: Value('-'),
        address: Value(''),
        creditLimit: Value(0),
        currentReceivable: Value(0),
        isActive: Value(true),
      ),
    );

    // Seed app settings
    await into(appSettings).insert(
      const AppSettingsCompanion(
        key: Value('company_name'),
        value: Value('SAUDARA PLAFON PVC METESEH'),
        description: Value('Nama perusahaan'),
      ),
    );

    await into(appSettings).insert(
      const AppSettingsCompanion(
        key: Value('company_address'),
        value: Value('Jl. Meteseh, Kota'),
        description: Value('Alamat perusahaan'),
      ),
    );

    await into(appSettings).insert(
      const AppSettingsCompanion(
        key: Value('company_phone'),
        value: Value('0274-123456'),
        description: Value('Nomor telepon perusahaan'),
      ),
    );

    await into(appSettings).insert(
      const AppSettingsCompanion(
        key: Value('allow_negative_stock'),
        value: Value('false'),
        description: Value('Izinkan stok negatif'),
      ),
    );

    await into(appSettings).insert(
      const AppSettingsCompanion(
        key: Value('default_due_days'),
        value: Value('30'),
        description: Value('Hari jatuh tempo default untuk kredit'),
      ),
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'saudara_erp',
  );
}

QueryExecutor _testConnection() {
  return driftDatabase(
    name: 'test_saudara_erp',
  );
}
