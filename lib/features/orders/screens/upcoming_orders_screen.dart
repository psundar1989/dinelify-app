import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/order_card.dart';
import '../../dashboard/providers/dashboard_providers.dart';

class UpcomingOrdersScreen extends ConsumerWidget {
  const UpcomingOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(upcomingOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Orders'),
        actions: [
          TextButton(
            onPressed: () => context.push('/orders/history'),
            child: const Text('History'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(upcomingOrdersProvider),
        child: orders.when(
          loading: () => const LoadingIndicator(),
          error: (err, _) => ErrorStateView(
            message: err.toString(),
            onRetry: () => ref.invalidate(upcomingOrdersProvider),
          ),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyState(
                    message: 'No upcoming orders. Head to the Weekly Menu to plan your meals.',
                    icon: Icons.event_available,
                  ),
                ],
              );
            }
            final sorted = [...list]..sort((a, b) => a.orderDate.compareTo(b.orderDate));
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final order = sorted[index];
                return OrderCard(order: order, onTap: () => context.push('/orders/${order.id}'));
              },
            );
          },
        ),
      ),
    );
  }
}
