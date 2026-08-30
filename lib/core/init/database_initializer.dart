import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/core/security/password_hasher.dart';
import 'package:saudara_erp/database/tables/users_table.dart';

class DatabaseInitializer {
  /// Initialize database with default data
  static Future<void> initialize() async {
    final db = AppDatabase();

    try {
      // Check if owner already exists
      final existingOwner =
          await (db.select(db.users)..where((u) => u.username.equals('owner')))
              .getSingleOrNull();

      if (existingOwner == null) {
        // Create default owner account
        final passwordHash = PasswordHasher.hashPassword('owner123');
        await db.into(db.users).insert(
          UsersCompanion(
            username: const Value('owner'),
            passwordHash: Value(passwordHash),
            fullName: const Value('Owner Account'),
            role: const Value('owner'),
            email: const Value('owner@saudara.local'),
            phone: const Value('0274-000000'),
            address: const Value('Jl. Meteseh, Kota'),
            isActive: const Value(true),
          ),
        );
      }
    } catch (e) {
      print('Error initializing database: $e');
    }
  }
}
