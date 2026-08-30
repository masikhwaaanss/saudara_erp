import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/products_table.dart';

class ProductsDao {
  final AppDatabase db;

  ProductsDao(this.db);

  /// Get product by ID
  Future<Product?> getProductById(int id) {
    return (db.select(db.products)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Get product by code
  Future<Product?> getProductByCode(String code) {
    return (db.select(db.products)..where((p) => p.code.equals(code))).getSingleOrNull();
  }

  /// Get all active products
  Future<List<Product>> getAllActiveProducts() {
    return (db.select(db.products)
          ..where((p) => p.isActive.equals(true) & p.deletedAt.isNull()))
        .get();
  }

  /// Search products by name or code
  Future<List<Product>> searchProducts(String query) {
    return (db.select(db.products)
          ..where((p) =>
              (p.name.like('%$query%') | p.code.like('%$query%')) &
              p.isActive.equals(true) &
              p.deletedAt.isNull()))
        .get();
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(int categoryId) {
    return (db.select(db.products)
          ..where((p) =>
              p.categoryId.equals(categoryId) &
              p.isActive.equals(true) &
              p.deletedAt.isNull()))
        .get();
  }

  /// Create product
  Future<int> createProduct(ProductsCompanion product) {
    return db.into(db.products).insert(product);
  }

  /// Update product
  Future<bool> updateProduct(Product product) {
    return db.update(db.products).replace(product);
  }

  /// Soft delete product
  Future<bool> softDeleteProduct(int productId) {
    return (db.update(db.products)..where((p) => p.id.equals(productId)))
        .write(ProductsCompanion(deletedAt: Value(DateTime.now())));
  }

  /// Get all categories
  Future<List<ProductCategory>> getAllCategories() {
    return (db.select(db.productCategories)..where((c) => c.isActive.equals(true))).get();
  }

  /// Get all units
  Future<List<ProductUnit>> getAllUnits() {
    return db.select(db.productUnits).get();
  }

  /// Create category
  Future<int> createCategory(ProductCategoriesCompanion category) {
    return db.into(db.productCategories).insert(category);
  }

  /// Create unit
  Future<int> createUnit(ProductUnitsCompanion unit) {
    return db.into(db.productUnits).insert(unit);
  }

  /// Get product by ID with relations (category and unit)
  Future<Map<String, dynamic>?> getProductDetail(int id) async {
    final product = await getProductById(id);
    if (product == null) return null;

    final category = await (db.select(db.productCategories)
          ..where((c) => c.id.equals(product.categoryId)))
        .getSingleOrNull();
    final unit = await (db.select(db.productUnits)..where((u) => u.id.equals(product.unitId)))
        .getSingleOrNull();

    return {
      'product': product,
      'category': category,
      'unit': unit,
    };
  }
}
