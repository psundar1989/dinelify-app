import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/network/dio_client.dart';
import '../models/menu_day.dart';

class MenuService {
  MenuService(this._dio);
  final Dio _dio;

  Future<List<MenuDayModel>> weekly({DateTime? startDate}) => unwrap(
    () => _dio.get(
      '/menus/weekly',
      queryParameters: startDate != null
          ? {'start_date': DateFormat('yyyy-MM-dd').format(startDate)}
          : null,
    ),
    (data) => (data['days'] as List<dynamic>)
        .map((e) => MenuDayModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Future<MenuDayModel> day(DateTime date) => unwrap(
    () => _dio.get('/menus/${DateFormat('yyyy-MM-dd').format(date)}'),
    (data) => MenuDayModel.fromJson(data as Map<String, dynamic>),
  );
}
