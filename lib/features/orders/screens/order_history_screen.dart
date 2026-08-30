import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/order_card.dart';
import '../providers/order_providers.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: orders.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) =>
            ErrorStateView(message: err.toString(), onRetry: () => ref.invalidate(orderHistoryProvider)),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(message: 'No past orders yet.', icon: Icons.history);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final order = list[index];
              return OrderCard(order: order, onTap: () => context.push('/orders/${order.id}'));
            },
          );
        },
      ),
    );
  }
}
