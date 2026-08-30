import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/daos/suppliers_dao.dart';
import 'package:saudara_erp/database/tables/suppliers_table.dart';
import 'package:saudara_erp/core/errors/app_exceptions.dart';
import 'package:saudara_erp/core/utils/logger.dart';

class SupplierRepository {
  final AppDatabase db;
  late final SuppliersDao suppliersDao;

  SupplierRepository(this.db) {
    suppliersDao = SuppliersDao(db);
  }

  /// Get supplier by ID
  Future<Supplier?> getSupplierById(int id) async {
    try {
      return await suppliersDao.getSupplierById(id);
    } catch (e, st) {
      AppLogger.error('Error getting supplier', e, st);
      return null;
    }
  }

  /// Get supplier by code
  Future<Supplier?> getSupplierByCode(String code) async {
    try {
      return await suppliersDao.getSupplierByCode(code);
    } catch (e, st) {
      AppLogger.error('Error getting supplier by code', e, st);
      return null;
    }
  }

  /// Get all active suppliers
  Future<List<Supplier>> getAllActiveSuppliers() async {
    try {
      return await suppliersDao.getAllActiveSuppliers();
    } catch (e, st) {
      AppLogger.error('Error getting all suppliers', e, st);
      return [];
    }
  }

  /// Search suppliers
  Future<List<Supplier>> searchSuppliers(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllActiveSuppliers();
      }
      return await suppliersDao.searchSuppliers(query);
    } catch (e, st) {
      AppLogger.error('Error searching suppliers', e, st);
      return [];
    }
  }

  /// Create supplier
  Future<Supplier> createSupplier({
    required String code,
    required String name,
    required String phone,
    String? email,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankName,
    String? notes,
  }) async {
    try {
      // Check if code already exists
      final existing = await suppliersDao.getSupplierByCode(code);
      if (existing != null) {
        throw ValidationException(
          message: 'Kode supplier sudah ada',
          code: 'CODE_EXISTS',
        );
      }

      final supplierId = await suppliersDao.createSupplier(
        SuppliersCompanion(
          code: Value(code),
          name: Value(name),
          phone: Value(phone),
          email: Value(email),
          address: Value(address),
          city: Value(city),
          province: Value(province),
          postalCode: Value(postalCode),
          bankAccountName: Value(bankAccountName),
          bankAccountNumber: Value(bankAccountNumber),
          bankName: Value(bankName),
          currentPayable: const Value(0),
          isActive: const Value(true),
          notes: Value(notes),
        ),
      );

      final supplier = await suppliersDao.getSupplierById(supplierId);
      if (supplier == null) {
        throw DatabaseException(
          message: 'Gagal membuat supplier',
        );
      }

      AppLogger.success('Supplier berhasil dibuat: $name');
      return supplier;
    } catch (e, st) {
      AppLogger.error('Error creating supplier', e, st);
      rethrow;
    }
  }

  /// Update supplier
  Future<bool> updateSupplier(Supplier supplier) async {
    try {
      return await suppliersDao.updateSupplier(supplier);
    } catch (e, st) {
      AppLogger.error('Error updating supplier', e, st);
      rethrow;
    }
  }

  /// Soft delete supplier
  Future<bool> deleteSupplier(int id) async {
    try {
      return await suppliersDao.softDeleteSupplier(id);
    } catch (e, st) {
      AppLogger.error('Error deleting supplier', e, st);
      rethrow;
    }
  }

  /// Update supplier payable
  Future<bool> updateSupplierPayable(int supplierId, int amount) async {
    try {
      return await suppliersDao.updateSupplierPayable(supplierId, amount);
    } catch (e, st) {
      AppLogger.error('Error updating supplier payable', e, st);
      rethrow;
    }
  }
}
