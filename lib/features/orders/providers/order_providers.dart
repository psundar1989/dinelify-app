import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/order.dart';
import '../../../data/providers.dart';

final orderHistoryProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) {
  return ref.watch(orderRepositoryProvider).history();
});

final orderDetailsProvider = FutureProvider.autoDispose.family<OrderModel, int>((ref, id) {
  return ref.watch(orderRepositoryProvider).show(id);
});
