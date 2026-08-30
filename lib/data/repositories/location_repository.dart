import '../models/location.dart';
import '../models/room.dart';
import '../services/location_service.dart';

class LocationRepository {
  LocationRepository(this._service);
  final LocationService _service;

  Future<List<LocationModel>> locations() => _service.locations();

  Future<List<RoomModel>> rooms(int locationId) => _service.rooms(locationId);
}
