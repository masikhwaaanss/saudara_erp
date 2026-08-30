import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/users_table.dart';
import 'package:saudara_erp/repositories/auth_repository.dart';
import 'package:saudara_erp/core/errors/app_exceptions.dart';

// Database provider
final databaseProvider = Provider((ref) => AppDatabase());

// Auth repository provider
final authRepositoryProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return AuthRepository(db);
});

// Current user state
class CurrentUserState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isLoggedIn;

  CurrentUserState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isLoggedIn = false,
  });

  CurrentUserState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isLoggedIn,
  }) {
    return CurrentUserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

// Auth state notifier
class AuthNotifier extends StateNotifier<CurrentUserState> {
  final AuthRepository authRepository;

  AuthNotifier(this.authRepository) : super(CurrentUserState());

  /// Login user
  Future<bool> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final user = await authRepository.login(username, password);
      state = CurrentUserState(
        user: user,
        isLoading: false,
        isLoggedIn: true,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: $e',
      );
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = CurrentUserState();
  }

  /// Check if user is logged in
  bool get isLoggedIn => state.isLoggedIn && state.user != null;
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, CurrentUserState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

// Is logged in provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});
