import 'package:flutter_test/flutter_test.dart';
import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/repositories/auth_repository.dart';
import 'package:saudara_erp/core/constants/enum.dart';
import 'package:saudara_erp/core/security/password_hasher.dart';

void main() {
  group('Authentication Tests', () {
    late AppDatabase db;
    late AuthRepository authRepository;

    setUpAll(() async {
      db = AppDatabase();
      authRepository = AuthRepository(db);
    });

    tearDownAll(() async {
      // Don't close test database
    });

    test('User can register with valid credentials', () async {
      final user = await authRepository.register(
        username: 'testuser_${DateTime.now().millisecondsSinceEpoch}',
        password: 'password123',
        fullName: 'Test User',
        role: UserRole.admin_1,
      );

      expect(user.username, contains('testuser_'));
      expect(user.fullName, 'Test User');
      expect(user.role, 'admin_1');
      expect(user.isActive, true);
    });

    test('User cannot register with duplicate username', () async {
      final uniqueUsername = 'duplicate_${DateTime.now().millisecondsSinceEpoch}';
      
      await authRepository.register(
        username: uniqueUsername,
        password: 'password123',
        fullName: 'First User',
        role: UserRole.admin_1,
      );

      expect(
        () => authRepository.register(
          username: uniqueUsername,
          password: 'password456',
          fullName: 'Second User',
          role: UserRole.gudang,
        ),
        throwsException,
      );
    });

    test('User can login with correct credentials', () async {
      final username = 'logintest_${DateTime.now().millisecondsSinceEpoch}';
      
      await authRepository.register(
        username: username,
        password: 'password123',
        fullName: 'Login Test User',
        role: UserRole.owner,
      );

      final user = await authRepository.login(username, 'password123');

      expect(user.username, username);
      expect(user.isActive, true);
      expect(user.lastLogin, isNotNull);
    });

    test('User cannot login with incorrect password', () async {
      final username = 'wrongpass_${DateTime.now().millisecondsSinceEpoch}';
      
      await authRepository.register(
        username: username,
        password: 'correctpassword',
        fullName: 'Wrong Password User',
        role: UserRole.gudang,
      );

      expect(
        () => authRepository.login(username, 'incorrectpassword'),
        throwsException,
      );
    });

    test('User cannot login with non-existent username', () async {
      expect(
        () => authRepository.login('nonexistent_${DateTime.now()}', 'password123'),
        throwsException,
      );
    });

    test('Password hash is secure', () {
      final password = 'securepassword';
      final hash1 = PasswordHasher.hashPassword(password);
      final hash2 = PasswordHasher.hashPassword(password);

      // Same password should produce same hash
      expect(hash1, hash2);

      // Hash should be different from original password
      expect(hash1, isNot(password));

      // Should verify correctly
      expect(PasswordHasher.verifyPassword(password, hash1), true);
      expect(PasswordHasher.verifyPassword('wrongpassword', hash1), false);
    });

    test('User can change password', () async {
      final username = 'changepass_${DateTime.now().millisecondsSinceEpoch}';
      
      await authRepository.register(
        username: username,
        password: 'oldpassword',
        fullName: 'Change Password User',
        role: UserRole.admin_1,
      );

      // Get user
      final user = await authRepository.getUserByUsername(username);
      expect(user, isNotNull);

      // Change password
      final success = await authRepository.changePassword(
        user!.id,
        'oldpassword',
        'newpassword',
      );
      expect(success, true);

      // Try login with new password
      final loginUser = await authRepository.login(username, 'newpassword');
      expect(loginUser.username, username);
    });
  });
}
