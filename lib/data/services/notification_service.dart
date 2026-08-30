import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../models/app_notification.dart';

class NotificationService {
  NotificationService(this._dio);
  final Dio _dio;

  Future<List<AppNotificationModel>> list() => unwrap(
    () => _dio.get('/notifications'),
    (data) => ((data as Map<String, dynamic>)['data'] as List<dynamic>)
        .map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Future<void> markAsRead(int id) => unwrap(() => _dio.post('/notifications/$id/read'), (_) {});
}
