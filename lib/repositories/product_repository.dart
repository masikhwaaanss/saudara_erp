import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/daos/products_dao.dart';
import 'package:saudara_erp/database/tables/products_table.dart';
import 'package:saudara_erp/core/constants/enum.dart';
import 'package:saudara_erp/core/errors/app_exceptions.dart';
import 'package:saudara_erp/core/utils/logger.dart';

class ProductRepository {
  final AppDatabase db;
  late final ProductsDao productsDao;

  ProductRepository(this.db) {
    productsDao = ProductsDao(db);
  }

  /// Get product by ID
  Future<Product?> getProductById(int id) async {
    try {
      return await productsDao.getProductById(id);
    } catch (e, st) {
      AppLogger.error('Error getting product', e, st);
      return null;
    }
  }

  /// Get product by code
  Future<Product?> getProductByCode(String code) async {
    try {
      return await productsDao.getProductByCode(code);
    } catch (e, st) {
      AppLogger.error('Error getting product by code', e, st);
      return null;
    }
  }

  /// Get all active products
  Future<List<Product>> getAllActiveProducts() async {
    try {
      return await productsDao.getAllActiveProducts();
    } catch (e, st) {
      AppLogger.error('Error getting all products', e, st);
      return [];
    }
  }

  /// Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllActiveProducts();
      }
      return await productsDao.searchProducts(query);
    } catch (e, st) {
      AppLogger.error('Error searching products', e, st);
      return [];
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      return await productsDao.getProductsByCategory(categoryId);
    } catch (e, st) {
      AppLogger.error('Error getting products by category', e, st);
      return [];
    }
  }

  /// Create product
  Future<Product> createProduct({
    required String code,
    required String name,
    required int categoryId,
    required int unitId,
    required CalculationType calculationType,
    required int costPrice,
    required int buyerPrice,
    required int applicatorPrice,
    required int agentPrice,
    int minimumStock = 0,
    int maximumStock = 0,
    String? description,
  }) async {
    try {
      // Check if code already exists
      final existing = await productsDao.getProductByCode(code);
      if (existing != null) {
        throw ValidationException(
          message: 'Kode produk sudah ada',
          code: 'CODE_EXISTS',
        );
      }

      final productId = await productsDao.createProduct(
        ProductsCompanion(
          code: Value(code),
          name: Value(name),
          categoryId: Value(categoryId),
          unitId: Value(unitId),
          calculationType: Value(calculationType.value),
          costPrice: Value(costPrice),
          buyerPrice: Value(buyerPrice),
          applicatorPrice: Value(applicatorPrice),
          agentPrice: Value(agentPrice),
          minimumStock: Value(minimumStock),
          maximumStock: Value(maximumStock),
          description: Value(description),
          isActive: const Value(true),
        ),
      );

      final product = await productsDao.getProductById(productId);
      if (product == null) {
        throw DatabaseException(
          message: 'Gagal membuat produk',
        );
      }

      AppLogger.success('Produk berhasil dibuat: $name');
      return product;
    } catch (e, st) {
      AppLogger.error('Error creating product', e, st);
      rethrow;
    }
  }

  /// Update product
  Future<bool> updateProduct({
    required int id,
    required String code,
    required String name,
    required int categoryId,
    required int unitId,
    required CalculationType calculationType,
    required int costPrice,
    required int buyerPrice,
    required int applicatorPrice,
    required int agentPrice,
    int minimumStock = 0,
    int maximumStock = 0,
    String? description,
  }) async {
    try {
      final product = await productsDao.getProductById(id);
      if (product == null) {
        throw NotFoundException(
          message: 'Produk tidak ditemukan',
        );
      }

      // Check if code exists for other products
      if (code != product.code) {
        final existing = await productsDao.getProductByCode(code);
        if (existing != null) {
          throw ValidationException(
            message: 'Kode produk sudah digunakan',
            code: 'CODE_EXISTS',
          );
        }
      }

      return await productsDao.updateProduct(
        product.copyWith(
          code: code,
          name: name,
          categoryId: categoryId,
          unitId: unitId,
          calculationType: calculationType.value,
          costPrice: costPrice,
          buyerPrice: buyerPrice,
          applicatorPrice: applicatorPrice,
          agentPrice: agentPrice,
          minimumStock: minimumStock,
          maximumStock: maximumStock,
          description: description,
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e, st) {
      AppLogger.error('Error updating product', e, st);
      rethrow;
    }
  }

  /// Soft delete product
  Future<bool> deleteProduct(int id) async {
    try {
      return await productsDao.softDeleteProduct(id);
    } catch (e, st) {
      AppLogger.error('Error deleting product', e, st);
      rethrow;
    }
  }

  /// Get all categories
  Future<List<ProductCategory>> getAllCategories() async {
    try {
      return await productsDao.getAllCategories();
    } catch (e, st) {
      AppLogger.error('Error getting categories', e, st);
      return [];
    }
  }

  /// Get all units
  Future<List<ProductUnit>> getAllUnits() async {
    try {
      return await productsDao.getAllUnits();
    } catch (e, st) {
      AppLogger.error('Error getting units', e, st);
      return [];
    }
  }

  /// Create category
  Future<ProductCategory> createCategory(String name, [String? description]) async {
    try {
      final categoryId = await productsDao.createCategory(
        ProductCategoriesCompanion(
          name: Value(name),
          description: Value(description),
          isActive: const Value(true),
        ),
      );

      final category = await (db.select(db.productCategories)
            ..where((c) => c.id.equals(categoryId)))
          .getSingleOrNull();

      if (category == null) {
        throw DatabaseException(
          message: 'Gagal membuat kategori',
        );
      }

      return category;
    } catch (e, st) {
      AppLogger.error('Error creating category', e, st);
      rethrow;
    }
  }

  /// Create unit
  Future<ProductUnit> createUnit(String name, String symbol, [String? description]) async {
    try {
      final unitId = await productsDao.createUnit(
        ProductUnitsCompanion(
          name: Value(name),
          symbol: Value(symbol),
          description: Value(description),
        ),
      );

      final unit = await (db.select(db.productUnits)..where((u) => u.id.equals(unitId)))
          .getSingleOrNull();

      if (unit == null) {
        throw DatabaseException(
          message: 'Gagal membuat satuan',
        );
      }

      return unit;
    } catch (e, st) {
      AppLogger.error('Error creating unit', e, st);
      rethrow;
    }
  }

  /// Get product detail with relations
  Future<Map<String, dynamic>?> getProductDetail(int id) async {
    try {
      return await productsDao.getProductDetail(id);
    } catch (e, st) {
      AppLogger.error('Error getting product detail', e, st);
      return null;
    }
  }
}
