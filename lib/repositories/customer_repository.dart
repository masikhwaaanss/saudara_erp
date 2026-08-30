import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/daos/customers_dao.dart';
import 'package:saudara_erp/database/tables/customers_table.dart';
import 'package:saudara_erp/core/errors/app_exceptions.dart';
import 'package:saudara_erp/core/utils/logger.dart';

class CustomerRepository {
  final AppDatabase db;
  late final CustomersDao customersDao;

  CustomerRepository(this.db) {
    customersDao = CustomersDao(db);
  }

  /// Get customer by ID
  Future<Customer?> getCustomerById(int id) async {
    try {
      return await customersDao.getCustomerById(id);
    } catch (e, st) {
      AppLogger.error('Error getting customer', e, st);
      return null;
    }
  }

  /// Get customer by code
  Future<Customer?> getCustomerByCode(String code) async {
    try {
      return await customersDao.getCustomerByCode(code);
    } catch (e, st) {
      AppLogger.error('Error getting customer by code', e, st);
      return null;
    }
  }

  /// Get all active customers
  Future<List<Customer>> getAllActiveCustomers() async {
    try {
      return await customersDao.getAllActiveCustomers();
    } catch (e, st) {
      AppLogger.error('Error getting all customers', e, st);
      return [];
    }
  }

  /// Search customers
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllActiveCustomers();
      }
      return await customersDao.searchCustomers(query);
    } catch (e, st) {
      AppLogger.error('Error searching customers', e, st);
      return [];
    }
  }

  /// Create customer
  Future<Customer> createCustomer({
    required String code,
    required String name,
    required String phone,
    String? email,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    int creditLimit = 0,
    String? notes,
  }) async {
    try {
      // Check if code already exists
      final existing = await customersDao.getCustomerByCode(code);
      if (existing != null) {
        throw ValidationException(
          message: 'Kode pelanggan sudah ada',
          code: 'CODE_EXISTS',
        );
      }

      final customerId = await customersDao.createCustomer(
        CustomersCompanion(
          code: Value(code),
          name: Value(name),
          phone: Value(phone),
          email: Value(email),
          address: Value(address),
          city: Value(city),
          province: Value(province),
          postalCode: Value(postalCode),
          creditLimit: Value(creditLimit),
          currentReceivable: const Value(0),
          isActive: const Value(true),
          notes: Value(notes),
        ),
      );

      final customer = await customersDao.getCustomerById(customerId);
      if (customer == null) {
        throw DatabaseException(
          message: 'Gagal membuat pelanggan',
        );
      }

      AppLogger.success('Pelanggan berhasil dibuat: $name');
      return customer;
    } catch (e, st) {
      AppLogger.error('Error creating customer', e, st);
      rethrow;
    }
  }

  /// Update customer
  Future<bool> updateCustomer(Customer customer) async {
    try {
      return await customersDao.updateCustomer(customer);
    } catch (e, st) {
      AppLogger.error('Error updating customer', e, st);
      rethrow;
    }
  }

  /// Soft delete customer
  Future<bool> deleteCustomer(int id) async {
    try {
      return await customersDao.softDeleteCustomer(id);
    } catch (e, st) {
      AppLogger.error('Error deleting customer', e, st);
      rethrow;
    }
  }

  /// Update customer receivable
  Future<bool> updateCustomerReceivable(int customerId, int amount) async {
    try {
      return await customersDao.updateCustomerReceivable(customerId, amount);
    } catch (e, st) {
      AppLogger.error('Error updating customer receivable', e, st);
      rethrow;
    }
  }
}
