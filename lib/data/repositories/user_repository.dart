import '../models/user.dart';
import '../services/user_service.dart';

class UserRepository {
  UserRepository(this._service);
  final UserService _service;

  Future<RegisterResult> register({
    required String name,
    required String mobile,
    required int locationId,
    required int roomId,
  }) => _service.register(name: name, mobile: mobile, locationId: locationId, roomId: roomId);

  Future<UserModel> profile() => _service.profile();

  Future<UserModel> updateProfile({String? name, int? locationId, int? roomId}) =>
      _service.updateProfile(name: name, locationId: locationId, roomId: roomId);
}
