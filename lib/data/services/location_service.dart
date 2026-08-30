import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../models/location.dart';
import '../models/room.dart';

class LocationService {
  LocationService(this._dio);
  final Dio _dio;

  Future<List<LocationModel>> locations() => unwrap(
    () => _dio.get('/locations'),
    (data) => (data as List<dynamic>).map((e) => LocationModel.fromJson(e as Map<String, dynamic>)).toList(),
  );

  Future<List<RoomModel>> rooms(int locationId) => unwrap(
    () => _dio.get('/rooms', queryParameters: {'location_id': locationId}),
    (data) => (data as List<dynamic>).map((e) => RoomModel.fromJson(e as Map<String, dynamic>)).toList(),
  );
}
