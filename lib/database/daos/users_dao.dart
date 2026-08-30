import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/users_table.dart';

class UsersDao {
  final AppDatabase db;

  UsersDao(this.db);

  /// Get user by ID
  Future<User?> getUserById(int id) {
    return (db.select(db.users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  /// Get user by username
  Future<User?> getUserByUsername(String username) {
    return (db.select(db.users)..where((u) => u.username.equals(username))).getSingleOrNull();
  }

  /// Get all users
  Future<List<User>> getAllUsers() {
    return db.select(db.users).get();
  }

  /// Create user
  Future<int> createUser(UsersCompanion user) {
    return db.into(db.users).insert(user);
  }

  /// Update user
  Future<bool> updateUser(User user) {
    return db.update(db.users).replace(user);
  }

  /// Update last login
  Future<bool> updateLastLogin(int userId) {
    return (db.update(db.users)..where((u) => u.id.equals(userId)))
        .write(UsersCompanion(lastLogin: Value(DateTime.now())));
  }
}
