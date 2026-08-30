import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../data/models/user.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import 'auth_state.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final controller = AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
    storage: ref.watch(secureStorageProvider),
  );
  ref.watch(unauthorizedSignalProvider).register(controller.handleUnauthorized);
  return controller;
});

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required SecureStorageService storage,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _storage = storage,
       super(const AuthState.unknown());

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final SecureStorageService _storage;

  /// Called once at app startup to restore a session from secure storage.
  Future<void> bootstrap() async {
    final token = await _storage.readToken();
    if (token == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await _userRepository.profile();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await _storage.clear();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> onLoggedIn({required String token, required UserModel user}) async {
    await _storage.saveToken(token);
    await _storage.saveUserId(user.id);
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> refreshProfile() async {
    final user = await _userRepository.profile();
    state = state.copyWith(status: AuthStatus.authenticated, user: user);
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (_) {
      // Even if the server call fails, clear the local session.
    }
    await _storage.clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Invoked by the Dio interceptor on any 401 response.
  void handleUnauthorized() {
    if (state.status == AuthStatus.authenticated) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}
