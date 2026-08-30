import '../models/user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository(this._service);
  final AuthService _service;

  Future<MobileLoginResult> loginByMobile(String mobile) => _service.loginByMobile(mobile);

  Future<void> logout() => _service.logout();

  Future<UserModel> me() => _service.me();
}
