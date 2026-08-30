import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../models/user.dart';

class MobileLoginResult {
  const MobileLoginResult({required this.isNewUser, this.token, this.user, this.mobile});
  final bool isNewUser;
  final String? token;
  final UserModel? user;
  final String? mobile;
}

class AuthService {
  AuthService(this._dio);
  final Dio _dio;

  /// Looks the mobile number up against the registered users — the only
  /// step "Order Food" needs to resume an existing account, matching the
  /// website (no OTP).
  Future<MobileLoginResult> loginByMobile(String mobile) => unwrap(
    () => _dio.post('/auth/login-by-mobile', data: {'mobile': mobile}),
    (data) => MobileLoginResult(
      isNewUser: data['is_new_user'] as bool,
      token: data['token'] as String?,
      user: data['user'] != null ? UserModel.fromJson(data['user'] as Map<String, dynamic>) : null,
      mobile: data['mobile'] as String?,
    ),
  );

  Future<void> logout() => unwrap(() => _dio.post('/auth/logout'), (_) {});

  Future<UserModel> me() => unwrap(
    () => _dio.get('/auth/me'),
    (data) => UserModel.fromJson(data as Map<String, dynamic>),
  );
}
