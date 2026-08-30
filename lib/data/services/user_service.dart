import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../models/user.dart';

class RegisterResult {
  const RegisterResult({required this.token, required this.user});
  final String token;
  final UserModel user;
}

class UserService {
  UserService(this._dio);
  final Dio _dio;

  Future<RegisterResult> register({
    required String name,
    required String mobile,
    required int locationId,
    required int roomId,
  }) => unwrap(
    () => _dio.post(
      '/user/register',
      data: {'name': name, 'mobile': mobile, 'location_id': locationId, 'room_id': roomId},
    ),
    (data) => RegisterResult(
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    ),
  );

  Future<UserModel> profile() => unwrap(
    () => _dio.get('/user/profile'),
    (data) => UserModel.fromJson(data as Map<String, dynamic>),
  );

  Future<UserModel> updateProfile({String? name, int? locationId, int? roomId}) => unwrap(
    () => _dio.put(
      '/user/profile',
      data: {
        if (name != null) 'name': name,
        if (locationId != null) 'location_id': locationId,
        if (roomId != null) 'room_id': roomId,
      },
    ),
    (data) => UserModel.fromJson(data as Map<String, dynamic>),
  );
}
