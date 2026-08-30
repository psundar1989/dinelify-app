import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/core_providers.dart';
import 'repositories/auth_repository.dart';
import 'repositories/location_repository.dart';
import 'repositories/menu_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/user_repository.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/menu_service.dart';
import 'services/notification_service.dart';
import 'services/order_service.dart';
import 'services/user_service.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(AuthService(ref.watch(dioProvider))),
);
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(UserService(ref.watch(dioProvider))),
);
final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => MenuRepository(MenuService(ref.watch(dioProvider))),
);
final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(OrderService(ref.watch(dioProvider))),
);
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(NotificationService(ref.watch(dioProvider))),
);
final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => LocationRepository(LocationService(ref.watch(dioProvider))),
);
