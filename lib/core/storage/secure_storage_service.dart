import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around FlutterSecureStorage — the only place the auth
/// token touches disk. Never persisted with SharedPreferences.
class SecureStorageService {
  SecureStorageService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';

  /// A short timeout keeps app startup from hanging forever if the
  /// platform's secure-storage backend is ever slow/unavailable to respond
  /// — bootstrap() falls back to "unauthenticated" instead of stalling on
  /// the splash screen.
  static const _readTimeout = Duration(seconds: 5);

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey).timeout(_readTimeout, onTimeout: () => null);

  Future<void> saveUserId(int id) => _storage.write(key: _userIdKey, value: id.toString());

  Future<int?> readUserId() async {
    final value = await _storage.read(key: _userIdKey);
    return value == null ? null : int.tryParse(value);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
  }
}
