import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  NotificationRepository(this._service);
  final NotificationService _service;

  Future<List<AppNotificationModel>> list() => _service.list();

  Future<void> markAsRead(int id) => _service.markAsRead(id);
}
