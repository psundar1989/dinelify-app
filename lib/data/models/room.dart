class RoomModel {
  const RoomModel({
    required this.id,
    required this.locationId,
    required this.roomNumber,
    required this.status,
  });

  final int id;
  final int locationId;
  final String roomNumber;
  final String status;

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
    id: json['id'] as int,
    locationId: json['location_id'] as int,
    roomNumber: json['room_number'] as String,
    status: json['status'] as String? ?? 'active',
  );
}
