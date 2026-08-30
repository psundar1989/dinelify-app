class LocationModel {
  const LocationModel({required this.id, required this.name, required this.status});

  final int id;
  final String name;
  final String status;

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    id: json['id'] as int,
    name: json['name'] as String,
    status: json['status'] as String? ?? 'active',
  );
}
