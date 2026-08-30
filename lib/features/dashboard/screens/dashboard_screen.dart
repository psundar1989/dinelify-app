import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/order_card.dart';
import '../../auth/providers/auth_controller.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final upcomingOrders = ref.watch(upcomingOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(upcomingOrdersProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Hi, ${user?.name.split(' ').first ?? 'there'} 👋',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              user?.location != null ? '${user!.location!.name} · Room ${user.room?.roomNumber ?? '-'}' : '',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.restaurant_menu,
                    label: 'Weekly Menu',
                    onTap: () => context.go('/menu'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.receipt_long,
                    label: 'Upcoming Orders',
                    onTap: () => context.go('/orders/upcoming'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Upcoming orders', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            upcomingOrders.when(
              loading: () => const LoadingIndicator(),
              error: (err, _) => ErrorStateView(
                message: err.toString(),
                onRetry: () => ref.invalidate(upcomingOrdersProvider),
              ),
              data: (orders) {
                if (orders.isEmpty) {
                  return const EmptyState(
                    message: 'No upcoming orders yet. Plan your meals from the Weekly Menu.',
                    icon: Icons.event_busy,
                  );
                }
                final sorted = [...orders]..sort((a, b) => a.orderDate.compareTo(b.orderDate));
                return Column(
                  children: sorted
                      .take(3)
                      .map(
                        (order) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: OrderCard(order: order, onTap: () => context.push('/orders/${order.id}')),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
