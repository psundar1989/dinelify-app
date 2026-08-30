import 'location.dart';
import 'room.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    this.mobile,
    this.email,
    this.emailVerifiedAt,
    required this.status,
    this.location,
    this.room,
  });

  final int id;
  final String name;
  final String? mobile;
  final String? email;
  final DateTime? emailVerifiedAt;
  final String status;
  final LocationModel? location;
  final RoomModel? room;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int,
    name: json['name'] as String,
    mobile: json['mobile'] as String?,
    email: json['email'] as String?,
    emailVerifiedAt: json['email_verified_at'] != null
        ? DateTime.parse(json['email_verified_at'] as String)
        : null,
    status: json['status'] as String? ?? 'active',
    location: json['location'] is Map<String, dynamic>
        ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
        : null,
    room: json['room'] is Map<String, dynamic>
        ? RoomModel.fromJson(json['room'] as Map<String, dynamic>)
        : null,
  );
}
