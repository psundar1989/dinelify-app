import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_notification.dart';
import '../../../data/providers.dart';

final notificationsProvider = FutureProvider.autoDispose<List<AppNotificationModel>>((ref) {
  return ref.watch(notificationRepositoryProvider).list();
});
