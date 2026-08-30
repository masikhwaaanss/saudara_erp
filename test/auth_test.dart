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
      db = AppDatabase.test();
      authRepository = AuthRepository(db);
    });

    tearDownAll(() async {
      await db.close();
    });

    test('User can register with valid credentials', () async {
      final user = await authRepository.register(
        username: 'testuser',
        password: 'password123',
        fullName: 'Test User',
        role: UserRole.admin_1,
      );

      expect(user.username, 'testuser');
      expect(user.fullName, 'Test User');
      expect(user.role, 'admin_1');
      expect(user.isActive, true);
    });

    test('User cannot register with duplicate username', () async {
      await authRepository.register(
        username: 'duplicate',
        password: 'password123',
        fullName: 'First User',
        role: UserRole.admin_1,
      );

      expect(
        () => authRepository.register(
          username: 'duplicate',
          password: 'password456',
          fullName: 'Second User',
          role: UserRole.gudang,
        ),
        throwsException,
      );
    });

    test('User can login with correct credentials', () async {
      await authRepository.register(
        username: 'logintest',
        password: 'password123',
        fullName: 'Login Test User',
        role: UserRole.owner,
      );

      final user = await authRepository.login('logintest', 'password123');

      expect(user.username, 'logintest');
      expect(user.isActive, true);
      expect(user.lastLogin, isNotNull);
    });

    test('User cannot login with incorrect password', () async {
      await authRepository.register(
        username: 'wrongpass',
        password: 'correctpassword',
        fullName: 'Wrong Password User',
        role: UserRole.gudang,
      );

      expect(
        () => authRepository.login('wrongpass', 'incorrectpassword'),
        throwsException,
      );
    });

    test('User cannot login with non-existent username', () async {
      expect(
        () => authRepository.login('nonexistent', 'password123'),
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
      await authRepository.register(
        username: 'changepass',
        password: 'oldpassword',
        fullName: 'Change Password User',
        role: UserRole.admin_1,
      );

      // Get user
      final user = await authRepository.getUserByUsername('changepass');
      expect(user, isNotNull);

      // Change password
      final success = await authRepository.changePassword(
        user!.id,
        'oldpassword',
        'newpassword',
      );
      expect(success, true);

      // Try login with new password
      final loginUser = await authRepository.login('changepass', 'newpassword');
      expect(loginUser.username, 'changepass');
    });
  });
}
