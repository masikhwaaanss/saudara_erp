import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/daos/users_dao.dart';
import 'package:saudara_erp/database/tables/users_table.dart';
import 'package:saudara_erp/core/constants/enum.dart';
import 'package:saudara_erp/core/security/password_hasher.dart';
import 'package:saudara_erp/core/errors/app_exceptions.dart';
import 'package:saudara_erp/core/utils/logger.dart';

class AuthRepository {
  final AppDatabase db;
  late final UsersDao usersDao;

  AuthRepository(this.db) {
    usersDao = UsersDao(db);
  }

  /// Register new user
  Future<User> register({
    required String username,
    required String password,
    required String fullName,
    required UserRole role,
    String? email,
    String? phone,
    String? address,
  }) async {
    try {
      // Check if username already exists
      final existing = await usersDao.getUserByUsername(username);
      if (existing != null) {
        throw ValidationException(
          message: 'Username sudah terdaftar',
          code: 'USERNAME_EXISTS',
        );
      }

      // Hash password
      final passwordHash = PasswordHasher.hashPassword(password);

      // Create user
      final userId = await usersDao.createUser(
        UsersCompanion(
          username: Value(username),
          passwordHash: Value(passwordHash),
          fullName: Value(fullName),
          role: Value(role.value),
          email: Value(email),
          phone: Value(phone),
          address: Value(address),
          isActive: const Value(true),
        ),
      );

      final user = await usersDao.getUserById(userId);
      if (user == null) {
        throw DatabaseException(
          message: 'Gagal membuat user',
        );
      }

      AppLogger.success('User berhasil dibuat: $username');
      return user;
    } catch (e, st) {
      AppLogger.error('Error registering user', e, st);
      rethrow;
    }
  }

  /// Login user
  Future<User> login(String username, String password) async {
    try {
      final user = await usersDao.getUserByUsername(username);
      if (user == null) {
        throw AuthException(
          message: 'Username atau password salah',
          code: 'INVALID_CREDENTIALS',
        );
      }

      if (!user.isActive) {
        throw AuthException(
          message: 'User tidak aktif',
          code: 'USER_INACTIVE',
        );
      }

      // Verify password
      if (!PasswordHasher.verifyPassword(password, user.passwordHash)) {
        throw AuthException(
          message: 'Username atau password salah',
          code: 'INVALID_CREDENTIALS',
        );
      }

      // Update last login
      await usersDao.updateLastLogin(user.id);

      AppLogger.success('Login berhasil: ${user.username}');
      return user;
    } catch (e, st) {
      AppLogger.error('Error logging in', e, st);
      rethrow;
    }
  }

  /// Get user by ID
  Future<User?> getUserById(int id) async {
    try {
      return await usersDao.getUserById(id);
    } catch (e, st) {
      AppLogger.error('Error getting user', e, st);
      return null;
    }
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    try {
      return await usersDao.getAllUsers();
    } catch (e, st) {
      AppLogger.error('Error getting all users', e, st);
      return [];
    }
  }

  /// Update user
  Future<bool> updateUser(User user) async {
    try {
      return await usersDao.updateUser(user);
    } catch (e, st) {
      AppLogger.error('Error updating user', e, st);
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final user = await usersDao.getUserById(userId);
      if (user == null) {
        throw NotFoundException(
          message: 'User tidak ditemukan',
        );
      }

      if (!PasswordHasher.verifyPassword(oldPassword, user.passwordHash)) {
        throw ValidationException(
          message: 'Password lama tidak cocok',
          code: 'INVALID_OLD_PASSWORD',
        );
      }

      final newHash = PasswordHasher.hashPassword(newPassword);
      final updatedUser = user.copyWith(passwordHash: newHash);
      return await usersDao.updateUser(updatedUser);
    } catch (e, st) {
      AppLogger.error('Error changing password', e, st);
      rethrow;
    }
  }
}
