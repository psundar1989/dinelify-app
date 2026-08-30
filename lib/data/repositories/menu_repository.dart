import '../models/menu_day.dart';
import '../services/menu_service.dart';

class MenuRepository {
  MenuRepository(this._service);
  final MenuService _service;

  Future<List<MenuDayModel>> weekly({DateTime? startDate}) => _service.weekly(startDate: startDate);

  Future<MenuDayModel> day(DateTime date) => _service.day(date);
}
